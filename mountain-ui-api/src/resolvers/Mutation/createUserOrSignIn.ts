import { v4 as uuid } from "uuid";
import AppleSignIn from "apple-signin-auth";
import { OAuth2Client } from "google-auth-library";

import { generateToken } from "../../auth";
import { Context } from "../../index";
import {
    DYNAMODB_TABLE_NAME_USERS,
    getItemFromDynamoDBResult,
    getItemsByIndex,
    putItem
} from "../../aws/dynamodb";
import { UserInputError } from "apollo-server-lambda";

type LoginType = "APPLE" | "GOOGLE";

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

const createUserOrSignIn = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<string> => {
    switch (args.type) {
        case "APPLE":
            await verifyAppleToken(args.id, args.token);
            return await oauthLogin("appleId", args.id, args.email, args.userData);
        case "GOOGLE":
            await verifyGoogleToken(args.id, args.token);
            return await oauthLogin("googleId", args.id, args.email, args.userData);
    }
};

const verifyAppleToken = async (id: string, token: string) => {
    const { sub } = await AppleSignIn.verifyIdToken(token, {
        audience: process.env.APPLE_CLIENT_ID,
        ignoreExpiration: true
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
) => {
    const dynamodbResult = await getItemsByIndex(DYNAMODB_TABLE_NAME_USERS, idFieldName, id);
    const user = await getItemFromDynamoDBResult(dynamodbResult);
    if (user) {
        return generateToken(user.id);
    } else {
        if (!email || !userData) {
            throw new UserInputError("Must Provide Email And UserData On Account Creation");
        }
        const mountainAppId = uuid();
        await putItem(DYNAMODB_TABLE_NAME_USERS, {
            id: mountainAppId,
            [idFieldName]: id,
            email,
            ...Object.assign({}, ...userData.map((item) => ({ [item.key]: item.value })))
        });
        return generateToken(mountainAppId);
    }
};

export default createUserOrSignIn;
