import axios from "axios";

import { checkHasUserId, checkIsValidUserAndHasValidInvite } from "../../auth";
import { deleteItem } from "../../aws/dynamodb";
import { deleteObjectsInBucket } from "../../aws/s3";
import { OAuthType } from "./createUserOrSignIn";
import { Context } from "../../index";
import { User } from "../../types";
import {
    USERS_TABLE,
    PROFILE_PICS_BUCKET,
    SLOPES_UNZIPPED_BUCKET
} from "../../../infrastructure/lib/infrastructure";

interface Args {
    options?: {
        tokensToInvalidate?: {
            token: string;
            type: OAuthType;
        }[];
    };
}

const deleteUser = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    if (args.options?.tokensToInvalidate) {
        args.options.tokensToInvalidate.forEach(
            async (token) => await invalidateToken(token.type, token.token)
        );
    }
    console.log(`Deleting user with id ${context.userId}`);
    await deleteObjectsInBucket(PROFILE_PICS_BUCKET, context.userId);
    await deleteObjectsInBucket(SLOPES_UNZIPPED_BUCKET, context.userId);
    return await deleteItem(USERS_TABLE, context.userId);
};

const invalidateToken = async (tokenType: OAuthType, token: string) => {
    switch (tokenType) {
        case "APPLE":
            return await invalidateAppleToken(token);
    }
};

const invalidateAppleToken = async (token: string) => {
    const invalidateTokenData = {
        client_id: process.env.APPLE_CLIENT_ID,
        client_secret: process.env.APPLE_CLIENT_SECRET,
        token: token
    };
    return await axios.post("https://appleid.apple.com/auth/revoke", invalidateTokenData);
};

export default deleteUser;
