import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { ParsedLogDetails } from "../User/logbook";

interface Args {
    system: keyof typeof MeasurementSystem;
}

const topSpeed = (parent: ParsedLogDetails, args: Args, context: Context, info: any) => {
    if (MeasurementSystem[args.system] === MeasurementSystem.METRIC) {
        return convert(parent.attributes.topSpeed).from("m/h").to("km/h");
    }
    return parent.attributes.topSpeed;
};

export default topSpeed;
