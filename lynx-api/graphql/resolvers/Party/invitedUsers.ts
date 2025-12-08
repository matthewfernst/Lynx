import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { Party, DatabaseUser } from "../../types";

const invitedUsers = async (
  parent: Party,
  _args: Record<string, never>,
  context: Context,
  _info: GraphQLResolveInfo,
): Promise<DatabaseUser[]> => {
  return (await context.dataloaders.users.loadMany(
    parent.invitedUsers ?? [],
  )) as DatabaseUser[];
};

export default invitedUsers;
