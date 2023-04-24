import { UserInputError } from "apollo-server-express";

import { generateToken } from "../../auth";
import { getItem, getItemFromDynamoDBResult } from "../../aws/dynamodb";
import { Context } from "../../index";

interface Args {
    id: string;
}

const loginUser = async (_: any, args: Args, context: Context, info: any): Promise<string> => {
    const queryOutput = await getItem("mountain-ui-app-users", args.id);
    const userRecord = getItemFromDynamoDBResult(queryOutput);
    if (!userRecord) {
        throw new UserInputError("User Not Found");
    }
    return generateToken(userRecord.id);
};

export default loginUser;
