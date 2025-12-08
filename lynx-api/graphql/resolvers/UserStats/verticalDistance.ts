import convert from "convert-units";
import { GraphQLResolveInfo } from "graphql";

import { Context } from "../../index";
import { MeasurementSystem, UserStats } from "../../types";

interface Args {
  system: keyof typeof MeasurementSystem;
}

const verticalDistance = (
  parent: UserStats,
  args: Args,
  _context: Context,
  _info: GraphQLResolveInfo,
) => {
  if (MeasurementSystem[args.system] === MeasurementSystem.IMPERIAL) {
    return convert(parent.verticalDistance).from("m").to("ft");
  }
  return parent.verticalDistance;
};

export default verticalDistance;
