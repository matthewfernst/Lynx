import { GraphQLError } from "graphql";

import { Context } from "../../index";
import { BAD_REQUEST, checkHasUserId, checkIsLoggedIn } from "../../auth";
import { INVITES_TABLE, USERS_TABLE, deleteItem, getItem, updateItem } from "../../aws/dynamodb";
import { User } from "../../types";

interface Args {
    inviteKey: string;
}

const resolveInviteKey = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    const userId = checkHasUserId(context.userId);
    await checkIsLoggedIn(userId);
    const inviteInfo = await getItem(INVITES_TABLE, args.inviteKey);
    if (!inviteInfo && args.inviteKey !== process.env.ESCAPE_INVITE_HATCH) {
        throw new GraphQLError("Invalid Invite Token Provided", {
            extensions: { code: BAD_REQUEST }
        });
    }
    const updateOutput = (await updateItem(USERS_TABLE, userId, "validatedInvite", true)) as User;
    await deleteItem(INVITES_TABLE, args.inviteKey);
    return updateOutput;
};

export default resolveInviteKey;
