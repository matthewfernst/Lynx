import { Context } from "../../index";
import { LogDetailType } from "../../types";
import { LogDetailParent } from "../Log/id";

const type = (parent: LogDetailParent, args: any, context: Context, info: any) => {
    return parent.type.toUpperCase();
};

export default type;
