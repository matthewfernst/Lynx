import { GraphQLResolveInfo } from "graphql";

import { DefinedUserContext } from "../../index";
import { Party, DatabaseUser } from "../../types";

const parties = async (
    parent: DatabaseUser,
    _args: Record<string, never>,
    context: DefinedUserContext,
    _info: GraphQLResolveInfo
): Promise<Party[]> => {
    return (await context.dataloaders.parties.loadMany(parent.parties)) as Party[];
};

export default parties;
