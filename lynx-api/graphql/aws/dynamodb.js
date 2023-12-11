"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getItemFromDynamoDBResult = exports.deleteItem = exports.deleteItemsFromArray = exports.addItemsToArray = exports.updateItem = exports.putItem = exports.scanAllItems = exports.getItemsByIndex = exports.getItem = exports.createDocumentClient = exports.DYNAMODB_TABLE_INVITES = exports.DYNAMODB_TABLE_USERS = void 0;
const client_dynamodb_1 = require("@aws-sdk/client-dynamodb");
const lib_dynamodb_1 = require("@aws-sdk/lib-dynamodb");
exports.DYNAMODB_TABLE_USERS = "lynx-users";
exports.DYNAMODB_TABLE_INVITES = "lynx-invites";
const createDocumentClient = () => {
    if (!process.env.AWS_REGION)
        throw new Error("AWS_REGION Is Not Defined");
    const serviceConfigOptions = {
        region: process.env.AWS_REGION,
        ...(process.env.IS_OFFLINE && { endpoint: "http://localhost:8080" })
    };
    const dynamodbClient = new client_dynamodb_1.DynamoDB(serviceConfigOptions);
    return lib_dynamodb_1.DynamoDBDocument.from(dynamodbClient);
};
exports.createDocumentClient = createDocumentClient;
const getItem = async (table, id) => {
    const documentClient = (0, exports.createDocumentClient)();
    try {
        console.log(`Getting item from table ${table} with id ${id}`);
        const getItemRequest = new lib_dynamodb_1.GetCommand({ TableName: table, Key: { id } });
        return await documentClient.send(getItemRequest);
    }
    catch (err) {
        console.error(err);
        throw Error("DynamoDB Get Call Failed");
    }
};
exports.getItem = getItem;
const getItemsByIndex = async (table, key, value) => {
    const documentClient = (0, exports.createDocumentClient)();
    try {
        console.log(`Getting item from table ${table} with ${key} ${value}`);
        const queryRequest = new lib_dynamodb_1.QueryCommand({
            TableName: table,
            IndexName: key,
            KeyConditionExpression: "#indexKey = :value",
            ExpressionAttributeNames: { "#indexKey": key },
            ExpressionAttributeValues: { ":value": value }
        });
        return await documentClient.send(queryRequest);
    }
    catch (err) {
        console.error(err);
        throw Error("DynamoDB Query Call Failed");
    }
};
exports.getItemsByIndex = getItemsByIndex;
const scanAllItems = async (table) => {
    const documentClient = (0, exports.createDocumentClient)();
    try {
        console.log(`Getting all items from table ${table}`);
        const scanRequest = new lib_dynamodb_1.ScanCommand({ TableName: table });
        return await documentClient.send(scanRequest);
    }
    catch (err) {
        console.error(err);
        throw Error("DynamoDB Scan Call Failed");
    }
};
exports.scanAllItems = scanAllItems;
const putItem = async (table, item) => {
    const documentClient = (0, exports.createDocumentClient)();
    try {
        console.log(`Putting item into table ${table}`);
        const putItemRequest = new lib_dynamodb_1.PutCommand({
            TableName: table,
            Item: item,
            ReturnValues: "ALL_OLD"
        });
        return await documentClient.send(putItemRequest);
    }
    catch (err) {
        console.error(err);
        throw Error("DynamoDB Put Call Failed");
    }
};
exports.putItem = putItem;
const updateItem = async (table, id, key, value) => {
    const documentClient = (0, exports.createDocumentClient)();
    try {
        console.log(`Updating item in table ${table} with id ${id}. New ${key} is ${value}`);
        const updateItemRequest = new lib_dynamodb_1.UpdateCommand({
            TableName: table,
            Key: { id },
            UpdateExpression: "set #updateKey = :value",
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
const addItemsToArray = async (table, id, key, values) => {
    const documentClient = (0, exports.createDocumentClient)();
    try {
        console.log(`Updating item in table ${table} with id ${id}. ${key} now has the following as values: ${values}`);
        const updateItemRequest = new lib_dynamodb_1.UpdateCommand({
            TableName: table,
            Key: { id },
            UpdateExpression: "set #updateKey = list_append(#updateKey, :value)",
            ExpressionAttributeNames: { "#updateKey": key },
            ExpressionAttributeValues: { ":value": values },
            ReturnValues: "ALL_NEW"
        });
        return await documentClient.send(updateItemRequest);
    }
    catch (err) {
        console.error(err);
        throw Error("DynamoDB Update Call Failed");
    }
};
exports.addItemsToArray = addItemsToArray;
const deleteItemsFromArray = async (table, id, key, values) => {
    const documentClient = (0, exports.createDocumentClient)();
    try {
        console.log(`Updating item in table ${table} with id ${id}. ${key} no longer has the following as values ${values}`);
        const item = (0, exports.getItemFromDynamoDBResult)(await (0, exports.getItem)(table, id));
        if (!item) {
            throw new Error("Error finding item for this userId");
        }
        const indices = item[key].map((listItem) => item[key].indexOf(listItem));
        const updateItemRequest = new lib_dynamodb_1.UpdateCommand({
            TableName: table,
            Key: { id },
            UpdateExpression: "remove " +
                indices.map((index, arrayIndex) => {
                    if (arrayIndex + 1 === indices.length) {
                        return `#updateKey[${index}]`;
                    }
                    return `#updateKey[${index}], `;
                }),
            ExpressionAttributeNames: { "#updateKey": key },
            ReturnValues: "ALL_NEW"
        });
        return await documentClient.send(updateItemRequest);
    }
    catch (err) {
        console.error(err);
        throw Error("DynamoDB Update Call Failed");
    }
};
exports.deleteItemsFromArray = deleteItemsFromArray;
const deleteItem = async (table, id) => {
    const documentClient = (0, exports.createDocumentClient)();
    try {
        console.log(`Deleting item from table ${table} with id ${id}`);
        const deleteItemRequest = new lib_dynamodb_1.DeleteCommand({
            TableName: table,
            Key: { id },
            ReturnValues: "ALL_OLD"
        });
        return await documentClient.send(deleteItemRequest);
    }
    catch (err) {
        console.error(err);
        throw Error("DynamoDB Delete Call Failed");
    }
};
exports.deleteItem = deleteItem;
const getItemFromDynamoDBResult = (dynamodbResult) => {
    if ("Item" in dynamodbResult && dynamodbResult.Item) {
        return dynamodbResult.Item;
    }
    if ("Items" in dynamodbResult && dynamodbResult.Items) {
        return dynamodbResult.Items[0];
    }
    if ("Attributes" in dynamodbResult && dynamodbResult.Attributes) {
        return dynamodbResult.Attributes;
    }
    return null;
};
exports.getItemFromDynamoDBResult = getItemFromDynamoDBResult;
