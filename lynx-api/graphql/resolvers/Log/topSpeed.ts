import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { LogParent } from "./id";

interface Args {
    system: MeasurementSystem;
}

const topSpeed = (parent: LogParent, args: Args, context: Context, info: any) => {
    if (args.system === "IMPERIAL") {
        return convert(parent.topSpeed).from("m/s").to("m/h");
    }
    return convert(parent.topSpeed).from("m/s").to("km/h");
};

export default topSpeed;
