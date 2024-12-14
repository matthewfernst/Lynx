import { GraphQLResolveInfo } from "graphql";

import { checkIsMe } from "../../auth";
import { DefinedUserContext } from "../../index";
import { User } from "../../types";

const email = (
    parent: User,
    _args: Record<string, never>,
    context: DefinedUserContext,
    _info: GraphQLResolveInfo
) => {
    checkIsMe(parent, context, "email");
    return parent.email;
};

export default email;
