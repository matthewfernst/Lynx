import { QueryCommand } from "@aws-sdk/lib-dynamodb";
import { GraphQLError } from "graphql";
import { DateTime } from "luxon";

import { Context } from "../../index";
import { DEPENDENCY_ERROR, LeaderboardEntry, User } from "../../types";
import { documentClient } from "../../aws/dynamodb";
import { LEADERBOARD_TABLE } from "../../../infrastructure/lynxStack";

export type LeaderboardSort = "DISTANCE" | "RUN_COUNT" | "TOP_SPEED" | "VERTICAL_DISTANCE";
export type LeaderboardQueryFields = "distance" | "runCount" | "topSpeed" | "verticalDistance";
export type Timeframe = "DAY" | "WEEK" | "MONTH" | "SEASON" | "ALL_TIME";

interface Args {
    sortBy: LeaderboardSort;
    timeframe: Timeframe;
    limit: number;
}

export const leaderboardSortTypesToQueryFields: {
    [key in LeaderboardSort]: LeaderboardQueryFields;
} = {
    DISTANCE: "distance",
    RUN_COUNT: "runCount",
    TOP_SPEED: "topSpeed",
    VERTICAL_DISTANCE: "verticalDistance"
};

const leaderboard = async (_: any, args: Args, context: Context, info: any): Promise<User[]> => {
    const leaderboardEntries = await getTimeframeRankingByIndex(
        leaderboardSortTypesToQueryFields[args.sortBy],
        leaderboardTimeframeFromQueryArgument(DateTime.now(), args.timeframe),
        args.limit
    );
    return await Promise.all(
        leaderboardEntries.map(async ({ id }) => (await context.dataloaders.users.load(id)) as User)
    );
};

export const leaderboardTimeframeFromQueryArgument = (
    date: DateTime,
    timeframe: Timeframe
): string => {
    switch (timeframe) {
        case "DAY":
            return `day-${date.ordinal}`;
        case "WEEK":
            return `week-${date.weekNumber}`;
        case "MONTH":
            return `month-${date.month}`;
        case "SEASON":
            return seasonNameFromDateArgument(date);
        case "ALL_TIME":
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
    limit: number
): Promise<LeaderboardEntry[]> => {
    try {
        console.log(`Getting items with timeframe ${timeframe} sorted by ${index}`);
        const queryRequest = new QueryCommand({
            TableName: LEADERBOARD_TABLE,
            IndexName: index,
            KeyConditionExpression: "timeframe = :value",
            ExpressionAttributeValues: { ":value": timeframe },
            ScanIndexForward: false,
            Limit: limit
        });
        const itemOutput = await documentClient.send(queryRequest);
        return itemOutput.Items as LeaderboardEntry[];
    } catch (err) {
        console.error(err);
        throw new GraphQLError("DynamoDB Query Call Failed", {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export default leaderboard;
