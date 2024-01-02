import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";

interface Args {
    system: keyof typeof MeasurementSystem;
}

const topSpeed = (parent: any, args: Args, context: Context, info: any) => {
    if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
        return convert(parent.topSpeed).from("m/s").to("m/h");
    }
    return convert(parent.topSpeed).from("m/s").to("km/h");
};

export default topSpeed;
