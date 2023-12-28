import DataLoader from "dataloader";
import { parseStringPromise, processors } from "xml2js";

import { getItem } from "./aws/dynamodb";
import { getObjectNamesInBucket, getRecordFromBucket } from "./aws/s3";
import {
    PARTIES_TABLE,
    SLOPES_UNZIPPED_BUCKET,
    USERS_TABLE
} from "../infrastructure/lynxStack";
import { Log } from "./types";

const createDataloaders = () => ({
    users: new DataLoader(userDataLoader),
    logs: new DataLoader(logsDataLoader),
    parties: new DataLoader(partiesDataLoader)
});

const userDataLoader = async (userIds: readonly string[]) => {
    return await Promise.all(userIds.map(async (userId) => await getItem(USERS_TABLE, userId)));
};

const logsDataLoader = async (userIds: readonly string[]) => {
    return await Promise.all(
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
    );
};

const partiesDataLoader = async (partyIds: readonly string[]) => {
    return await Promise.all(
        partyIds.map(async (partyId) => await getItem(PARTIES_TABLE, partyId))
    );
};

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

export default createDataloaders;
