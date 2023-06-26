import { v4 as uuid } from "uuid";
import { DateTime } from "luxon";

import { Context } from "../../index";
import { checkIsLoggedInAndHasValidToken } from "../../auth";
import { DYNAMODB_TABLE_NAME_INVITES, putItem } from "../../aws/dynamodb";

const createInviteKey = async (_: any, args: any, context: Context, info: any): Promise<string> => {
    await checkIsLoggedInAndHasValidToken(context);
    console.log(`Generating invite token for user with id ${context.userId}`);
    const inviteKey = uuid();
    const ttl = DateTime.now().toSeconds() + 60 * 60 * 24;
    await putItem(DYNAMODB_TABLE_NAME_INVITES, { id: inviteKey, ttl });
    return inviteKey;
};

export default createInviteKey;
