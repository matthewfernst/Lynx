import { Context } from "../../index";
import { ParsedLog } from "../User/logbook";

const id = (parent: ParsedLog, args: any, context: Context, info: any): string => {
    return parent.attributes.identifier;
};

export default id;
