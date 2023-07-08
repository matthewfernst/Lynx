import { Context } from "../../index";
import { LogDetailParent } from "../Log/id";

const endDate = (parent: LogDetailParent, args: any, context: Context, info: any) => {
    return parent.end;
};

export default endDate;
