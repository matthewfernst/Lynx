import { Context } from "../../index";
import { RunRecord } from "../../types";
import { getRecordsFromBucket, toRunRecordsBucket } from "../../aws/s3";
import { parseString } from 'xml2js';

const runRecords = async (
    parent: any,
    args: {},
    context: Context,
    info: any
): Promise<RunRecord[]> => {
    const records = await getRecordsFromBucket(toRunRecordsBucket, parent.id);
    const parsedRecords: RunRecord[] = [];

    // Parse each XML record to JSON
    for (const record of records) {
        parseString(record, (err, result) => {
            if (err) {
                console.error('Error parsing XML:', err);
                return;
            }
            const jsonRecord = JSON.stringify(result);
            parsedRecords.push(JSON.parse(jsonRecord));
        });
    }

    return parsedRecords;
};

export default runRecords;

