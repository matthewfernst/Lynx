import { Context } from "../../index";
import { ParsedLogDetails } from "../User/logbook";

const startDate = (parent: ParsedLogDetails, args: any, context: Context, info: any) => {
    return parent.attributes.start;
};

export default startDate;
