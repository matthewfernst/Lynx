import { GraphQLResolveInfo } from "graphql";

import { getItemByIndex } from "../../aws/dynamodb";
import { USERS_TABLE } from "../../../infrastructure/stacks/lynxApiStack";
import { Context } from "../../index";
import { DatabaseUser } from "../../types";

interface Args {
  email: string;
}

const userLookupByEmail = async (
  _: unknown,
  args: Args,
  context: Context,
  _info: GraphQLResolveInfo,
): Promise<DatabaseUser | undefined> => {
  const partialUser = await getItemByIndex(USERS_TABLE, "email", args.email);
  if (!partialUser) {
    return undefined;
  }
  return context.dataloaders.users.load(partialUser.id);
};

export default userLookupByEmail;
