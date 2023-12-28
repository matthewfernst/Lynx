import { checkIsMe } from "../../auth";
import { DefinedUserContext } from "../../index";
import { Log, User } from "../../types";

const logbook = async (
    parent: User,
    args: {},
    context: DefinedUserContext,
    info: any
): Promise<Log[]> => {
    checkIsMe(parent, context, "logbook");
    return await context.dataloaders.logs.load(context.userId);
};

export default logbook;
