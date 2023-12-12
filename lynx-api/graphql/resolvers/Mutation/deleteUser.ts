import axios from "axios";

import { Context } from "../../index";
import { checkIsLoggedInAndHasValidInvite } from "../../auth";
import { USERS_TABLE, deleteItem } from "../../aws/dynamodb";
import { deleteObjectsInBucket, profilePictureBucketName, toRunRecordsBucket } from "../../aws/s3";
import { User } from "../../types";
import { OAuthType } from "./createUserOrSignIn";

interface Args {
    options?: {
        tokensToInvalidate?: {
            token: string;
            type: OAuthType;
        }[];
    };
}

const deleteUser = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    await checkIsLoggedInAndHasValidInvite(context);
    if (args.options?.tokensToInvalidate) {
        args.options.tokensToInvalidate.forEach(
            async (token) => await invalidateToken(token.type, token.token)
        );
    }
    await deleteObjectsInBucket(profilePictureBucketName, context.userId as string);
    await deleteObjectsInBucket(toRunRecordsBucket, context.userId as string);
    const result = await deleteItem(USERS_TABLE, context.userId as string);
    return result.Attributes as unknown as User;
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
