import { GraphQLResolveInfo } from "graphql";
import { Context } from "../../index";
import { Party } from "../../types";

export type Args = {
  id: string;
};

const partyLookupById = async (
  _: unknown,
  args: Args,
  context: Context,
  _info: GraphQLResolveInfo,
): Promise<Party | undefined> => {
  return context.dataloaders.parties.load(args.id);
};

export default partyLookupById;
