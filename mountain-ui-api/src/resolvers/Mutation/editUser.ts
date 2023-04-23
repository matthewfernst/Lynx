import { UserInputError } from "apollo-server-errors";

import { Context } from "../../index";
import { checkIsLoggedIn } from "../../auth";
import { getItemFromDynamoDBResult, getItemsByIndex, updateItem } from "../../aws/dynamodb";

interface Args {
    userPairs: {
        key: string;
        value: string;
    }[];
}

const editUser = async (_: any, args: Args, context: Context, info: any) => {
    await checkIsLoggedIn(context);
    let queryOutput;
    for (const userValue of args.userPairs) {
        if (userValue.key === "email") {
            await validateEmail(userValue.value);
        }

        queryOutput = await updateItem(
            "quaesta-users",
            context.userId as string,
            userValue.key,
            userValue.value
        );
    }

    return queryOutput ? getItemFromDynamoDBResult(queryOutput) : null;
};

const validateEmail = async (email: string) => {
    const queryOutput = await getItemsByIndex("quaesta-users", "email", email);
    if (queryOutput.Count && queryOutput.Count > 0) {
        throw new UserInputError("User Already Exists");
    }
};

export default editUser;
