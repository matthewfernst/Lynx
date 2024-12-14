import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { User } from "../../types";
import { checkHasUserId } from "../../auth";

const selfLookup = async (
    _: unknown,
    _args: Record<string, never>,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<User | undefined> => {
    checkHasUserId(context);
    return context.dataloaders.users.load(context.userId);
};

export default selfLookup;
