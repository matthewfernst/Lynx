import { GraphQLError } from "graphql";

import { Context } from "../../index";
import { BAD_REQUEST, checkIsLoggedIn } from "../../auth";
import { INVITES_TABLE, USERS_TABLE, deleteItem, getItem, updateItem } from "../../aws/dynamodb";
import { Invite, User } from "../../types";

interface Args {
    inviteKey: string;
}

const resolveInviteKey = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    await checkIsLoggedIn(context);
    const inviteInfo = await getItem(INVITES_TABLE, args.inviteKey);
    if (!inviteInfo && args.inviteKey !== process.env.ESCAPE_INVITE_HATCH) {
        throw new GraphQLError("Invalid Invite Token Provided", {
            extensions: { code: BAD_REQUEST }
        });
    }
    const updateOutput = (await updateItem(
        USERS_TABLE,
        context.userId as string,
        "validatedInvite",
        true
    )) as User;
    await deleteItem(INVITES_TABLE, args.inviteKey);
    return updateOutput;
};

export default resolveInviteKey;
