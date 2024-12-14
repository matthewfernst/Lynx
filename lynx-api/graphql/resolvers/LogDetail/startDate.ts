import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { ParsedLogDetails } from "../User/logbook";

const startDate = (
    parent: ParsedLogDetails,
    _args: Record<string, never>,
    _context: Context,
    _info: GraphQLResolveInfo
) => {
    return parent.attributes.start;
};

export default startDate;
