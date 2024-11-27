import AppleSignIn from "apple-signin-auth";
import axios from "axios";
import { OAuth2Client } from "google-auth-library";
import { GraphQLError } from "graphql";
import { DateTime } from "luxon";
import { v4 as uuid } from "uuid";

import { GrantType, generateToken } from "../../auth";
import { Context } from "../../index";
import { LOG_LEVEL, BAD_REQUEST, INTERNAL_SERVER_ERROR } from "../../types";
import { getItemByIndex, putItem } from "../../aws/dynamodb";
import { USERS_TABLE } from "../../../infrastructure/stacks/lynxApiStack";

export enum OAuthType {
    APPLE,
    GOOGLE,
    FACEBOOK
}

interface Args {
    oauthLoginId: {
        type: keyof typeof OAuthType;
        id: string;
        token: string;
    };
    email?: string;
    userData?: {
        key: string;
        value: string;
    }[];
}

export interface AuthorizationToken {
    accessToken: string;
    expiryDate: string;
    refreshToken: string;
}

interface FacebookData {
    data: {
        app_id: string;
        type: string;
        application: string;
        data_access_expires_at: number;
        expires_at: number;
        is_valid: boolean;
        issued_at: number;
        metadata: Map<string, string>;
        scopes: string[];
        user_id: string;
    };
}

const oauthSignIn = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<AuthorizationToken> => {
    const { type, id, token } = args.oauthLoginId;
    await verifyToken(OAuthType[type], id, token);
    return await oauthLogin(idKeyFromIdType[OAuthType[type]], id, args.email, args.userData);
};

export const verifyToken = async (type: OAuthType, id: string, token: string) => {
    console[LOG_LEVEL](`Verifying ${OAuthType[type]} Token With User ${id}`);
    const valid = await isValidToken(type, id, token);
    if (!valid) {
        throw new GraphQLError("Invalid OAuth Token Provided", {
            extensions: { code: BAD_REQUEST, id, token }
        });
    }
};

const isValidToken = async (type: OAuthType, id: string, token: string) => {
    try {
        switch (type) {
            case OAuthType.APPLE:
                return await isValidAppleToken(id, token);
            case OAuthType.GOOGLE:
                return await isValidGoogleToken(id, token);
            case OAuthType.FACEBOOK:
                return await isValidFacebookToken(id, token);
        }
    } catch (err) {
        console.error(err);
        throw new GraphQLError("Failure Validating OAuth Token", {
            extensions: { code: INTERNAL_SERVER_ERROR, id, token }
        });
    }
};

const isValidAppleToken = async (id: string, token: string) => {
    const { sub } = await AppleSignIn.verifyIdToken(token, {
        audience: process.env.APPLE_CLIENT_ID
    });
    return sub === id;
};

const isValidGoogleToken = async (id: string, token: string) => {
    const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
    const ticket = await client.verifyIdToken({
        idToken: token,
        audience: process.env.GOOGLE_CLIENT_ID
    });
    return ticket.getUserId() === id;
};

const isValidFacebookToken = async (id: string, token: string): Promise<boolean> => {
    const debugTokenURL = "https://graph.facebook.com/debug_token";
    const queryParams = new URLSearchParams({
        input_token: token,
        access_token: `${process.env.FACEBOOK_CLIENT_ID}|${process.env.FACEBOOK_CLIENT_SECRET}`
    });
    const verificationURL = `${debugTokenURL}?${queryParams.toString()}`;
    console[LOG_LEVEL](`Using Verification URL ${verificationURL}`);
    const { data: facebookData }: { data: FacebookData } = await axios.get(verificationURL);
    return facebookData.data.is_valid && facebookData.data.user_id === id;
};

export const idKeyFromIdType: { [key in OAuthType]: string } = {
    [OAuthType.APPLE]: "appleId",
    [OAuthType.GOOGLE]: "googleId",
    [OAuthType.FACEBOOK]: "facebookId"
};

const oauthLogin = async (
    idFieldName: string,
    id: string,
    email?: string,
    userData?: { key: string; value: string }[]
): Promise<AuthorizationToken> => {
    const user = await getItemByIndex(USERS_TABLE, idFieldName, id);
    const oneHourFromNow = DateTime.now().plus({ hours: 1 }).toMillis().toString();
    let userId;
    if (!user) {
        if (!email || !userData) {
            const errorMessage = "Must Provide Email And UserData On Account Creation";
            console.error(`${errorMessage}. Provided email: ${email}, userData: ${userData}`);
            throw new GraphQLError(errorMessage, { extensions: { code: BAD_REQUEST, id, email } });
        }
        userId = await createNewUser(idFieldName, id, email, userData);
    } else {
        userId = user.id;
    }
    return {
        accessToken: generateToken(userId, GrantType.AUTH),
        expiryDate: oneHourFromNow,
        refreshToken: generateToken(userId, GrantType.REFRESH)
    };
};

const createNewUser = async (
    idFieldName: string,
    id: string,
    email: string,
    userData: { key: string; value: string }[]
) => {
    const userId = uuid();
    await putItem(USERS_TABLE, {
        id: userId,
        [idFieldName]: id,
        validatedInvite: false,
        email,
        ...Object.assign({}, ...userData.map((item) => ({ [item.key]: item.value })))
    });
    return userId;
};

export default oauthSignIn;
