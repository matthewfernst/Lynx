import { GraphQLError } from "graphql";
import { parseStringPromise, processors } from "xml2js";

import { SLOPES_UNZIPPED_BUCKET } from "../../../infrastructure/lynxStack";
import { checkIsMe } from "../../auth";
import { getObjectNamesInBucket, getRecordFromBucket } from "../../aws/s3";
import { DefinedUserContext } from "../../index";
import { DEPENDENCY_ERROR, User } from "../../types";

export interface ParsedLog {
    attributes: {
        altitudeOffset: number;
        centerLat: number;
        centerLong: number;
        conditions: string;
        distance: number;
        duration: number;
        end: string;
        equipment: number;
        identifier: string;
        isFavorite: number;
        locationId: string;
        locationName: string;
        overrides: string;
        peakAltitude: number;
        processedByBuild: number;
        recordEnd: string;
        recordStart: string;
        rodeWith: string;
        runCount: number;
        source: number;
        sport: number;
        start: string;
        timeZoneOffset: number;
        topSpeed: number;
        vertical: number;
    };
    actions: {
        action: ParsedLogDetails[];
    }[];
    originalFileName: string;
}

export interface ParsedLogDetails {
    attributes: {
        avgSpeed: number;
        distance: number;
        duration: number;
        end: string;
        maxAlt: number;
        maxLat: number;
        maxLong: number;
        minAlt: number;
        minLat: string;
        minLong: string;
        minSpeed: number;
        numberOfType: number;
        start: string;
        topSpeed: number;
        topSpeedAlt: number;
        topSpeedLat: number;
        topSpeedLong: number;
        trackIDs: string;
        type: string;
        vertical: number;
    };
}

const logbook = async (
    parent: User,
    args: {},
    context: DefinedUserContext,
    info: any
): Promise<ParsedLog[]> => {
    checkIsMe(parent, context, "logbook");
    return context.dataloaders.logs.load(context.userId);
};

export const logsDataLoader = async (userIds: readonly string[]) => {
    return await Promise.all(
        userIds.map(async (userId) => {
            const recordNames = await getObjectNamesInBucket(SLOPES_UNZIPPED_BUCKET, userId);
            return await Promise.all(
                recordNames.map(async (path): Promise<ParsedLog> => {
                    const unzippedRecord = await getRecordFromBucket(SLOPES_UNZIPPED_BUCKET, path);
                    const activity = await xmlToActivity(unzippedRecord);
                    activity.originalFileName = getOriginalFileName(path);
                    return activity;
                })
            );
        })
    );
};

export const xmlToActivity = async (xml: string): Promise<ParsedLog> => {
    try {
        const parsedXML = await parseStringPromise(xml, {
            normalize: true,
            attrkey: "attributes",
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

const getOriginalFileName = (objectPath: string): string => {
    const objectName = objectPath.split("/").pop();
    if (!objectName) {
        throw new GraphQLError("Object Name Not Found", {
            extensions: { code: DEPENDENCY_ERROR, objectPath }
        });
    }
    return `${objectName.split(".")[0]}.slopes`;
};

export default logbook;
