import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";
import {
    DYNAMODB_TABLE_NAME_USERS,
    getItemFromDynamoDBResult,
    updateItem
} from "../../aws/dynamodb";
import { User } from "../../types";

interface Args {
    userData: {
        key: string;
        value: string;
    }[];
}

const editUser = async (_: any, args: Args, context: Context, info: any): Promise<User | null> => {
    await checkIsLoggedIn(context);
    let queryOutput;
    for (const userValue of args.userData) {
        queryOutput = await updateItem(
            DYNAMODB_TABLE_NAME_USERS,
            context.userId as string,
            userValue.key,
            userValue.value
        );
    }
    return queryOutput ? getItemFromDynamoDBResult(queryOutput) : null;
};

export default editUser;
