import { UserInputError } from "apollo-server-errors";

import { generateToken } from "../../auth";
import { getItemsByIndex, putItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { sendAccountCreatedEmail } from "../../aws/ses";

interface Args {
    id: string;
    email: string;
}

const createUser = async (_: any, args: Args, context: Context, info: any): Promise<string> => {
    await putItem("mountain-ui-app-users", args);
    console.log(`Sending Account Created Email to ${args.email}`);
    sendAccountCreatedEmail(args.email);
    return generateToken(args.id);
};

export default createUser;
