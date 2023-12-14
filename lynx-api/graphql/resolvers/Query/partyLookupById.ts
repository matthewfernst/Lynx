import { Context } from "../../index";
import { Party, User } from "../../types";
import { PARTIES_TABLE, getItem } from "../../aws/dynamodb";

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
