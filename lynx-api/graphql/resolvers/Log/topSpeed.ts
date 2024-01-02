import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { LogParent } from "./id";

interface Args {
    system: keyof typeof MeasurementSystem;
}

const topSpeed = (parent: LogParent, args: Args, context: Context, info: any) => {
    if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
        return convert(parent.topSpeed).from("m/s").to("m/h");
    }
    return convert(parent.topSpeed).from("m/s").to("km/h");
};

export default topSpeed;
