import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";
import {
    DYNAMODB_TABLE_NAME_USERS,
    addItemsToArray,
    getItem,
    getItemFromDynamoDBResult,
    updateItem
} from "../../aws/dynamodb";
import { User } from "../../types";

interface Args {
    friendId: string;
}

const requestFriend = async (_: any, args: Args, context: Context, info: any): Promise<User> => {
    await checkIsLoggedIn(context);
    const queryOutput = await getItem(DYNAMODB_TABLE_NAME_USERS, args.friendId);
    if (!getItemFromDynamoDBResult(queryOutput)) {
        throw new Error("Provided friendId does not exist as a User");
    }
    await addItemsToArray(DYNAMODB_TABLE_NAME_USERS, args.friendId, "incomingFriendRequests", [
        context.userId as string
    ]);
    const result = await addItemsToArray(
        DYNAMODB_TABLE_NAME_USERS,
        context.userId as string,
        "outgoingFriendRequests",
        [args.friendId]
    );
    return getItemFromDynamoDBResult(result) as User;
};

export default requestFriend;
