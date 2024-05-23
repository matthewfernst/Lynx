import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { ParsedLogDetails } from "../User/logbook";

interface Args {
    system: keyof typeof MeasurementSystem;
}

const topSpeedAltitude = (parent: ParsedLogDetails, args: Args, context: Context, info: any) => {
    if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
        return convert(parent.attributes.topSpeedAlt).from("m").to("ft");
    }
    return parent.attributes.topSpeedAlt;
};

export default topSpeedAltitude;
