import {
    checkHasUserId,
    checkIsValidUserAndHasValidInvite,
    checkIsValidPartyAndIsPartyOwner
} from "../../auth";
import { deleteItem, deleteItemsFromArray } from "../../aws/dynamodb";
import { Context } from "../../index";
import { Party, LOG_LEVEL } from "../../types";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/stacks/lynxApiStack";

interface Args {
    partyId: string;
}

const deleteParty = async (_: any, args: Args, context: Context, info: any): Promise<Party> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    await checkIsValidPartyAndIsPartyOwner(context, args.partyId);

    console[LOG_LEVEL](`Deleting party with id ${args.partyId}`);
    await deleteItemsFromArray(USERS_TABLE, context.userId, "parties", [args.partyId]);
    return await deleteItem(PARTIES_TABLE, args.partyId);
};

export default deleteParty;
