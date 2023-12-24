import { getItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { Party } from "../../types";
import { PARTIES_TABLE } from "../../../infrastructure/lib/infrastructure";

interface Parent {
    parties: string[];
}

const parties = async (
    parent: Parent,
    args: any,
    context: Context,
    info: any
): Promise<Party[]> => {
    return await Promise.all(
        parent.parties.map(async (party) => (await getItem(PARTIES_TABLE, party)) as Party)
    );
};

export default parties;
