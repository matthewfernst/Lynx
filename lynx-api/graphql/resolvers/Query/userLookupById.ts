import { Context } from "../../index";
import { User } from "../../types";

interface Args {
    id: string;
}

const userLookupById = async (
    _: any,
    args: Args,
    context: Context,
    info: any
): Promise<User | undefined> => {
    return context.dataloaders.users.load(args.id);
};

export default userLookupById;
