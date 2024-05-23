import { Context } from "../../index";
import { ParsedLog, ParsedLogDetails } from "../User/logbook";

const details = (parent: ParsedLog, args: any, context: Context, info: any): ParsedLogDetails[] => {
    return parent.actions.flatMap((action) => action.action);
};

export default details;
