import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { ParsedLogDetails } from "../User/logbook";

interface Args {
    system: keyof typeof MeasurementSystem;
}

const distance = (parent: ParsedLogDetails, args: Args, context: Context, info: any) => {
    if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
        return convert(parent.attributes.distance).from("m").to("ft");
    }
    return parent.attributes.distance;
};

export default distance;
