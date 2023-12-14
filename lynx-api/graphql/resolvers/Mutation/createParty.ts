import { v4 as uuid } from "uuid";

import { Context } from "../../index";
import { checkIsLoggedInAndHasValidInvite } from "../../auth";
import { PARTIES_TABLE, USERS_TABLE, addItemsToArray, putItem } from "../../aws/dynamodb";
import { Party } from "../../types";

interface Args {
    name: string;
}

const createParty = async (_: any, args: Args, context: Context, info: any): Promise<Party> => {
    await checkIsLoggedInAndHasValidInvite(context);
    console.log(`Creating party token for user with id ${context.userId}`);
    const partyId = uuid();
    const party = await putItem(PARTIES_TABLE, {
        id: partyId,
        name: args.name,
        users: [context.userId]
    });
    await addItemsToArray(USERS_TABLE, context.userId as string, "parties", [partyId]);
    return party;
};

export default createParty;
