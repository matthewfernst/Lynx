import { Context } from "../../index";
import { RunRecord } from "../../types";
import { getRecordsFromBucket, toRunRecordsBucket } from "../../aws/s3";

const runRecords = async (
    parent: any,
    args: {},
    context: Context,
    info: any
): Promise<RunRecord[]> => {
    const records = await getRecordsFromBucket(toRunRecordsBucket, parent.id);
    return records.map((record) => JSON.parse(record));
};

export default runRecords;
