import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { LogParent } from "./id";

interface Args {
    system: MeasurementSystem;
}

const topSpeed = (parent: LogParent, args: Args, context: Context, info: any) => {
    if (args.system === "METRIC") {
        return convert(parent.topSpeed).from("m/h").to("km/h");
    }
    return parent.topSpeed;
};

export default topSpeed;
