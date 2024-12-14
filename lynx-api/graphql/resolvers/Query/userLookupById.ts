import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { User } from "../../types";

interface Args {
    id: string;
}

const userLookupById = async (
    _: unknown,
    args: Args,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<User | undefined> => {
    return context.dataloaders.users.load(args.id);
};

export default userLookupById;
