import { GraphQLError } from "graphql";

import { checkHasUserId, checkIsLoggedIn } from "../../auth";
import { deleteItem, getItem, updateItem } from "../../aws/dynamodb";
import { BAD_REQUEST, Context } from "../../index";
import { User } from "../../types";
import { INVITES_TABLE, USERS_TABLE } from "../../../infrastructure/lib/infrastructure";

interface Args {
    inviteKey: string;
}

const resolveInviteKey = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    const userId = checkHasUserId(context.userId);
    await checkIsLoggedIn(userId);
    const inviteInfo = await getItem(INVITES_TABLE, args.inviteKey);
    if (!inviteInfo && args.inviteKey !== process.env.ESCAPE_INVITE_HATCH) {
        throw new GraphQLError("Invalid Invite Token Provided", {
            extensions: { code: BAD_REQUEST, inviteKey: args.inviteKey }
        });
    }
    const updateOutput = (await updateItem(USERS_TABLE, userId, "validatedInvite", true)) as User;
    await deleteItem(INVITES_TABLE, args.inviteKey);
    return updateOutput;
};

export default resolveInviteKey;
