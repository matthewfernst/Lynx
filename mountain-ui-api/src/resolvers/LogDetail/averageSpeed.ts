import convert from "convert-units";

import { Context } from "../../index";
import { LogDetailParent } from "../Log/id";

interface Args {
    system: "METRIC" | "IMPERIAL";
}

const averageSpeed = (parent: LogDetailParent, args: Args, context: Context, info: any) => {
    if (args.system === "METRIC") {
        return convert(parent.avgSpeed).from("m/h").to("km/h");
    }
    return parent.avgSpeed;
};

export default averageSpeed;
