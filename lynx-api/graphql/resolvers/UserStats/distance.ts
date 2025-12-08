import convert from "convert-units";
import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { MeasurementSystem, UserStats } from "../../types";

interface Args {
  system: keyof typeof MeasurementSystem;
}

const distance = (
  parent: UserStats,
  args: Args,
  _context: Context,
  _info: GraphQLResolveInfo,
) => {
  if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
    return convert(parent.distance).from("m").to("ft");
  }
  return parent.distance;
};

export default distance;
