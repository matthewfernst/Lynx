import { Context } from "../../index";
import { User } from "../../types";
import { checkHasUserId } from "../../auth";

const selfLookup = async (
    _: any,
    args: {},
    context: Context,
    info: any
): Promise<User | undefined> => {
    const userId = checkHasUserId(context.userId);
    return await context.dataloaders.users.load(userId);
};

export default selfLookup;
