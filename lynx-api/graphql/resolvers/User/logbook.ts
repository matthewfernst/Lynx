import { Context } from "../../index";
import { Log } from "../../types";
import { getObjectNamesInBucket, getRecordFromBucket, toRunRecordsBucket } from "../../aws/s3";
import { parseStringPromise, processors } from "xml2js";

const reverseRenameFileFunction = (originalFileName: string) => {
    return `${originalFileName.split(".")[0]}.slopes`;
};

const logbook = async (parent: any, args: {}, context: Context, info: any): Promise<Log[]> => {
    if (!parent.logbook) {
        return await getLogbookInformationFromS3(parent.id);
    }
    return parent.logbook;
};

export const getLogbookInformationFromS3 = async (userId: string): Promise<Log[]> => {
    const recordNames = await getObjectNamesInBucket(toRunRecordsBucket, userId);
    return Promise.all(
        recordNames.map(async (recordName): Promise<Log> => {
            const unzippedRecord = await getRecordFromBucket(toRunRecordsBucket, recordName);
            const activity = await xmlToActivity(unzippedRecord);
            activity.originalFileName = reverseRenameFileFunction(recordName);
            return activity;
        })
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
}

export default logbook;
