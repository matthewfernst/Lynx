import { Context } from "../../index";
import { ParsedLogDetails } from "../User/logbook";

const endDate = (parent: ParsedLogDetails, args: any, context: Context, info: any) => {
    return parent.attributes.end;
};

export default endDate;
