import { UpdateItemOutput } from "@aws-sdk/client-dynamodb";
import { UpdateCommand } from "@aws-sdk/lib-dynamodb";
import { S3Event } from "aws-lambda";
import { DateTime } from "luxon";

import { documentClient } from "../graphql/aws/dynamodb";
import { getRecordFromBucket } from "../graphql/aws/s3";
import { xmlToActivity } from "../graphql/dataloaders";
import {
    Timeframe,
    leaderboardSortTypesToQueryFields,
    leaderboardTimeframeFromQueryArgument
} from "../graphql/resolvers/Query/leaderboard";
import { LEADERBOARD_TABLE } from "../infrastructure/lynxStack";

const timeframes: Timeframe[] = ["DAY", "WEEK", "MONTH", "SEASON", "ALL_TIME"];

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
                        const value = activity[activityKey];
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
    try {
        const updateItemRequest = new UpdateCommand({
            TableName: LEADERBOARD_TABLE,
            Key: { id, timeframe: leaderboardTimeframeFromQueryArgument(endTime, timeframe) },
            UpdateExpression: generateUpdateExpression(timeframe, sortType),
            ExpressionAttributeNames: {
                "#updateKey": sortType,
                ...(timeframe !== "ALL_TIME" && { "#ttl": "ttl" })
            },
            ExpressionAttributeValues: {
                ":value": value,
                ...(timeframe !== "ALL_TIME" && { ":ttl": getTimeToLive(endTime, timeframe) })
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

const generateUpdateExpression = (timeframe: Timeframe, sortType: string) => {
    const updateExpression = isMaximumSortType(sortType)
        ? "SET #updateKey = :value"
        : "ADD #updateKey :value";
    if (timeframe !== "ALL_TIME") {
        const setTTL = "#ttl = :ttl";
        const ttlAddition = isMaximumSortType(sortType) ? `, ${setTTL}` : ` SET ${setTTL}`;
        return `${updateExpression}${ttlAddition}`;
    }
    return updateExpression;
};

const isMaximumSortType = (sortType: string) => sortType.includes("top");

const getTimeToLive = (endTime: DateTime, timeframe: Exclude<Timeframe, "ALL_TIME">): number => {
    switch (timeframe) {
        case "DAY":
            return endTime.startOf("day").plus({ days: 1 }).toSeconds();
        case "WEEK":
            return endTime.startOf("week").plus({ weeks: 1 }).toSeconds();
        case "MONTH":
            return endTime.startOf("month").plus({ months: 1 }).toSeconds();
        case "SEASON":
            if (endTime.month >= 8) {
                return endTime.startOf("year").plus({ years: 1, months: 8 }).toSeconds();
            } else {
                return endTime.startOf("year").plus({ months: 8 }).toSeconds();
            }
    }
};
