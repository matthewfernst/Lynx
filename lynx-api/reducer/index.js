"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateItem = exports.handler = void 0;
const lib_dynamodb_1 = require("@aws-sdk/lib-dynamodb");
const dynamodb_1 = require("../graphql/aws/dynamodb");
const s3_1 = require("../graphql/aws/s3");
const logbook_1 = require("../graphql/resolvers/User/logbook");
const leaderboard_1 = require("../graphql/resolvers/Query/leaderboard");
async function handler(event, context) {
    for (const record of event.Records) {
        const bucket = decodeURIComponent(record.s3.bucket.name);
        const userId = decodeURIComponent(record.s3.object.key).split("/")[0];
        const unzippedRecord = await (0, s3_1.getRecordFromBucket)(bucket, record.s3.object.key);
        const activity = await (0, logbook_1.xmlToActivity)(unzippedRecord);
        Object.values(leaderboard_1.leaderboardSortTypesToQueryFields).forEach(async (key) => {
            const activityKey = key == "verticalDistance" ? "vertical" : activity[key];
            await (0, exports.updateItem)(userId, key, activityKey);
        });
    }
    return { statusCode: 200 };
}
exports.handler = handler;
const updateItem = async (id, key, value) => {
    const documentClient = (0, dynamodb_1.createDocumentClient)();
    try {
        console.log(`Updating item in table lynx-users with id ${id}. Adding ${value} to ${key}`);
        const updateItemRequest = new lib_dynamodb_1.UpdateCommand({
            TableName: "lynx-users",
            Key: { id },
            UpdateExpression: "set #updateKey = #updateKey + :value",
            ExpressionAttributeNames: { "#updateKey": key },
            ExpressionAttributeValues: { ":value": value },
            ReturnValues: "ALL_NEW"
        });
        return await documentClient.send(updateItemRequest);
    }
    catch (err) {
        console.error(err);
        throw Error("DynamoDB Update Call Failed");
    }
};
exports.updateItem = updateItem;
