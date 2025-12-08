import { GraphQLResolveInfo } from "graphql";

import { checkIsMe } from "../../auth";
import { DefinedUserContext } from "../../index";
import { DatabaseUser } from "../../types";

const email = (
  parent: DatabaseUser,
  _args: Record<string, never>,
  context: DefinedUserContext,
  _info: GraphQLResolveInfo,
) => {
  checkIsMe(parent, context, "email");
  return parent.email;
};

export default email;
