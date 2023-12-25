import { Context } from "../../index";
import { Party } from "../../types";

interface Args {
    id: string;
}

const partyLookupById = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<Party | undefined> => {
    return await context.dataloaders.parties.load(args.id);
};

export default partyLookupById;
