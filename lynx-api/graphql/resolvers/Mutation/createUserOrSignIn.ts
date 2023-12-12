import AppleSignIn from "apple-signin-auth";
import { OAuth2Client } from "google-auth-library";
import { GraphQLError } from "graphql";
import { DateTime } from "luxon";
import { v4 as uuid } from "uuid";

import { BAD_REQUEST, generateToken } from "../../auth";
import { Context } from "../../index";
import {
    DYNAMODB_TABLE_USERS,
    getItemFromDynamoDBResult,
    getItemsByIndex,
    putItem
} from "../../aws/dynamodb";
import { User } from "../../types";

export type OAuthType = "APPLE" | "GOOGLE";

interface Args {
    oauthLoginId: {
        type: OAuthType;
        id: string;
        token?: string;
    };
    email?: string;
    userData: {
        key: string;
        value: string;
    }[];
}

interface AuthorizationToken {
    token: string;
    expiryDate: string;
    validatedInvite: boolean;
}

const createUserOrSignIn = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<AuthorizationToken> => {
    const { type, id, token } = args.oauthLoginId;
    if (!token) {
        throw new GraphQLError("Token Is Mandatory", {
            extensions: { code: BAD_REQUEST }
        });
    }
    await verifyToken(type, id, token);
    return await oauthLogin(idKeyFromIdType(type), id, args.email, args.userData);
};

export const verifyToken = async (type: OAuthType, id: string, token: string) => {
    switch (type) {
        case "APPLE":
            return await verifyAppleToken(id, token);
        case "GOOGLE":
            return await verifyGoogleToken(id, token);
    }
};

const verifyAppleToken = async (id: string, token: string) => {
    const { sub } = await AppleSignIn.verifyIdToken(token, {
        audience: process.env.APPLE_CLIENT_ID
    });
    return sub === id;
};

const verifyGoogleToken = async (id: string, token: string) => {
    const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);
    const ticket = await client.verifyIdToken({
        idToken: token,
        audience: process.env.GOOGLE_CLIENT_ID
    });
    return ticket.getUserId() === id;
};

export const idKeyFromIdType = (idType: OAuthType) => {
    switch (idType) {
        case "APPLE":
            return "appleId";
        case "GOOGLE":
            return "googleId";
    }
};

const oauthLogin = async (
    idFieldName: string,
    id: string,
    email?: string,
    userData?: { key: string; value: string }[]
): Promise<AuthorizationToken> => {
    const dynamodbResult = await getItemsByIndex(DYNAMODB_TABLE_USERS, idFieldName, id);
    const user = (await getItemFromDynamoDBResult(dynamodbResult)) as User | null;
    const oneHourFromNow = DateTime.now().plus({ hours: 1 }).toMillis().toString();
    if (user) {
        return {
            token: generateToken(user.id),
            expiryDate: oneHourFromNow,
            validatedInvite: user.validatedInvite
        };
    } else {
        if (!email || !userData) {
            throw new GraphQLError("Must Provide Email And UserData On Account Creation", {
                extensions: { code: BAD_REQUEST }
            });
        }
        const lynxAppId = uuid();
        const validatedInvite = false;
        await putItem(DYNAMODB_TABLE_USERS, {
            id: lynxAppId,
            [idFieldName]: id,
            validatedInvite,
            email,
            ...Object.assign({}, ...userData.map((item) => ({ [item.key]: item.value })))
        });
        return {
            token: generateToken(lynxAppId),
            expiryDate: oneHourFromNow,
            validatedInvite
        };
    }
};

export default createUserOrSignIn;
