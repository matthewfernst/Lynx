import { GraphQLError, GraphQLResolveInfo } from "graphql";
import { DateTime } from "luxon";
import { parseStringPromise, processors } from "xml2js";

import { checkIsMe } from "../../auth";
import { DefinedUserContext } from "../../index";
import { DEPENDENCY_ERROR, DatabaseUser, ParsedLog } from "../../types";
import { Timeframe } from "../Query/leaderboard";

export interface Args {
  timeframe: keyof typeof Timeframe;
}

const logbook = async (
  parent: DatabaseUser,
  args: Args,
  context: DefinedUserContext,
  _info: GraphQLResolveInfo,
): Promise<ParsedLog[]> => {
  checkIsMe(parent, context, "logbook");
  const logs = await context.dataloaders.logs.load(context.userId);
  return logs.filter((log) => filterLogByTimeframe(log, args.timeframe));
};

export const xmlToActivity = async (xml: string): Promise<ParsedLog> => {
  try {
    const parsedXML = await parseStringPromise(xml, {
      normalize: true,
      attrkey: "attributes",
      tagNameProcessors: [processors.firstCharLowerCase],
      attrNameProcessors: [processors.firstCharLowerCase],
      valueProcessors: [processors.parseBooleans, processors.parseNumbers],
      attrValueProcessors: [processors.parseBooleans, processors.parseNumbers],
    });
    return parsedXML.activity;
  } catch (err) {
    console.error(err);
    throw new GraphQLError("Error Parsing XML", {
      extensions: { code: DEPENDENCY_ERROR },
    });
  }
};

export const getOriginalFileName = (objectPath: string): string => {
  const objectName = objectPath.split("/").pop();
  if (!objectName) {
    throw new GraphQLError("Object Name Not Found", {
      extensions: { code: DEPENDENCY_ERROR, objectPath },
    });
  }
  return `${objectName.split(".")[0]}.slopes`;
};

const filterLogByTimeframe = (log: ParsedLog, timeframe: string): boolean => {
  const date = DateTime.fromFormat(
    log.attributes.start,
    "yyyy-MM-dd HH:mm:ss ZZZ",
  );
  const currentTime = DateTime.now();
  const diff = currentTime.diff(date, ["months", "weeks", "days"]);
  switch (timeframe) {
    case "ALL_TIME":
      return true;
    case "SEASON": {
      const seasonStart = getSeasonStart(currentTime);
      const seasonEnd = getSeasonEnd(currentTime);
      return seasonStart < date && date < seasonEnd;
    }
    case "MONTH":
      return diff.months <= 1;
    case "WEEK":
      return diff.weeks <= 1;
    case "DAY":
      return diff.days <= 1;
  }
  return false;
};

export const getSeasonStart = (time: DateTime): DateTime => {
  if (time.month >= 8) {
    return time.startOf("year").plus({ months: 8 });
  } else {
    return time.startOf("year").minus({ months: 5 });
  }
};

export const getSeasonEnd = (time: DateTime): DateTime => {
  if (time.month >= 8) {
    return time.startOf("year").plus({ years: 1, months: 8 });
  } else {
    return time.startOf("year").plus({ months: 8 });
  }
};

export default logbook;
