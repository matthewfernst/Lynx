import { GraphQLError } from "graphql";

import { checkHasUserId, checkIsValidUser } from "../../auth";
import { deleteItem, getItem, updateItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { BAD_REQUEST, User } from "../../types";
import { INVITES_TABLE, USERS_TABLE } from "../../../infrastructure/lib/infrastructure";

interface Args {
    inviteKey: string;
}

const resolveInviteKey = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    checkHasUserId(context);
    await checkIsValidUser(context);
    const inviteInfo = await getItem(INVITES_TABLE, args.inviteKey);
    if (!inviteInfo && args.inviteKey !== process.env.ESCAPE_INVITE_HATCH) {
        throw new GraphQLError("Invalid Invite Token Provided", {
            extensions: { code: BAD_REQUEST, inviteKey: args.inviteKey }
        });
    }
    const updateOutput = await updateItem(USERS_TABLE, context.userId, "validatedInvite", true);
    await deleteItem(INVITES_TABLE, args.inviteKey);
    return updateOutput;
};

export default resolveInviteKey;
