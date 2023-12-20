import { QueryCommand } from "@aws-sdk/lib-dynamodb";
import { DateTime } from "luxon";

import { Context } from "../../index";
import { LeaderboardEntry, User } from "../../types";
import { LEADERBOARD_TABLE, USERS_TABLE, documentClient, getItem } from "../../aws/dynamodb";
import { populateLogbookDataForUser } from "./selfLookup";

export type LeaderboardSort = "DISTANCE" | "RUN_COUNT" | "TOP_SPEED" | "VERTICAL_DISTANCE";
export type Timeframe = "DAY" | "WEEK" | "MONTH" | "YEAR" | "ALL_TIME";

interface Args {
    sortBy: LeaderboardSort;
    timeframe: Timeframe;
    limit: number;
}

export const leaderboardSortTypesToQueryFields: { [key in LeaderboardSort]: string } = {
    DISTANCE: "distance",
    RUN_COUNT: "runCount",
    TOP_SPEED: "topSpeed",
    VERTICAL_DISTANCE: "verticalDistance"
};

const leaderboard = async (_: any, args: Args, context: Context, info: any): Promise<User[]> => {
    const leaderboardEntries = await getTimeframeRankingByIndex(
        leaderboardSortTypesToQueryFields[args.sortBy],
        valueFromTimeframe(args.timeframe),
        args.limit
    );
    return await Promise.all(
        leaderboardEntries.map(async ({ id }) => {
            const user = (await getItem(USERS_TABLE, id)) as User;
            return await populateLogbookDataForUser(user);
        })
    );
};

const valueFromTimeframe = (timeframe: Timeframe): string => {
    const now = DateTime.now();
    const day = now.ordinal;
    const week = now.weekNumber;
    const month = now.month;
    const year = now.year;

    switch (timeframe) {
        case "DAY":
            return `day-${day}`;
        case "WEEK":
            return `week-${week}`;
        case "MONTH":
            return `month-${month}`;
        case "YEAR":
            return `year-${year}`;
        case "ALL_TIME":
            return "all";
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
        throw Error("DynamoDB Query Call Failed");
    }
};

export default leaderboard;
