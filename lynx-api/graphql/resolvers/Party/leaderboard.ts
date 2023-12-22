import { QueryCommand } from "@aws-sdk/lib-dynamodb";
import { DateTime } from "luxon";

import { Context } from "../../index";
import { LeaderboardEntry, Party, User } from "../../types";
import { documentClient, getItem } from "../../aws/dynamodb";
import { populateLogbookDataForUser } from "../Query/selfLookup";
import { LeaderboardSort, Timeframe } from "../Query/leaderboard";
import { LEADERBOARD_TABLE, PARTIES_TABLE, USERS_TABLE } from "../../../infrastructure/lib/infrastructure";

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

const leaderboard = async (
    parent: Party,
    args: Args,
    context: Context,
    info: any
): Promise<User[]> => {
    const leaderboardEntries = await getTimeframeRankingByIndex(
        leaderboardSortTypesToQueryFields[args.sortBy],
        valueFromTimeframe(args.timeframe),
        args.limit,
        parent.id
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
    limit: number,
    partyId: string
): Promise<LeaderboardEntry[]> => {
    const usersInParty = getUserIdsInParty(partyId);
    try {
        console.log(`Getting items with timeframe ${timeframe} sorted by ${index}`);
        const queryRequest = new QueryCommand({
            TableName: LEADERBOARD_TABLE,
            IndexName: index,
            KeyConditionExpression: "timeframe = :value",
            ExpressionAttributeValues: { ":value": timeframe, ":users": usersInParty },
            ScanIndexForward: false,
            Limit: limit,
            FilterExpression: "id IN :users"
        });
        const itemOutput = await documentClient.send(queryRequest);
        return itemOutput.Items as LeaderboardEntry[];
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Query Call Failed");
    }
};

const getUserIdsInParty = async (partyId: string): Promise<string[]> => {
    const party = (await getItem(PARTIES_TABLE, partyId)) as Party;
    return party.users;
};

export default leaderboard;
