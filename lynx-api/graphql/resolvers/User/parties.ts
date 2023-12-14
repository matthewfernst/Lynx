import { PARTIES_TABLE, getItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { Party } from "../../types";

interface Parent {
    id: string;
    parties: string[];
}

const parties = async (
    parent: Parent,
    args: any,
    context: Context,
    info: any
): Promise<Party[]> => {
    return Promise.all(
        parent.parties.map(async (party) => (await getItem(PARTIES_TABLE, party)) as Party)
    );
};

export default parties;
