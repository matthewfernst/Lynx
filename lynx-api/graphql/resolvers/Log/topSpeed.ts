import convert from "convert-units";
import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { MeasurementSystem, ParsedLog } from "../../types";

interface Args {
  system: keyof typeof MeasurementSystem;
}

const topSpeed = (
  parent: ParsedLog,
  args: Args,
  _context: Context,
  _info: GraphQLResolveInfo,
) => {
  if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
    return convert(parent.attributes.topSpeed).from("m/s").to("m/h");
  }
  return convert(parent.attributes.topSpeed).from("m/s").to("km/h");
};

export default topSpeed;
