import { UpdateItemOutput } from "@aws-sdk/client-dynamodb";
import { UpdateCommand } from "@aws-sdk/lib-dynamodb";

import { createDocumentClient } from "../graphql/aws/dynamodb";
import { getRecordFromBucket } from "../graphql/aws/s3";
import { xmlToActivity } from "../graphql/resolvers/User/logbook";
import { leaderboardSortTypesToQueryFields } from "../graphql/resolvers/Query/leaderboard";

export async function handler(event: any, context: any) {
    for (const record of event.Records) {
        const bucket = decodeURIComponent(record.s3.bucket.name);
        const userId = decodeURIComponent(record.s3.object.key).split("/")[0];
        const unzippedRecord = await getRecordFromBucket(bucket, record.s3.object.key);
        const activity = await xmlToActivity(unzippedRecord);

        Object.values(leaderboardSortTypesToQueryFields).forEach(async (key) => {
            const activityKey = key == "verticalDistance" ? "vertical" : activity[key]
            await updateItem(userId, key, activityKey);
        })
    }
    return { statusCode: 200 };
}

export const updateItem = async (
    id: string,
    key: string,
    value: any
): Promise<UpdateItemOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Updating item in table lynx-users with id ${id}. Adding ${value} to ${key}`);
        const updateItemRequest = new UpdateCommand({
            TableName: "lynx-users",
            Key: { id },
            UpdateExpression: "set #updateKey = #updateKey + :value",
            ExpressionAttributeNames: { "#updateKey": key },
            ExpressionAttributeValues: { ":value": value },
            ReturnValues: "ALL_NEW"
        });
        return await documentClient.send(updateItemRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Update Call Failed");
    }
};
