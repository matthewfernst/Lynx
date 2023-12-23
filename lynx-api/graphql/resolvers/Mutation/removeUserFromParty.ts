import {
    checkHasUserId,
    checkIsLoggedInAndHasValidInvite,
    checkIsPartyOwner,
    checkIsValidUser
} from "../../auth";
import { deleteItemsFromArray } from "../../aws/dynamodb";
import { Context } from "../../index";
import { Party } from "../../types";
import { PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/lib/infrastructure";

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
    const userId = checkHasUserId(context.userId);
    await checkIsLoggedInAndHasValidInvite(userId);
    await checkIsPartyOwner(userId, args.partyId);
    await checkIsValidUser(args.userId);

    console.log(`Deleting party membership for user with id ${args.userId}`);
    await deleteItemsFromArray(USERS_TABLE, args.userId, "parties", [args.partyId]);
    return (await deleteItemsFromArray(PARTIES_TABLE, args.partyId, "users", [
        args.userId
    ])) as Party;
};

export default removeUserFromParty;
