import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";
import { DYNAMODB_TABLE_NAME_USERS, deleteItem } from "../../aws/dynamodb";

const deleteUser = async (_: any, args: {}, context: Context, info: any) => {
    await checkIsLoggedIn(context);
    const result = await deleteItem(DYNAMODB_TABLE_NAME_USERS, context.userId as string);
    return result.Attributes;
};

export default deleteUser;
