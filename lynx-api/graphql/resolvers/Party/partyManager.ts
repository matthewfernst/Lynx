import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { Party, User } from "../../types";

const partyManager = async (
    parent: Party,
    _args: Record<string, never>,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<User> => {
    return (await context.dataloaders.users.load(parent.partyManager)) as User;
};

export default partyManager;
