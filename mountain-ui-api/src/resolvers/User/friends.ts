import { Context } from "../../index";
import { checkIsMe } from "../../auth";
import { getItemFromDynamoDBResult, getItem, DYNAMODB_TABLE_NAME_USERS } from "../../aws/dynamodb";

interface Parent {
    id: string;
    friends: string[];
}

const friends = (parent: Parent, args: any, context: Context, info: any) => {
    checkIsMe(parent, context);
    return Promise.all(
        parent.friends.map(async (id) => {
            const queryOutput = await getItem(DYNAMODB_TABLE_NAME_USERS, id);
            return getItemFromDynamoDBResult(queryOutput);
        })
    );
};

export default friends;
