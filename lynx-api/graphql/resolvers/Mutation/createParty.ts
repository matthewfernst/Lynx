import { v4 as uuid } from "uuid";

import { Context } from "../../index";
import { checkIsLoggedInAndHasValidInvite } from "../../auth";
import { PARTIES_TABLE, putItem } from "../../aws/dynamodb";
import { Party } from "../../types";

interface Args {
    name: string;
}

const createParty = async (_: any, args: Args, context: Context, info: any): Promise<Party> => {
    await checkIsLoggedInAndHasValidInvite(context);
    console.log(`Creating party token for user with id ${context.userId}`);
    const partyId = uuid();
    return await putItem(PARTIES_TABLE, {
        id: partyId,
        name: args.name,
        users: [context.userId]
    });
};

export default createParty;
