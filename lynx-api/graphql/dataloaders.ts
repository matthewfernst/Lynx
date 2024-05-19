import DataLoader from "dataloader";
import { GraphQLError } from "graphql";
import { parseStringPromise, processors } from "xml2js";

import { documentClient, getItem } from "./aws/dynamodb";
import { getObjectNamesInBucket, getRecordFromBucket } from "./aws/s3";
import {
    LEADERBOARD_TABLE,
    PARTIES_TABLE,
    SLOPES_UNZIPPED_BUCKET,
    USERS_TABLE
} from "../infrastructure/lynxStack";
import { DEPENDENCY_ERROR, Log, UserStats } from "./types";
import { GetCommand } from "@aws-sdk/lib-dynamodb";

const createDataloaders = () => ({
    users: new DataLoader(userDataLoader),
    logs: new DataLoader(logsDataLoader),
    parties: new DataLoader(partiesDataLoader),
    leaderboard: new DataLoader(leaderboardDataLoader, { cacheKeyFn: (key) => JSON.stringify(key) })
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

const logsDataLoader = async (userIds: readonly string[]) => {
    return await Promise.all(
        userIds.map(async (userId) => {
            const recordNames = await getObjectNamesInBucket(SLOPES_UNZIPPED_BUCKET, userId);
            return await Promise.all(
                recordNames.map(async (name): Promise<Log> => {
                    const unzippedRecord = await getRecordFromBucket(SLOPES_UNZIPPED_BUCKET, name);
                    const activity = await xmlToActivity(unzippedRecord);
                    activity.originalFileName = `${name.split(".")[0]}.slopes`;
                    return activity;
                })
            );
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

export const xmlToActivity = async (xml: string): Promise<Log> => {
    try {
        const parsedXML = await parseStringPromise(xml, {
            normalize: true,
            mergeAttrs: true,
            explicitArray: false,
            tagNameProcessors: [processors.firstCharLowerCase],
            attrNameProcessors: [processors.firstCharLowerCase],
            valueProcessors: [processors.parseBooleans, processors.parseNumbers],
            attrValueProcessors: [processors.parseBooleans, processors.parseNumbers]
        });
        return parsedXML.activity;
    } catch (err) {
        console.error(err);
        throw new GraphQLError("Error Parsing XML", {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export default createDataloaders;
