import convert from "convert-units";
import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { MeasurementSystem, UserStats } from "../../types";

interface Args {
  system: keyof typeof MeasurementSystem;
}

const topSpeed = (
  parent: UserStats,
  args: Args,
  _context: Context,
  _info: GraphQLResolveInfo,
) => {
  if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
    return convert(parent.topSpeed).from("m/s").to("m/h");
  }
  return convert(parent.topSpeed).from("m/s").to("km/h");
};

export default topSpeed;
