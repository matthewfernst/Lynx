import { v4 as uuid } from "uuid";

import { generateToken } from "../../auth";
import { Context } from "../../index";
import {
    DYNAMODB_TABLE_NAME_USERS,
    getItemFromDynamoDBResult,
    getItemsByIndex,
    putItem
} from "../../aws/dynamodb";
import { sendAccountCreatedEmail } from "../../aws/ses";
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
    };
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

const verifyAppleToken = async (id: string, token: string) => {};
const verifyGoogleToken = async (id: string, token: string) => {};

const oauthLogin = async (
    idFieldName: string,
    id: string,
    email: string | undefined,
    userData: Object
) => {
    const dynamodbResult = await getItemsByIndex(DYNAMODB_TABLE_NAME_USERS, idFieldName, id);
    const user = await getItemFromDynamoDBResult(dynamodbResult);
    let mountainAppId;
    if (user) {
        mountainAppId = generateToken(user.id.toString());
    } else {
        if (!email) {
            throw new UserInputError("Must Provide Email On Account Creation");
        }
        mountainAppId = uuid();
        await putItem(DYNAMODB_TABLE_NAME_USERS, {
            id: mountainAppId,
            [idFieldName]: id,
            email,
            ...userData
        });
        console.log(`Sending Account Created Email to ${email}`);
        await sendAccountCreatedEmail(email);
    }

    return generateToken(mountainAppId);
};

export default createUserOrSignIn;
