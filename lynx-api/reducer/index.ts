import { ConditionalCheckFailedException, UpdateItemOutput } from "@aws-sdk/client-dynamodb";
import { UpdateCommand } from "@aws-sdk/lib-dynamodb";
import { S3Event } from "aws-lambda";
import { DateTime } from "luxon";

import { LEADERBOARD_TABLE } from "../infrastructure/stacks/lynxApiStack";

import { documentClient } from "../graphql/aws/dynamodb";
import { getRecordFromBucket } from "../graphql/aws/s3";
import { generateUniquenessId } from "../graphql/dataloaders";
import {
    Timeframe,
    leaderboardSortTypesToQueryFields,
    leaderboardTimeframeFromQueryArgument
} from "../graphql/resolvers/Query/leaderboard";
import { getSeasonEnd, xmlToActivity } from "../graphql/resolvers/User/logbook";

const timeframes = [
    Timeframe.DAY,
    Timeframe.WEEK,
    Timeframe.MONTH,
    Timeframe.SEASON,
    Timeframe.ALL_TIME
];

export async function handler(event: S3Event) {
    for (const record of event.Records) {
        const bucket = decodeURIComponent(record.s3.bucket.name);
        const objectKey = decodeURIComponent(record.s3.object.key).replaceAll("+", " ");

        console.info(`Retrieving unzipped record from ${bucket} with key ${objectKey}`);
        const unzippedRecord = await getRecordFromBucket(bucket, objectKey);
        const activity = await xmlToActivity(unzippedRecord);

        const userId = objectKey.split("/")[0];
        const endTime = DateTime.fromFormat(activity.attributes.end, "yyyy-MM-dd HH:mm:ss ZZZ");
        const resorts = ["ALL", activity.attributes.locationName];

        await Promise.all(
            timeframes.map(async (timeframe) => {
                const resultsForTimeframe = await Promise.all(
                    resorts.flatMap(async (resortValue) =>
                        await updateAllMetrics(activity, userId, endTime, timeframe, resortValue)
                    )
                );
                console.info(
                    `Successfully updated leaderboard for timeframe "${Timeframe[timeframe]}".`
                );
                return resultsForTimeframe;
            })
        );
    }
}

async function updateAllMetrics(
    activity: any,
    userId: string,
    endTime: DateTime,
    timeframe: Timeframe,
    resortValue: string
) {
    return Object.values(leaderboardSortTypesToQueryFields).map(async (sortType) => {
        const activityKey = sortType === "verticalDistance" ? "vertical" : sortType;
        const value = activity.attributes[activityKey];
        return await updateItem(userId, endTime, timeframe, resortValue, sortType, value);
    });
}

async function updateItem(
    id: string,
    endTime: DateTime,
    timeframe: Timeframe,
    resort: string,
    sortType: string,
    value: number,
): Promise<UpdateItemOutput | undefined> {
    const timeframeKey = leaderboardTimeframeFromQueryArgument(endTime, timeframe);
    try {
        const uniquenessId = generateUniquenessId(timeframeKey, resort);
        const updateItemRequest = new UpdateCommand({
            TableName: LEADERBOARD_TABLE,
            Key: { id, "uniqueness-id": uniquenessId },
            UpdateExpression: generateUpdateExpression(timeframe, sortType),
            ExpressionAttributeNames: {
                "#timeframe": "timeframe",
                "#resort": "resort",
                "#updateKey": sortType,
                ...(timeframe !== Timeframe.ALL_TIME && { "#ttl": "ttl" })
            },
            ExpressionAttributeValues: {
                ":timeframe": timeframeKey,
                ":resort": resort,
                ":value": value,
                ...(timeframe !== Timeframe.ALL_TIME && {
                    ":ttl": getTimeToLive(endTime, timeframe)
                })
            },
            ...(isMaximumSortType(sortType) && {
                ConditionExpression: "attribute_not_exists(#updateKey) OR #updateKey < :value"
            }),
            ReturnValues: "UPDATED_NEW"
        });
        return await documentClient.send(updateItemRequest);
    } catch (err: unknown) {
        if (err instanceof ConditionalCheckFailedException) {
            console.info(
                `Skipped update for ${sortType} because ${sortType} is not a new maximum.`
            );
            return;
        }
        console.error(err);
        throw new Error("DynamoDB Update Call Failed");
    }
}

function generateUpdateExpression(timeframe: Timeframe, sortType: string) {
    const ttl = timeframe !== Timeframe.ALL_TIME ? ", #ttl = :ttl" : "";

    return isMaximumSortType(sortType)
        ? `SET #timeframe = :timeframe, #resort = :resort${ttl}, #updateKey = :value`
        : `SET #timeframe = :timeframe, #resort = :resort${ttl} ADD #updateKey :value`;
}

const isMaximumSortType = (sortType: string) => sortType.includes("top");

function getTimeToLive(
    endTime: DateTime,
    timeframe: Exclude<Timeframe, Timeframe.ALL_TIME>
): number {
    switch (timeframe) {
        case Timeframe.DAY:
            return endTime.startOf("day").plus({ days: 1 }).toSeconds();
        case Timeframe.WEEK:
            return endTime.startOf("week").plus({ weeks: 1 }).toSeconds();
        case Timeframe.MONTH:
            return endTime.startOf("month").plus({ months: 1 }).toSeconds();
        case Timeframe.SEASON:
            return getSeasonEnd(endTime).toSeconds();
    }
}
