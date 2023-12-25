import { GetCommand } from "@aws-sdk/lib-dynamodb";
import { GraphQLError } from "graphql";

import { Context } from "../../index";
import { DEPENDENCY_ERROR, UserStats } from "../../types";
import { Timeframe, leaderboardTimeframeFromQueryArgument } from "../Query/leaderboard";
import { LEADERBOARD_TABLE } from "../../../infrastructure/lib/infrastructure";
import { documentClient } from "../../aws/dynamodb";

interface Parent {
    id: string;
}

interface Args {
    timeframe: Timeframe;
}

const stats = async (
    parent: Parent,
    args: Args,
    context: Context,
    info: any
): Promise<UserStats | undefined> => {
    const timeframe = leaderboardTimeframeFromQueryArgument(args.timeframe);
    return await getUserStatsFromLeaderboard(parent.id, timeframe);
};

const getUserStatsFromLeaderboard = async (id: string, timeframe: string): Promise<UserStats> => {
    try {
        console.log(`Getting user stats with timeframe ${timeframe}`);
        const queryRequest = new GetCommand({
            TableName: LEADERBOARD_TABLE,
            Key: { id, timeframe }
        });
        const itemOutput = await documentClient.send(queryRequest);
        return itemOutput.Item as UserStats;
    } catch (err) {
        console.error(err);
        throw new GraphQLError("DynamoDB Query Call Failed", {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export default stats;
