import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { Party, DatabaseUser } from "../../types";

const users = async (
    parent: Party,
    _args: Record<string, never>,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<DatabaseUser[]> => {
    return Promise.all(
        parent.users.map(async (userId) => (await context.dataloaders.users.load(userId)) as DatabaseUser)
    );
};

export default users;
