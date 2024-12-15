import { GraphQLResolveInfo } from "graphql";
import { DateTime } from "luxon";

import { INVITES_TABLE } from "../../../infrastructure/stacks/lynxApiStack";

import { Context } from "../../index";
import { checkHasUserId, checkIsValidUserAndHasValidInvite } from "../../auth";
import { putItem } from "../../aws/dynamodb";

const createInviteKey = async (
    _: unknown,
    _args: Record<string, never>,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<string> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    console.info(`Generating invite token for user with id ${context.userId}`);
    const inviteKey = Math.random().toString(10).substring(2, 8);
    await putItem(INVITES_TABLE, { id: inviteKey, ttl: DateTime.now().toSeconds() + 60 * 60 * 24 });
    return inviteKey;
};

export default createInviteKey;
