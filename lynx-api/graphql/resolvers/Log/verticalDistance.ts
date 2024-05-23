import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { ParsedLog } from "../User/logbook";

interface Args {
    system: keyof typeof MeasurementSystem;
}

const verticalDistance = (parent: ParsedLog, args: Args, context: Context, info: any) => {
    if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
        return convert(parent.attributes.vertical).from("m").to("ft");
    }
    return parent.attributes.vertical;
};

export default verticalDistance;
