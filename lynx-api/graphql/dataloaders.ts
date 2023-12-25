import DataLoader from "dataloader";
import { parseStringPromise, processors } from "xml2js";

import { getItem } from "./aws/dynamodb";
import { SLOPES_UNZIPPED_BUCKET, USERS_TABLE } from "../infrastructure/lib/infrastructure";
import { getObjectNamesInBucket, getRecordFromBucket } from "./aws/s3";
import { Log } from "./types";

export const usersDataLoader = new DataLoader(async (userIds: readonly string[]) =>
    Promise.all(userIds.map(async (userId) => await getItem(USERS_TABLE, userId)))
);

export const logsDataLoader = new DataLoader(async (userIds: readonly string[]) =>
    Promise.all(
        userIds.map(async (userId) => {
            const recordNames = await getObjectNamesInBucket(SLOPES_UNZIPPED_BUCKET, userId);
            console.log(`Retriving records with names [${recordNames}].`);
            return await Promise.all(
                recordNames.map(async (recordName): Promise<Log> => {
                    const unzippedRecord = await getRecordFromBucket(
                        SLOPES_UNZIPPED_BUCKET,
                        recordName
                    );
                    const activity = await xmlToActivity(unzippedRecord);
                    activity.originalFileName = `${recordName.split(".")[0]}.slopes`;
                    return activity;
                })
            );
        })
    )
);

export const xmlToActivity = async (xml: string): Promise<Log> => {
    const { activity } = await parseStringPromise(xml, {
        normalize: true,
        mergeAttrs: true,
        explicitArray: false,
        tagNameProcessors: [processors.firstCharLowerCase],
        attrNameProcessors: [processors.firstCharLowerCase],
        valueProcessors: [processors.parseBooleans, processors.parseNumbers],
        attrValueProcessors: [processors.parseBooleans, processors.parseNumbers]
    });
    return activity;
};

export default { users: usersDataLoader, logs: logsDataLoader };
