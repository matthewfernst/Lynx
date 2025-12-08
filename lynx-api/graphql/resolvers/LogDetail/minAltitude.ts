import convert from "convert-units";
import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { MeasurementSystem, ParsedLogDetails } from "../../types";

interface Args {
  system: keyof typeof MeasurementSystem;
}

const minAltitude = (
  parent: ParsedLogDetails,
  args: Args,
  _context: Context,
  _info: GraphQLResolveInfo,
) => {
  if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
    return convert(parent.attributes.minAlt).from("m").to("ft");
  }
  return parent.attributes.minAlt;
};

export default minAltitude;
