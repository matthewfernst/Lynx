import { Context } from "../../index";
import { LogParent } from "./id";

const endDate = (parent: LogParent, args: any, context: Context, info: any) => {
    return parent.end;
};

export default endDate;
