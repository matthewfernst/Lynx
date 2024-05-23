import { Context } from "../../index";
import { ParsedLog } from "../User/logbook";

const endDate = (parent: ParsedLog, args: any, context: Context, info: any) => {
    return parent.attributes.end;
};

export default endDate;
