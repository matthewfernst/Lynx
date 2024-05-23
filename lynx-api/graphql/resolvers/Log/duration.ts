import { Context } from "../../index";
import { ParsedLog } from "../User/logbook";

const duration = (parent: ParsedLog, args: any, context: Context, info: any): number => {
    return parent.attributes.duration;
};

export default duration;
