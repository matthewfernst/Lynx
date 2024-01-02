import convert from "convert-units";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { LogParent } from "./id";

interface Args {
    system: keyof typeof MeasurementSystem;
}

const verticalDistance = (parent: LogParent, args: Args, context: Context, info: any) => {
    if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
        return convert(parent.vertical).from("m").to("ft");
    }
    return parent.vertical;
};

export default verticalDistance;
