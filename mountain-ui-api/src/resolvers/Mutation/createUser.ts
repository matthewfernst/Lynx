import { UserInputError } from "apollo-server-errors";

import CryptoJS from "crypto-js";
import { v4 as uuid } from "uuid";

import { generateToken } from "../../auth";
import { getItemsByIndex, putItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { sendAccountCreatedEmail } from "../../aws/ses";

interface Args {
    id: string;
    email: string;
    avatar?: string;
    name?: string;
}

const createUser = async (_: any, args: Args, context: Context, info: any): Promise<string> => {
    await validateEmail(args.email);
    await putItem("quaesta-users", args);
    console.log(`Sending Account Created Email to ${args.email}`);
    sendAccountCreatedEmail(args.email);
    return generateToken(args.id);
};

const validateEmail = async (email: string) => {
    const queryOutput = await getItemsByIndex("quaesta-users", "email", email);
    if (queryOutput.Count && queryOutput.Count > 0) {
        throw new UserInputError("User Already Exists");
    }
};

export default createUser;
