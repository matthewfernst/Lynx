import { GraphQLResolveInfo } from "graphql";

import { checkHasUserId, checkIsValidUser } from "../../auth";
import { updateItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { DatabaseUser } from "../../types";
import { USERS_TABLE } from "../../../infrastructure/stacks/lynxApiStack";

interface Args {
  userData: {
    key: string;
    value: string;
  }[];
}

const editUser = async (
  _: unknown,
  args: Args,
  context: Context,
  _info: GraphQLResolveInfo,
): Promise<DatabaseUser> => {
  checkHasUserId(context);
  await checkIsValidUser(context);
  for (const data of args.userData) {
    await updateItem(USERS_TABLE, context.userId, data.key, data.value);
  }
  return (await context.dataloaders.users.load(context.userId)) as DatabaseUser;
};

export default editUser;
