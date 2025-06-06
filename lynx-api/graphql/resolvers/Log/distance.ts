import convert from "convert-units";
import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { MeasurementSystem, ParsedLog } from "../../types";

interface Args {
    system: keyof typeof MeasurementSystem;
}

const distance = (parent: ParsedLog, args: Args, _context: Context, _info: GraphQLResolveInfo) => {
    if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
        return convert(parent.attributes.distance).from("m").to("ft");
    }
    return parent.attributes.distance;
};

export default distance;
