import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { LogDetailParent } from "../Log/id";

interface Args {
    system: MeasurementSystem;
}

const maxAltitude = (parent: LogDetailParent, args: Args, context: Context, info: any) => {
    if (args.system === "IMPERIAL") {
        return convert(parent.maxAlt).from("m").to("ft");
    }
    return parent.maxAlt;
};

export default maxAltitude;
