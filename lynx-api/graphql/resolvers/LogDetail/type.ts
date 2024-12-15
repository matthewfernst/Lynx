import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { ParsedLogDetails } from "../../types";

const type = (
    parent: ParsedLogDetails,
    _args: Record<string, never>,
    _context: Context,
    _info: GraphQLResolveInfo
) => {
    return parent.attributes.type.toUpperCase();
};

export default type;
