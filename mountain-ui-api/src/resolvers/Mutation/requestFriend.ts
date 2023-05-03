import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";
import {
    DYNAMODB_TABLE_NAME_USERS,
    getItemFromDynamoDBResult,
    updateItem
} from "../../aws/dynamodb";

interface Args {
    friendId: string;
}

const requestFriend = async (_: any, args: Args, context: Context, info: any) => {
    await checkIsLoggedIn(context);
    return null;
};

export default requestFriend;
