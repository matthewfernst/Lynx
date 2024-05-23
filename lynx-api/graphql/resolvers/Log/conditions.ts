import { Context } from "../../index";
import { ParsedLog } from "../User/logbook";

const conditions = (parent: ParsedLog, args: any, context: Context, info: any): string[] => {
    return parent.attributes.conditions.split(",");
};

export default conditions;
