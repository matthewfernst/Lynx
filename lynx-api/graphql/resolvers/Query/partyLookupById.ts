import { Context } from "../../index";
import { Party } from "../../types";
import { getItem } from "../../aws/dynamodb";
import { PARTIES_TABLE } from "../../../infrastructure/lib/infrastructure";

interface Args {
    id: string;
}

const partyLookupById = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<Party | undefined> => {
    return await getItem(PARTIES_TABLE, args.id);
};

export default partyLookupById;
