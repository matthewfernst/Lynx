import { GraphQLResolveInfo } from "graphql";

import { checkHasUserId, checkIsValidUserAndHasValidInvite } from "../../auth";
import { updateItem } from "../../aws/dynamodb";
import { Context } from "../../index";
import { User } from "../../types";
import { USERS_TABLE } from "../../../infrastructure/stacks/lynxApiStack";

interface Args {
    userData: {
        key: string;
        value: string;
    }[];
}

const editUser = async (
    _: unknown,
    args: Args,
    context: Context,
    _info: GraphQLResolveInfo
): Promise<User> => {
    checkHasUserId(context);
    await checkIsValidUserAndHasValidInvite(context);
    for (const data of args.userData) {
        await updateItem(USERS_TABLE, context.userId, data.key, data.value);
    }
    return (await context.dataloaders.users.load(context.userId)) as User;
};

export default editUser;
