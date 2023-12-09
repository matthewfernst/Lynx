import { UserInputError } from "apollo-server-lambda";

import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";
import {
    DYNAMODB_TABLE_INVITES,
    DYNAMODB_TABLE_USERS,
    deleteItem,
    getItem,
    getItemFromDynamoDBResult,
    updateItem
} from "../../aws/dynamodb";
import { Invite, User } from "../../types";

interface Args {
    inviteKey: string;
}

const resolveInviteKey = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    await checkIsLoggedIn(context);
    const queryOutput = await getItem(DYNAMODB_TABLE_INVITES, args.inviteKey);
    const inviteInfo = (await getItemFromDynamoDBResult(queryOutput)) as Invite | null;
    if (!inviteInfo && args.inviteKey !== process.env.ESCAPE_INVITE_HATCH) {
        throw new UserInputError("Invalid Invite Token Provided");
    }
    const updateOutput = await updateItem(
        DYNAMODB_TABLE_USERS,
        context.userId as string,
        "validatedInvite",
        true
    );
    await deleteItem(DYNAMODB_TABLE_INVITES, args.inviteKey);
    return getItemFromDynamoDBResult(updateOutput) as User;
};

export default resolveInviteKey;
