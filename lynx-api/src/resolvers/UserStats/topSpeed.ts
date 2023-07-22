import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";

interface Args {
    system: MeasurementSystem;
}

const topSpeed = (parent: any, args: Args, context: Context, info: any) => {
    if (args.system === "IMPERIAL") {
        return convert(parent.topSpeed).from("m/s").to("m/h");
    }
    return convert(parent.topSpeed).from("m/s").to("km/h");
};

export default topSpeed;
