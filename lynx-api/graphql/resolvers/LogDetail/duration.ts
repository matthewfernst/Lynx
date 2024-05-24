import { Context } from "../../index";
import { ParsedLogDetails } from "../User/logbook";

const distance = (parent: ParsedLogDetails, args: any, context: Context, info: any) => {
    return parent.attributes.duration;
};

export default distance;
