import { Context } from "../../index";
import { ParsedLog } from "../User/logbook";

const runCount = (parent: ParsedLog, args: any, context: Context, info: any): number => {
    return parent.attributes.runCount;
};

export default runCount;
