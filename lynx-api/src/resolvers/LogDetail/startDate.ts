import { Context } from "../../index";
import { LogDetailParent } from "../Log/id";

const startDate = (parent: LogDetailParent, args: any, context: Context, info: any) => {
    return parent.start;
};

export default startDate;
