import {
    checkHasUserId,
    checkIsValidUserAndHasValidInvite,
    checkIsValidPartyAndIsPartyOwner
} from "../../auth";
import { deleteItemsFromArray } from "../../aws/dynamodb";
import { Context, LOG_LEVEL } from "../../index";
import { Party } from "../../types";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/lynxStack";

interface Args {
    partyId: string;
    userId: string;
}

const removeUserFromParty = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<Party> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    await checkIsValidPartyAndIsPartyOwner(context, args.partyId);

    console[LOG_LEVEL](`Deleting party membership for user with id ${args.userId}`);
    await deleteItemsFromArray(USERS_TABLE, args.userId, "parties", [args.partyId]);
    return (await deleteItemsFromArray(PARTIES_TABLE, args.partyId, "users", [
        args.userId
    ])) as Party;
};

export default removeUserFromParty;
