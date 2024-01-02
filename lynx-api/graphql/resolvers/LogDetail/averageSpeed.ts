import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { LogDetailParent } from "../Log/id";

interface Args {
    system: keyof typeof MeasurementSystem;
}

const averageSpeed = (parent: LogDetailParent, args: Args, context: Context, info: any) => {
    if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
        return convert(parent.avgSpeed).from("m/s").to("m/h");
    }
    return convert(parent.avgSpeed).from("m/s").to("km/h");
};

export default averageSpeed;
