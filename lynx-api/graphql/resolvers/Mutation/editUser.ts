import { checkHasUserId, checkIsLoggedInAndHasValidInvite } from "../../auth";
import { getItem, updateItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { User } from "../../types";
import { USERS_TABLE } from "../../../infrastructure/lib/infrastructure";

interface Args {
    userData: {
        key: string;
        value: string;
    }[];
}

const editUser = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    const userId = checkHasUserId(context.userId);
    await checkIsLoggedInAndHasValidInvite(userId);
    for (const data of args.userData) {
        await updateItem(USERS_TABLE, userId, data.key, data.value);
    }
    return (await getItem(USERS_TABLE, userId)) as User;
};

export default editUser;
