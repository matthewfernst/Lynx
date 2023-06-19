import { Context } from "../../index";
import { RunRecord } from "../../types";
import { getObjectNamesInBucket, getRecordFromBucket, toRunRecordsBucket } from "../../aws/s3";
import { parseStringPromise, processors } from "xml2js";

const reverseRenameFileFunction = (originalFileName: string) => {
    return `${originalFileName.split(".")[0]}.slopes`;
};

const logbook = async (
    parent: any,
    args: {},
    context: Context,
    info: any
): Promise<RunRecord[]> => {
    const recordNames = await getObjectNamesInBucket(toRunRecordsBucket, parent.id);
    return Promise.all(
        recordNames.map(async (recordName): Promise<RunRecord> => {
            const unzippedRecord = await getRecordFromBucket(toRunRecordsBucket, recordName);
            const { activity } = await parseStringPromise(unzippedRecord, {
                normalize: true,
                mergeAttrs: true,
                explicitArray: false,
                tagNameProcessors: [processors.firstCharLowerCase],
                attrNameProcessors: [processors.firstCharLowerCase],
                valueProcessors: [processors.parseBooleans, processors.parseNumbers],
                attrValueProcessors: [processors.parseBooleans, processors.parseNumbers]
            });
            activity.originalFileName = reverseRenameFileFunction(recordName);
            return activity;
        })
    );
};

export default logbook;
