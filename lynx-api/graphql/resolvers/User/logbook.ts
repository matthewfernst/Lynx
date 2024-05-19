import { GraphQLError } from "graphql";
import { parseStringPromise, processors } from "xml2js";

import { SLOPES_UNZIPPED_BUCKET } from "../../../infrastructure/lynxStack";
import { checkIsMe } from "../../auth";
import { getObjectNamesInBucket, getRecordFromBucket } from "../../aws/s3";
import { DefinedUserContext } from "../../index";
import { DEPENDENCY_ERROR, Log, User } from "../../types";

const logbook = async (
    parent: User,
    args: {},
    context: DefinedUserContext,
    info: any
): Promise<Log[]> => {
    checkIsMe(parent, context, "logbook");
    return await context.dataloaders.logs.load(context.userId);
};

export const logsDataLoader = async (userIds: readonly string[]) => {
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

export default logbook;
