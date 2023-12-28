import { Context } from "../../index";
import { User } from "../../types";
import { checkHasUserId } from "../../auth";

const selfLookup = async (
    _: any,
    args: {},
    context: Context,
    info: any
): Promise<User | undefined> => {
    checkHasUserId(context);
    return await context.dataloaders.users.load(context.userId);
};

export default selfLookup;
