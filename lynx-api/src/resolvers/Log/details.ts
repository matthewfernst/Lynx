import { Context } from "../../index";
import { LogParent } from "./id";

const details = (parent: LogParent, args: any, context: Context, info: any) => {
    return parent.actions.action;
};

export default details;
