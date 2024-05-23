import { Context } from "../../index";
import { ParsedLog } from "../User/logbook";

const startDate = (parent: ParsedLog, args: any, context: Context, info: any) => {
    return parent.attributes.start;
};

export default startDate;
