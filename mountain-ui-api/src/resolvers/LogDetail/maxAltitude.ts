import convert from "convert-units";

import { Context } from "../../index";
import { LogDetailParent } from "../Log/id";

interface Args {
    system: "METRIC" | "IMPERIAL";
}

const maxAltitude = (parent: LogDetailParent, args: Args, context: Context, info: any) => {
    if (args.system === "METRIC") {
        return convert(parent.maxAlt).from("ft").to("m");
    }
    return parent.maxAlt;
};

export default maxAltitude;
