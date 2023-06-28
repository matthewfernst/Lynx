import { v4 as uuid } from "uuid";
import { DateTime } from "luxon";
import AppleSignIn from "apple-signin-auth";
import { OAuth2Client } from "google-auth-library";
import { UserInputError } from "apollo-server-lambda";

import { generateToken } from "../../auth";
import { Context } from "../../index";
import {
    DYNAMODB_TABLE_USERS,
    getItemFromDynamoDBResult,
    getItemsByIndex,
    putItem
} from "../../aws/dynamodb";
import { User } from "../../types";

export type LoginType = "APPLE" | "GOOGLE";

interface Args {
    type: LoginType;
    id: string;
    token: string;
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
    switch (args.type) {
        case "APPLE":
            await verifyAppleToken(args.id, args.token);
        case "GOOGLE":
            await verifyGoogleToken(args.id, args.token);
    }
    return await oauthLogin(idKeyFromIdType(args.type), args.id, args.email, args.userData);
};

export const idKeyFromIdType = (idType: LoginType) => {
    switch (idType) {
        case "APPLE":
            return "appleId";
        case "GOOGLE":
            return "googleId";
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
            throw new UserInputError("Must Provide Email And UserData On Account Creation");
        }
        const mountainAppId = uuid();
        const validatedInvite = false;
        await putItem(DYNAMODB_TABLE_USERS, {
            id: mountainAppId,
            [idFieldName]: id,
            validatedInvite,
            email,
            ...Object.assign({}, ...userData.map((item) => ({ [item.key]: item.value })))
        });
        return {
            token: generateToken(mountainAppId),
            expiryDate: oneHourFromNow,
            validatedInvite
        };
    }
};

export default createUserOrSignIn;
