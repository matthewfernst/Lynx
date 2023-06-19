import convert from "convert-units";

import { Context } from "../../index";
import { LogParent } from "./id";

interface Args {
    system: "METRIC" | "IMPERIAL";
}

const distance = (parent: LogParent, args: Args, context: Context, info: any) => {
    if (args.system === "METRIC") {
        return convert(parent.distance).from("ft").to("m");
    }
    return parent.distance;
};

export default distance;
