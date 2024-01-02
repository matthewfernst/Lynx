import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { LogDetailParent } from "../Log/id";

interface Args {
    system: keyof typeof MeasurementSystem;
}

const topSpeed = (parent: LogDetailParent, args: Args, context: Context, info: any) => {
    if (MeasurementSystem[args.system] === MeasurementSystem.METRIC) {
        return convert(parent.topSpeed).from("m/h").to("km/h");
    }
    return parent.topSpeed;
};

export default topSpeed;
