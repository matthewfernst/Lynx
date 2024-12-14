import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { ParsedLog, ParsedLogDetails } from "../User/logbook";

const details = (
    parent: ParsedLog,
    _args: Record<string, never>,
    _context: Context,
    _info: GraphQLResolveInfo
): ParsedLogDetails[] => {
    return parent.actions.flatMap((action) => action.action);
};

export default details;
