import { Context } from "../../index";
import { ParsedLogDetails } from "../User/logbook";

const type = (parent: ParsedLogDetails, args: any, context: Context, info: any) => {
    return parent.attributes.type.toUpperCase();
};

export default type;
