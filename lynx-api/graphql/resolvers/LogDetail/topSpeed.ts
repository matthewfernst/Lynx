import convert from "convert-units";
import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { MeasurementSystem, ParsedLogDetails } from "../../types";

interface Args {
  system: keyof typeof MeasurementSystem;
}

const topSpeed = (
  parent: ParsedLogDetails,
  args: Args,
  _context: Context,
  _info: GraphQLResolveInfo,
) => {
  if (MeasurementSystem[args.system] === MeasurementSystem.METRIC) {
    return convert(parent.attributes.topSpeed).from("m/h").to("km/h");
  }
  return parent.attributes.topSpeed;
};

export default topSpeed;
