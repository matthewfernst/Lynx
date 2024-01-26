import { DateTime } from "luxon";

import { Context, logLevel } from "../../index";
import { checkHasUserId, checkIsValidUserAndHasValidInvite } from "../../auth";
import { putItem } from "../../aws/dynamodb";
import { INVITES_TABLE } from "../../../infrastructure/lynxStack";

const createInviteKey = async (_: any, args: any, context: Context, info: any): Promise<string> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    console[logLevel](`Generating invite token for user with id ${context.userId}`);
    const inviteKey = Math.random().toString(10).substring(2, 8);
    await putItem(INVITES_TABLE, { id: inviteKey, ttl: DateTime.now().toSeconds() + 60 * 60 * 24 });
    return inviteKey;
};

export default createInviteKey;
