import { DateTime } from "luxon";

import { Context } from "../../index";
import { LOG_LEVEL } from "../../types";
import { checkHasUserId, checkIsValidUserAndHasValidInvite } from "../../auth";
import { putItem } from "../../aws/dynamodb";
import { INVITES_TABLE } from "../../../infrastructure/stacks/lynxApiStack";

const createInviteKey = async (_: any, args: any, context: Context, info: any): Promise<string> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    console[LOG_LEVEL](`Generating invite token for user with id ${context.userId}`);
    const inviteKey = Math.random().toString(10).substring(2, 8);
    await putItem(INVITES_TABLE, { id: inviteKey, ttl: DateTime.now().toSeconds() + 60 * 60 * 24 });
    return inviteKey;
};

export default createInviteKey;
