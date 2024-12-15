import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { DatabaseUser } from "../../types";

interface Args {
    id: string;
}

const userLookupById = async (
    _: unknown,
    args: Args,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<DatabaseUser | undefined> => {
    return context.dataloaders.users.load(args.id);
};

export default userLookupById;
