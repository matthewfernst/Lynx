import { Context } from "../../index";
import { ParsedLog } from "../User/logbook";

const locationName = (parent: ParsedLog, args: any, context: Context, info: any): string => {
    return parent.attributes.locationName;
};

export default locationName;
