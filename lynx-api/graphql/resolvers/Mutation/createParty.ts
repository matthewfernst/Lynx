import { v4 as uuid } from "uuid";

import { checkHasUserId, checkIsLoggedInAndHasValidInvite } from "../../auth";
import { addItemsToArray, putItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { Party } from "../../types";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/lib/infrastructure";

interface Args {
    name: string;
}

const createParty = async (_: any, args: Args, context: Context, info: any): Promise<Party> => {
    const userId = checkHasUserId(context.userId);
    await checkIsLoggedInAndHasValidInvite(userId);
    console.log(`Creating party token for user with id ${userId}`);
    const partyId = uuid();
    const party = await putItem(PARTIES_TABLE, {
        id: partyId,
        name: args.name,
        users: [userId]
    });
    await addItemsToArray(USERS_TABLE, userId, "parties", [partyId]);
    return party;
};

export default createParty;
