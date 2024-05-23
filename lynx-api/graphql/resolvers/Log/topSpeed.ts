import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { ParsedLog } from "../User/logbook";

interface Args {
    system: keyof typeof MeasurementSystem;
}

const topSpeed = (parent: ParsedLog, args: Args, context: Context, info: any) => {
    if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
        return convert(parent.attributes.topSpeed).from("m/s").to("m/h");
    }
    return convert(parent.attributes.topSpeed).from("m/s").to("km/h");
};

export default topSpeed;
