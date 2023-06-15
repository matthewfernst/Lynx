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
  return Promise.all(records.map(async (record) => await parseString(record) as RunRecord)):
};

export default runRecords;
