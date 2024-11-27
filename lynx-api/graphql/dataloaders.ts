import { GetCommand } from "@aws-sdk/lib-dynamodb";
import DataLoader from "dataloader";
import { GraphQLError } from "graphql";

import { documentClient, getItem } from "./aws/dynamodb";
import { LEADERBOARD_TABLE, PARTIES_TABLE, USERS_TABLE } from "../infrastructure/stacks/lynxApiStack";
import { DEPENDENCY_ERROR, UserStats } from "./types";
import { profilePictureDataloader } from "./resolvers/User/profilePictureUrl";
import { logsDataLoader } from "./resolvers/User/logbook";

const createDataloaders = () => ({
    users: new DataLoader(userDataLoader),
    parties: new DataLoader(partiesDataLoader),
    leaderboard: new DataLoader(leaderboardDataLoader, {
        cacheKeyFn: (key) => JSON.stringify(key)
    }),
    logs: new DataLoader(logsDataLoader),
    profilePictures: new DataLoader(profilePictureDataloader, {
        cacheKeyFn: (key) => JSON.stringify(key)
    })
});

const userDataLoader = async (userIds: readonly string[]) => {
    return await Promise.all(
        userIds.map(async (userId) => {
            try {
                return await getItem(USERS_TABLE, userId);
            } catch (err) {
                console.error(err);
                throw new GraphQLError("DynamoDB Call Failed", {
                    extensions: { code: DEPENDENCY_ERROR }
                });
            }
        })
    );
};

const partiesDataLoader = async (partyIds: readonly string[]) => {
    return await Promise.all(
        partyIds.map(async (partyId) => {
            try {
                return await getItem(PARTIES_TABLE, partyId);
            } catch (err) {
                console.error(err);
                throw new GraphQLError("DynamoDB Call Failed", {
                    extensions: { code: DEPENDENCY_ERROR }
                });
            }
        })
    );
};

const leaderboardDataLoader = async (
    leaderboardTableKeys: readonly { id: string; timeframe: string }[]
) => {
    return await Promise.all(
        leaderboardTableKeys.map(async ({ id, timeframe }) => {
            try {
                const queryRequest = new GetCommand({
                    TableName: LEADERBOARD_TABLE,
                    Key: { id, timeframe }
                });
                const itemOutput = await documentClient.send(queryRequest);
                console.log(`Retrieved leaderboard item for id ${id} and timeframe ${timeframe}`);
                return itemOutput.Item as UserStats;
            } catch (err) {
                console.error(err);
                throw new GraphQLError("DynamoDB Call Failed", {
                    extensions: { code: DEPENDENCY_ERROR }
                });
            }
        })
    );
};

export default createDataloaders;
