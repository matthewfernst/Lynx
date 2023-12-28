import { v4 as uuid } from "uuid";

import { checkHasUserId, checkIsValidUserAndHasValidInvite } from "../../auth";
import { addItemsToArray, putItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { Party } from "../../types";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/lib/infrastructure";

interface Args {
    name: string;
}

const createParty = async (_: any, args: Args, context: Context, info: any): Promise<Party> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    console.log(`Creating party token for user with id ${context.userId}`);
    const partyId = uuid();
    const party = await putItem(PARTIES_TABLE, {
        id: partyId,
        name: args.name,
        partyManager: context.userId,
        users: [context.userId]
    });
    await addItemsToArray(USERS_TABLE, context.userId, "parties", [partyId]);
    return party;
};

export default createParty;
