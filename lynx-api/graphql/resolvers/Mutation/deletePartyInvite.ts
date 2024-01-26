import {
    checkHasUserId,
    checkIsValidUserAndHasValidInvite,
    checkIsValidPartyAndIsPartyOwner
} from "../../auth";
import { deleteItemsFromArray } from "../../aws/dynamodb";
import { Context } from "../../index";
import { Party, LOG_LEVEL } from "../../types";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/lynxStack";

interface Args {
    partyId: string;
    userId: string;
}

const deletePartyInvite = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<Party> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    await checkIsValidPartyAndIsPartyOwner(context, args.partyId);

    console[LOG_LEVEL](`Deleting party invite for user with id ${args.userId}`);
    await deleteItemsFromArray(USERS_TABLE, args.userId, "partyInvites", [args.partyId]);
    return (await deleteItemsFromArray(PARTIES_TABLE, args.partyId, "invitedUsers", [
        args.userId
    ])) as Party;
};

export default deletePartyInvite;
