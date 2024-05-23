import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { ParsedLogDetails } from "../User/logbook";

interface Args {
    system: keyof typeof MeasurementSystem;
}

const minAltitude = (parent: ParsedLogDetails, args: Args, context: Context, info: any) => {
    if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
        return convert(parent.attributes.minAlt).from("m").to("ft");
    }
    return parent.attributes.minAlt;
};

export default minAltitude;
