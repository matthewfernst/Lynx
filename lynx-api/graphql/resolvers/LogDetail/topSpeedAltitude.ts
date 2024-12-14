import convert from "convert-units";
import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { MeasurementSystem } from "../../types";
import { ParsedLogDetails } from "../User/logbook";

interface Args {
    system: keyof typeof MeasurementSystem;
}

const topSpeedAltitude = (
    parent: ParsedLogDetails,
    args: Args,
    _context: Context,
    _info: GraphQLResolveInfo
) => {
    if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
        return convert(parent.attributes.topSpeedAlt).from("m").to("ft");
    }
    return parent.attributes.topSpeedAlt;
};

export default topSpeedAltitude;
