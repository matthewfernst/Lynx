import { ApolloServerErrorCode } from "@apollo/server/errors";
import { GraphQLError, GraphQLResolveInfo } from "graphql";

import { checkHasUserId, checkIsValidUser } from "../../auth";
import { deleteItem, getItem, updateItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { DatabaseUser } from "../../types";
import { INVITES_TABLE, USERS_TABLE } from "../../../infrastructure/stacks/lynxApiStack";

interface Args {
    inviteKey: string;
}

const resolveInviteKey = async (
    _: unknown,
    args: Args,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<DatabaseUser> => {
    checkHasUserId(context);
    await checkIsValidUser(context);
    const inviteInfo = await getItem(INVITES_TABLE, args.inviteKey);
    const usingEscapeHatch = args.inviteKey === process.env.ESCAPE_INVITE_HATCH;
    if (!inviteInfo && !usingEscapeHatch) {
        throw new GraphQLError("Invalid Invite Token Provided", {
            extensions: { code: ApolloServerErrorCode.BAD_REQUEST, inviteKey: args.inviteKey }
        });
    }
    const updateOutput = await updateItem(USERS_TABLE, context.userId, "validatedInvite", true);
    if (!usingEscapeHatch) await deleteItem(INVITES_TABLE, args.inviteKey);
    return updateOutput;
};

export default resolveInviteKey;
