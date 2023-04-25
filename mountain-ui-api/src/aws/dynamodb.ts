import "dotenv/config";

import {
    DynamoDBClient,
    DynamoDBClientConfig,
    DeleteItemOutput,
    GetItemCommand,
    GetItemOutput,
    PutItemOutput,
    QueryOutput,
    UpdateItemOutput,
    QueryCommand,
    PutItemCommand,
    UpdateItemCommand,
    DeleteItemCommand
} from "@aws-sdk/client-dynamodb";

import { User } from "../types";

type DynamoDBResult =
    | GetItemOutput
    | QueryOutput
    | PutItemOutput
    | UpdateItemOutput
    | DeleteItemOutput;

export const DYNAMODB_TABLE_NAME_USERS = "mountain-ui-app-users";

const createDocumentClient = (): DynamoDBClient => {
    if (!process.env.AWS_REGION) throw new Error("AWS_REGION Is Not Defined");

    const serviceConfigOptions: DynamoDBClientConfig = {
        region: process.env.AWS_REGION,
        ...(process.env.IS_OFFLINE && { endpoint: "http://localhost:8080" })
    };

    return new DynamoDBClient(serviceConfigOptions);
};

export const getItem = async (table: string, id: string): Promise<GetItemOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Getting item from table ${table} with id ${id}`);
        const getItemRequest = new GetItemCommand({ TableName: table, Key: { id: { S: id } } });
        return await documentClient.send(getItemRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Get Call Failed");
    }
};

export const getItemsByIndex = async (
    table: string,
    key: string,
    value: string
): Promise<QueryOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Getting item from table ${table} with ${key} ${value}`);
        const queryRequest = new QueryCommand({
            TableName: table,
            IndexName: key,
            KeyConditionExpression: "#indexKey = :value",
            ExpressionAttributeNames: { "#indexKey": key },
            ExpressionAttributeValues: { ":value": { S: value } }
        });
        return await documentClient.send(queryRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Query Call Failed");
    }
};

export const putItem = async (table: string, item: Object): Promise<PutItemOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Putting item into table ${table}`);
        const putItemRequest = new PutItemCommand({
            TableName: table,
            Item: Object.assign(
                {},
                ...Object.keys(item).map((key: string) => ({
                    [key]: {
                        S: item[key]
                    }
                }))
            ),
            ReturnValues: "ALL_OLD"
        });
        return await documentClient.send(putItemRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Put Call Failed");
    }
};

export const updateItem = async (
    table: string,
    id: string,
    key: string,
    value: string
): Promise<UpdateItemOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Updating item in table ${table} with id ${id}. New ${key} is ${value}`);
        const updateItemRequest = new UpdateItemCommand({
            TableName: table,
            Key: { id: { S: id } },
            UpdateExpression: "set #updateKey = :value",
            ExpressionAttributeNames: { "#updateKey": key },
            ExpressionAttributeValues: { ":value": { S: value } },
            ReturnValues: "ALL_NEW"
        });
        return await documentClient.send(updateItemRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Update Call Failed");
    }
};

export const deleteItem = async (table: string, id: string): Promise<DeleteItemOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Deleting item from table ${table} with id ${id}`);
        const deleteItemRequest = new DeleteItemCommand({
            TableName: table,
            Key: { id: { S: id } },
            ReturnValues: "ALL_OLD"
        });
        return await documentClient.send(deleteItemRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Delete Call Failed");
    }
};

export const getItemFromDynamoDBResult = (dynamodbResult: DynamoDBResult): User | null => {
    if ("Item" in dynamodbResult && dynamodbResult.Item) {
        return dynamodbResult.Item as unknown as User;
    }
    if ("Items" in dynamodbResult && dynamodbResult.Items) {
        return dynamodbResult.Items[0] as unknown as User;
    }
    if ("Attributes" in dynamodbResult && dynamodbResult.Attributes) {
        return dynamodbResult.Attributes as unknown as User;
    }
    return null;
};
