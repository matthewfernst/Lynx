import convert from "convert-units";

import { Context } from "../../index";
import { LogDetailParent } from "../Log/id";

interface Args {
    system: "METRIC" | "IMPERIAL";
}

const minAltitude = (parent: LogDetailParent, args: Args, context: Context, info: any) => {
    if (args.system === "METRIC") {
        return convert(parent.minAlt).from("ft").to("m");
    }
    return parent.minAlt;
};

export default minAltitude;
