import { GraphQLResolveInfo } from "graphql";

import { DefinedUserContext } from "../../index";
import { Party, User } from "../../types";

const parties = async (
    parent: User,
    _args: Record<string, never>,
    context: DefinedUserContext,
    _info: GraphQLResolveInfo
): Promise<Party[]> => {
    return (await context.dataloaders.parties.loadMany(parent.parties)) as Party[];
};

export default parties;
