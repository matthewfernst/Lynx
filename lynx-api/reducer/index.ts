import { UpdateItemOutput } from "@aws-sdk/client-dynamodb";
import { UpdateCommand } from "@aws-sdk/lib-dynamodb";
import { S3Event } from "aws-lambda";
import { DateTime } from "luxon";

import { documentClient } from "../graphql/aws/dynamodb";
import { getRecordFromBucket } from "../graphql/aws/s3";
import { xmlToActivity } from "../graphql/dataloaders";
import { leaderboardSortTypesToQueryFields } from "../graphql/resolvers/Query/leaderboard";
import { LEADERBOARD_TABLE } from "../infrastructure/lib/infrastructure";

const timeframes = ["day", "week", "month", "year", "all"] as const;
type Timeframe = (typeof timeframes)[number];

export async function handler(event: S3Event) {
    for (const record of event.Records) {
        const bucket = decodeURIComponent(record.s3.bucket.name);
        const objectKey = decodeURIComponent(record.s3.object.key).replaceAll("+", " ");

        console.log(`Retrieving unzipped record from ${bucket} with key ${objectKey}`);
        const unzippedRecord = await getRecordFromBucket(bucket, objectKey);
        const activity = await xmlToActivity(unzippedRecord);

        const userId = objectKey.split("/")[0];
        const endTime = DateTime.fromFormat(activity.end, "yyyy-MM-dd HH:mm:ss ZZZ");

        await Promise.all(
            timeframes.map(async (timeframe) => {
                const resultsForTimeframe = await Promise.all(
                    Object.values(leaderboardSortTypesToQueryFields).map(async (sortType) => {
                        const activityKey = sortType === "verticalDistance" ? "vertical" : sortType;
                        const value = activity[activityKey] as number;
                        return await updateItem(userId, endTime, timeframe, sortType, value);
                    })
                );
                console.log(`Successfully updated leaderboard for timeframe "${timeframe}".`);
                return resultsForTimeframe;
            })
        );
    }
}

const updateItem = async (
    id: string,
    endTime: DateTime,
    timeframe: Timeframe,
    sortType: string,
    value: number
): Promise<UpdateItemOutput> => {
    if (timeframe === "all") {
        return await updateAllTimeframe(id, sortType, value);
    }
    try {
        const updateTimeframe = `${timeframe}-${getNumericValue(endTime, timeframe)}`;
        const updateItemRequest = new UpdateCommand({
            TableName: LEADERBOARD_TABLE,
            Key: { id, timeframe: updateTimeframe },
            UpdateExpression: generateUpdateExpression(sortType),
            ExpressionAttributeNames: { "#updateKey": sortType, "#ttl": "ttl" },
            ExpressionAttributeValues: {
                ":value": value,
                ":ttl": getTimeToLive(endTime, timeframe)
            },
            ...(isMaximumSortType(sortType) && {
                ConditionExpression: "attribute_not_exists(#updateKey) OR #updateKey < :value"
            }),
            ReturnValues: "UPDATED_NEW"
        });
        return await documentClient.send(updateItemRequest);
    } catch (err) {
        console.error(err);
        throw new Error("DynamoDB Update Call Failed");
    }
};

const updateAllTimeframe = async (
    id: string,
    sortType: string,
    value: number
): Promise<UpdateItemOutput> => {
    try {
        const updateItemRequest = new UpdateCommand({
            TableName: LEADERBOARD_TABLE,
            Key: { id, timeframe: "all" },
            UpdateExpression: "ADD #updateKey :value",
            ExpressionAttributeNames: { "#updateKey": sortType },
            ExpressionAttributeValues: { ":value": value },
            ReturnValues: "UPDATED_NEW"
        });
        return await documentClient.send(updateItemRequest);
    } catch (err) {
        console.error(err);
        throw new Error("DynamoDB Update Call Failed");
    }
};

const generateUpdateExpression = (sortKey: string) => {
    if (isMaximumSortType(sortKey)) {
        return "SET #updateKey = :value, #ttl = :ttl";
    } else {
        return "ADD #updateKey :value SET #ttl = :ttl";
    }
};

const isMaximumSortType = (sortType: string) => {
    return sortType.includes("top");
};

const getNumericValue = (endTime: DateTime, timeframe: Exclude<Timeframe, "all">): number => {
    switch (timeframe) {
        case "day":
            return endTime.ordinal;
        case "week":
            return endTime.weekNumber;
        case "month":
            return endTime.month;
        case "year":
            return endTime.year;
    }
};

const getTimeToLive = (endTime: DateTime, timeframe: Exclude<Timeframe, "all">): number => {
    switch (timeframe) {
        case "day":
            return endTime.plus({ days: 1 }).toSeconds();
        case "week":
            return endTime.plus({ weeks: 1 }).toSeconds();
        case "month":
            return endTime.plus({ months: 1 }).toSeconds();
        case "year":
            return endTime.plus({ years: 1 }).toSeconds();
    }
};
