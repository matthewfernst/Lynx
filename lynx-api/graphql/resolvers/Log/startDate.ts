import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { ParsedLog } from "../User/logbook";

const startDate = (
    parent: ParsedLog,
    _args: Record<string, never>,
    _context: Context,
    _info: GraphQLResolveInfo
) => {
    return parent.attributes.start;
};

export default startDate;
