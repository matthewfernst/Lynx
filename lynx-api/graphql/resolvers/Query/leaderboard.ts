import { QueryCommand } from "@aws-sdk/lib-dynamodb";
import { GraphQLError, GraphQLResolveInfo } from "graphql";
import { DateTime } from "luxon";

import { Context } from "../../index";
import { DEPENDENCY_ERROR, LeaderboardEntry, DatabaseUser } from "../../types";
import { documentClient } from "../../aws/dynamodb";
import { LEADERBOARD_TABLE } from "../../../infrastructure/stacks/lynxApiStack";

export enum LeaderboardSort {
  DISTANCE,
  RUN_COUNT,
  TOP_SPEED,
  VERTICAL_DISTANCE,
}
export enum Timeframe {
  DAY,
  WEEK,
  MONTH,
  SEASON,
  ALL_TIME,
}

interface Args {
  sortBy: keyof typeof LeaderboardSort;
  timeframe: keyof typeof Timeframe;
  limit: number;
}

export const leaderboardSortTypesToQueryFields: {
  [key in LeaderboardSort]:
    | "distance"
    | "runCount"
    | "topSpeed"
    | "verticalDistance";
} = {
  [LeaderboardSort.DISTANCE]: "distance",
  [LeaderboardSort.RUN_COUNT]: "runCount",
  [LeaderboardSort.TOP_SPEED]: "topSpeed",
  [LeaderboardSort.VERTICAL_DISTANCE]: "verticalDistance",
};

const leaderboard = async (
  _: unknown,
  args: Args,
  context: Context,
  _info: GraphQLResolveInfo,
): Promise<DatabaseUser[]> => {
  const leaderboardEntries = await getTimeframeRankingByIndex(
    leaderboardSortTypesToQueryFields[LeaderboardSort[args.sortBy]],
    leaderboardTimeframeFromQueryArgument(
      DateTime.now(),
      Timeframe[args.timeframe],
    ),
    args.limit,
  );
  return Promise.all(
    leaderboardEntries.map(
      async ({ id }) =>
        (await context.dataloaders.users.load(id)) as DatabaseUser,
    ),
  );
};

export const leaderboardTimeframeFromQueryArgument = (
  date: DateTime,
  timeframe: Timeframe,
): string => {
  switch (timeframe) {
    case Timeframe.DAY:
      return `day-${date.ordinal}`;
    case Timeframe.WEEK:
      return `week-${date.weekNumber}`;
    case Timeframe.MONTH:
      return `month-${date.month}`;
    case Timeframe.SEASON:
      return seasonNameFromDateArgument(date);
    case Timeframe.ALL_TIME:
      return "all";
  }
};

export const seasonNameFromDateArgument = (time: DateTime): string => {
  if (time.month >= 8) {
    return `${time.year}-${time.year + 1}`;
  } else {
    return `${time.year - 1}-${time.year}`;
  }
};

const getTimeframeRankingByIndex = async (
  index: string,
  timeframe: string,
  limit: number,
): Promise<LeaderboardEntry[]> => {
  try {
    console.info(
      `Getting items with timeframe ${timeframe} sorted by ${index}`,
    );
    const queryRequest = new QueryCommand({
      TableName: LEADERBOARD_TABLE,
      IndexName: index,
      KeyConditionExpression: "timeframe = :value",
      ExpressionAttributeValues: { ":value": timeframe },
      ScanIndexForward: false,
      Limit: limit,
    });
    const itemOutput = await documentClient.send(queryRequest);
    return itemOutput.Items as LeaderboardEntry[];
  } catch (err) {
    console.error(err);
    throw new GraphQLError("DynamoDB Query Call Failed", {
      extensions: { code: DEPENDENCY_ERROR },
    });
  }
};

export default leaderboard;
