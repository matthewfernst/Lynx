import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";
import {
    DYNAMODB_TABLE_NAME_USERS,
    addItemsToArray,
    deleteItemsFromArray,
    getItem,
    getItemFromDynamoDBResult,
    updateItem
} from "../../aws/dynamodb";
import { User } from "../../types";

interface Args {
    friendId: string;
    choice: boolean;
}

const resolveRequestFriend = async (_: any, args: Args, context: Context, info: any) => {
    await checkIsLoggedIn(context);
    const userInfo = await getItem(DYNAMODB_TABLE_NAME_USERS, context.userId as string);
    const friendInfo = await getItem(DYNAMODB_TABLE_NAME_USERS, args.friendId);
    if (!getItemFromDynamoDBResult(friendInfo)) {
        throw new Error("Provided friendId does not exist as a User");
    }
    if (!getItemFromDynamoDBResult(userInfo)?.incomingFriendRequests.includes(args.friendId)) {
        throw new Error("Provided friendId has not asked to be friends");
    }
    await deleteItemsFromArray(
        DYNAMODB_TABLE_NAME_USERS,
        context.userId as string,
        "incomingFriendRequests",
        [args.friendId]
    );
    await deleteItemsFromArray(DYNAMODB_TABLE_NAME_USERS, args.friendId, "outgoingFriendRequests", [
        context.userId as string
    ]);
    return getItemFromDynamoDBResult(
        await addItemsToArray(DYNAMODB_TABLE_NAME_USERS, context.userId as string, "friends", [
            args.friendId
        ])
    ) as User;
};

export default resolveRequestFriend;
