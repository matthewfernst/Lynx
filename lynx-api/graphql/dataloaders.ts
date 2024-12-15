import { GetCommand } from "@aws-sdk/lib-dynamodb";
import DataLoader from "dataloader";
import { GraphQLError } from "graphql";

import {
    LEADERBOARD_TABLE,
    PARTIES_TABLE,
    PROFILE_PICS_BUCKET,
    SLOPES_UNZIPPED_BUCKET,
    USERS_TABLE
} from "../infrastructure/stacks/lynxApiStack";

import { documentClient, getItem } from "./aws/dynamodb";
import { checkIfObjectInBucket, getObjectNamesInBucket, getRecordFromBucket } from "./aws/s3";
import { xmlToActivity, getOriginalFileName } from "./resolvers/User/logbook";
import { DEPENDENCY_ERROR, Party, DatabaseUser, UserStats, ParsedLog } from "./types";

const createDataloaders = () => ({
    users: new DataLoader(userDataLoader),
    parties: new DataLoader(partiesDataLoader),
    leaderboard: new DataLoader(leaderboardDataLoader, {
        cacheKeyFn: (key) => JSON.stringify(key)
    }),
    logs: new DataLoader(logsDataLoader),
    profilePictures: new DataLoader(profilePictureDataloader, {
        cacheKeyFn: (user) => user.id
    })
});

const userDataLoader = async (
    userIds: readonly string[]
): Promise<(DatabaseUser | undefined)[]> => {
    return Promise.all(userIds.map((userId) => getItem(USERS_TABLE, userId)));
};

const partiesDataLoader = async (partyIds: readonly string[]): Promise<(Party | undefined)[]> => {
    return Promise.all(partyIds.map((partyId) => getItem(PARTIES_TABLE, partyId)));
};

const leaderboardDataLoader = async (
    leaderboardTableKeys: readonly { id: string; timeframe: string }[]
) => {
    return Promise.all(
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

export const profilePictureDataloader = async (
    users: readonly DatabaseUser[]
): Promise<(string | null)[]> => {
    return Promise.all(
        users.map(async (user) => {
            if (await checkIfObjectInBucket(PROFILE_PICS_BUCKET, user.id)) {
                console.info(`Found S3 profile picture for user ${user.id}`);
                return `https://${PROFILE_PICS_BUCKET}.s3.us-west-1.amazonaws.com/${user.id}`;
            } else if (user.profilePictureUrl) {
                return user.profilePictureUrl;
            } else {
                return null;
            }
        })
    );
};

export const logsDataLoader = async (userIds: readonly string[]): Promise<ParsedLog[][]> => {
    return Promise.all(
        userIds.map(async (userId) => {
            const recordNames = await getObjectNamesInBucket(SLOPES_UNZIPPED_BUCKET, userId);
            return Promise.all(
                recordNames.map(async (path) => {
                    const unzippedRecord = await getRecordFromBucket(SLOPES_UNZIPPED_BUCKET, path);
                    const activity = await xmlToActivity(unzippedRecord);
                    activity.originalFileName = getOriginalFileName(path);
                    return activity;
                })
            );
        })
    );
};

export default createDataloaders;
