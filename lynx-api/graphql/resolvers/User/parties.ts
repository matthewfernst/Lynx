import { Context } from "../../index";
import { Party } from "../../types";

interface Parent {
    parties: string[];
}

const parties = async (
    parent: Parent,
    args: any,
    context: Context,
    info: any
): Promise<Party[]> => {
    return (await context.dataloaders.parties.loadMany(parent.parties)) as Party[];
};

export default parties;
