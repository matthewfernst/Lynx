import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { ParsedLog } from "../../types";

const locationName = (
  parent: ParsedLog,
  _args: Record<string, never>,
  _context: Context,
  _info: GraphQLResolveInfo,
): string => {
  return parent.attributes.locationName;
};

export default locationName;
