import { Context } from "../../index";
import { RunRecord } from "../../types";
import { getRecordsFromBucket, toRunRecordsBucket } from "../../aws/s3";
import { parseStringPromise, processors } from "xml2js";

const runRecords = async (
    parent: any,
    args: {},
    context: Context,
    info: any
): Promise<RunRecord[]> => {
    const records = await getRecordsFromBucket(toRunRecordsBucket, parent.id);
    return Promise.all(
        records.map(async (record): Promise<RunRecord> => {
            const xml: { activity: RunRecord } = await parseStringPromise(record, {
                normalize: true,
                mergeAttrs: true,
                explicitArray: false,
                tagNameProcessors: [processors.firstCharLowerCase],
                attrNameProcessors: [processors.firstCharLowerCase],
                valueProcessors: [processors.parseBooleans, processors.parseNumbers],
                attrValueProcessors: [processors.parseBooleans, processors.parseNumbers]
            });
            return xml.activity;
        })
    );
};

export default runRecords;
