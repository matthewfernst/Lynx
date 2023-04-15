import { Context } from "../../index";
import { RunRecord } from "../../../types";
import { getRecordsFromBucket } from "../../s3";

const runRecords = async (
    parent: any,
    args: {},
    context: Context,
    info: any
): Promise<RunRecord[]> => {
    const records = await getRecordsFromBucket("mountain-ui-app-slopes-unzipped", parent.id);
    return records.map((record) => JSON.parse(record));
};

export default runRecords;
