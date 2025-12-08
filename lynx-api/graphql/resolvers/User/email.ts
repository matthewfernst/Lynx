import { GraphQLResolveInfo, responsePathAsArray } from "graphql";

import { checkIsMe } from "../../auth";
import { DefinedUserContext } from "../../index";
import { DatabaseUser } from "../../types";

const email = (
  parent: DatabaseUser,
  _args: Record<string, never>,
  context: DefinedUserContext,
  info: GraphQLResolveInfo,
) => {
  const pathArray = responsePathAsArray(info.path);
  const entrypoint = pathArray.length > 0 ? String(pathArray[0]) : "";

  if (entrypoint !== "userLookupByEmail") {
    checkIsMe(parent, context, "email");
  }

  return parent.email;
};

export default email;
