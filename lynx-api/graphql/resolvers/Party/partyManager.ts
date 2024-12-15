import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { Party, DatabaseUser } from "../../types";

const partyManager = async (
    parent: Party,
    _args: Record<string, never>,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<DatabaseUser> => {
    return (await context.dataloaders.users.load(parent.partyManager)) as DatabaseUser;
};

export default partyManager;
