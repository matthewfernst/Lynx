import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { LogParent } from "./id";

interface Args {
    system: MeasurementSystem;
}

const verticalDistance = (parent: LogParent, args: Args, context: Context, info: any) => {
    if (args.system === "METRIC") {
        return convert(parent.vertical).from("ft").to("m");
    }
    return parent.vertical;
};

export default verticalDistance;
