import { checkHasUserId, checkIsLoggedInAndHasValidInvite, checkIsPartyOwner } from "../../auth";
import { deleteItem, deleteItemsFromArray } from "../../aws/dynamodb";
import { Context } from "../../index";
import { Party } from "../../types";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/lib/infrastructure";

interface Args {
    partyId: string;
}

const deleteParty = async (_: any, args: Args, context: Context, info: any): Promise<Party> => {
    const userId = checkHasUserId(context.userId);
    await checkIsLoggedInAndHasValidInvite(userId);
    await checkIsPartyOwner(userId, args.partyId);

    console.log(`Deleting party with id ${args.partyId}`);
    await deleteItemsFromArray(USERS_TABLE, userId, "parties", [args.partyId]);
    return (await deleteItem(PARTIES_TABLE, args.partyId)) as Party;
};

export default deleteParty;
