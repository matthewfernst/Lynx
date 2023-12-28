import { checkIsMe } from "../../auth";
import { Context } from "../../index";
import { Log } from "../../types";

interface Parent {
    id: string;
    logbook?: Log[];
}

const logbook = async (parent: Parent, args: {}, context: Context, info: any): Promise<Log[]> => {
    const userId = checkIsMe(parent, context.userId, "logbook");
    return await context.dataloaders.logs.load(userId);
};

export default logbook;
