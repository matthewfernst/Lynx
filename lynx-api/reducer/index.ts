import { UpdateItemOutput } from "@aws-sdk/client-dynamodb";
import { UpdateCommand } from "@aws-sdk/lib-dynamodb";

import { LEADERBOARD_TABLE, createDocumentClient } from "../graphql/aws/dynamodb";
import { getRecordFromBucket } from "../graphql/aws/s3";
import { xmlToActivity } from "../graphql/resolvers/User/logbook";
import { leaderboardSortTypesToQueryFields } from "../graphql/resolvers/Query/leaderboard";
import { DateTime } from "luxon";

export async function handler(event: any, context: any) {
    for (const record of event.Records) {
        const bucket = decodeURIComponent(record.s3.bucket.name);
        const objectKey = decodeURIComponent(record.s3.object.key);

        console.log(`Retrieving unzipped record from ${bucket} with key ${objectKey}`);
        const unzippedRecord = await getRecordFromBucket(bucket, objectKey);
        const activity = await xmlToActivity(unzippedRecord);

        const userId = objectKey.split("/")[0];
        const timeframes = processTimeframes(activity.end);

        timeframes.forEach((timeframe) => {
            Object.values(leaderboardSortTypesToQueryFields).forEach(async (key) => {
                const value = key == "verticalDistance" ? activity.vertical : activity[key];
                await updateItem(userId, timeframe, key, value);
            });
        });
    }
    return { statusCode: 200 };
}

const processTimeframes = (activityEnd: string): string[] => {
    const time = DateTime.fromFormat(activityEnd, "yyyy-MM-dd HH:mm:ss ZZZ");
    return [
        `day-${time.ordinal}`,
        `week-${time.weekNumber}`,
        `month-${time.month}`,
        `year-${time.year}`,
        "all"
    ];
};

const updateItem = async (
    id: string,
    timeframe: string,
    key: string,
    value: any
): Promise<UpdateItemOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Updating item in table lynx-users with id ${id}. Adding ${value} to ${key}`);
        const updateItemRequest = new UpdateCommand({
            TableName: LEADERBOARD_TABLE,
            Key: { id, timeframe },
            UpdateExpression: "set #updateKey = #updateKey + :value",
            ExpressionAttributeNames: { "#updateKey": key },
            ExpressionAttributeValues: { ":value": value },
            ReturnValues: "UPDATED_NEW"
        });
        return await documentClient.send(updateItemRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Update Call Failed");
    }
};
