import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { ParsedLog } from "../../types";

const endDate = (
  parent: ParsedLog,
  _args: Record<string, never>,
  _context: Context,
  _info: GraphQLResolveInfo,
) => {
  return parent.attributes.end;
};

export default endDate;
