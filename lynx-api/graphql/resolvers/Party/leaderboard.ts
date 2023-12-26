import { QueryCommand } from "@aws-sdk/lib-dynamodb";
import DataLoader from "dataloader";
import { GraphQLError } from "graphql";
import { DateTime } from "luxon";

import { documentClient } from "../../aws/dynamodb";
import { Context } from "../../index";
import { LEADERBOARD_TABLE } from "../../../infrastructure/lib/infrastructure";
import { LeaderboardEntry, Party, User } from "../../types";
import {
    LeaderboardSort,
    Timeframe,
    leaderboardTimeframeFromQueryArgument
} from "../Query/leaderboard";

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
    const usersInParty = await getUserIdsInParty(context.dataloaders.parties, parent.id);
    const leaderboardEntries = await getTimeframeRankingByIndex(
        leaderboardSortTypesToQueryFields[args.sortBy],
        leaderboardTimeframeFromQueryArgument(DateTime.now(), args.timeframe),
        args.limit,
        usersInParty
    );
    return await Promise.all(
        leaderboardEntries.map(async ({ id }) => (await context.dataloaders.users.load(id)) as User)
    );
};

const getTimeframeRankingByIndex = async (
    index: string,
    timeframe: string,
    limit: number,
    usersInParty: string[]
): Promise<LeaderboardEntry[]> => {
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
        throw new GraphQLError("DynamoDB Query Call Failed");
    }
};

const getUserIdsInParty = async (
    partiesDataloader: DataLoader<string, Party | undefined, string>,
    partyId: string
): Promise<string[]> => {
    const party = (await partiesDataloader.load(partyId)) as Party;
    return party.users;
};

export default leaderboard;
