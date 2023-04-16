import { UserInputError } from "apollo-server-express";

import { generateToken } from "../../auth";
import { getItem, getItemFromDynamoDBResult } from "../../db";
import { Context } from "../../index";
import { User } from "../../../types";

interface Args {
    id: string;
}

const loginUser = async (_: any, args: Args, context: Context, info: any): Promise<string> => {
    const queryOutput = await getItem("quaesta-users", args.id);
    const userRecord = getItemFromDynamoDBResult(queryOutput) as User | null;
    if (!userRecord) {
        throw new UserInputError("User Not Found");
    }
    return generateToken(userRecord.id.toString());
};

export default loginUser;
