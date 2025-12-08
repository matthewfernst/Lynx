import { GraphQLResolveInfo } from "graphql";

import { DefinedUserContext } from "../../index";
import { Party, DatabaseUser } from "../../types";

const partyInvites = async (
  parent: DatabaseUser,
  _args: Record<string, never>,
  context: DefinedUserContext,
  _info: GraphQLResolveInfo,
): Promise<Party[]> => {
  return (await context.dataloaders.parties.loadMany(
    parent.partyInvites ?? [],
  )) as Party[];
};

export default partyInvites;
