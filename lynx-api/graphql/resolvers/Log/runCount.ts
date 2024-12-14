import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { ParsedLog } from "../User/logbook";

const runCount = (
    parent: ParsedLog,
    _args: Record<string, never>,
    _context: Context,
    _info: GraphQLResolveInfo
): number => {
    return parent.attributes.runCount;
};

export default runCount;
