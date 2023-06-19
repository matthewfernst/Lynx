import { Context } from "../../index";
import { LogParent } from "./id";

const startDate = (parent: LogParent, args: any, context: Context, info: any) => {
    return parent.start;
};

export default startDate;
