import "dotenv/config";

import {
    DynamoDBClientConfig,
    DeleteItemOutput,
    GetItemOutput,
    PutItemOutput,
    QueryOutput,
    ScanOutput,
    UpdateItemOutput,
    DynamoDB
} from "@aws-sdk/client-dynamodb";
import {
    DynamoDBDocument,
    DeleteCommand,
    GetCommand,
    UpdateCommand,
    PutCommand,
    QueryCommand,
    ScanCommand
} from "@aws-sdk/lib-dynamodb";

import { Invite, User } from "../types";

type DynamoDBResult =
    | GetItemOutput
    | QueryOutput
    | PutItemOutput
    | UpdateItemOutput
    | DeleteItemOutput;

export const DYNAMODB_TABLE_NAME_USERS = "mountain-ui-app-users";
export const DYNAMODB_TABLE_NAME_INVITES = "mountain-ui-app-invites";

export type Table = typeof DYNAMODB_TABLE_NAME_USERS | typeof DYNAMODB_TABLE_NAME_INVITES;

const createDocumentClient = (): DynamoDBDocument => {
    if (!process.env.AWS_REGION) throw new Error("AWS_REGION Is Not Defined");

    const serviceConfigOptions: DynamoDBClientConfig = {
        region: process.env.AWS_REGION,
        ...(process.env.IS_OFFLINE && { endpoint: "http://localhost:8080" })
    };

    const dynamodbClient = new DynamoDB(serviceConfigOptions);
    return DynamoDBDocument.from(dynamodbClient);
};

export const getItem = async (table: Table, id: string): Promise<GetItemOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Getting item from table ${table} with id ${id}`);
        const getItemRequest = new GetCommand({ TableName: table, Key: { id } });
        return await documentClient.send(getItemRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Get Call Failed");
    }
};

export const getItemsByIndex = async (
    table: Table,
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
            ExpressionAttributeValues: { ":value": value }
        });
        return await documentClient.send(queryRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Query Call Failed");
    }
};

export const scanAllItems = async (table: Table): Promise<ScanOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Getting all items from table ${table}`);
        const scanRequest = new ScanCommand({ TableName: table });
        return await documentClient.send(scanRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Scan Call Failed");
    }
};

export const putItem = async (table: Table, item: Object): Promise<PutItemOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Putting item into table ${table}`);
        const putItemRequest = new PutCommand({
            TableName: table,
            Item: item,
            ReturnValues: "ALL_OLD"
        });
        return await documentClient.send(putItemRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Put Call Failed");
    }
};

export const updateItem = async (
    table: Table,
    id: string,
    key: string,
    value: any
): Promise<UpdateItemOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Updating item in table ${table} with id ${id}. New ${key} is ${value}`);
        const updateItemRequest = new UpdateCommand({
            TableName: table,
            Key: { id },
            UpdateExpression: "set #updateKey = :value",
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

export const addItemsToArray = async (
    table: Table,
    id: string,
    key: string,
    values: string[]
): Promise<UpdateItemOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(
            `Updating item in table ${table} with id ${id}. ${key} now has the following as values: ${values}`
        );
        const updateItemRequest = new UpdateCommand({
            TableName: table,
            Key: { id },
            UpdateExpression: "set #updateKey = list_append(#updateKey, :value)",
            ExpressionAttributeNames: { "#updateKey": key },
            ExpressionAttributeValues: { ":value": values },
            ReturnValues: "ALL_NEW"
        });
        return await documentClient.send(updateItemRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Update Call Failed");
    }
};

export const deleteItemsFromArray = async (
    table: Table,
    id: string,
    key: string,
    values: string[]
): Promise<UpdateItemOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(
            `Updating item in table ${table} with id ${id}. ${key} no longer has the following as values ${values}`
        );
        const item = getItemFromDynamoDBResult(await getItem(table, id));
        if (!item) {
            throw new Error("Error finding item for this userId");
        }
        const indices = item[key].map((listItem: string) => item[key].index(listItem));
        const updateItemRequest = new UpdateCommand({
            TableName: table,
            Key: { id },
            UpdateExpression:
                "remove " +
                indices.map((index: number, arrayIndex: number) => {
                    if (arrayIndex + 1 === indices.length) {
                        return `#updateKey[${index}]`;
                    }
                    return `#updateKey[${index}], `;
                }),
            ExpressionAttributeNames: { "#updateKey": key },
            ReturnValues: "ALL_NEW"
        });
        return await documentClient.send(updateItemRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Update Call Failed");
    }
};

export const deleteItem = async (table: Table, id: string): Promise<DeleteItemOutput> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Deleting item from table ${table} with id ${id}`);
        const deleteItemRequest = new DeleteCommand({
            TableName: table,
            Key: { id },
            ReturnValues: "ALL_OLD"
        });
        return await documentClient.send(deleteItemRequest);
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Delete Call Failed");
    }
};

export const getItemFromDynamoDBResult = (dynamodbResult: DynamoDBResult): User | Invite | null => {
    if ("Item" in dynamodbResult && dynamodbResult.Item) {
        return dynamodbResult.Item as any;
    }
    if ("Items" in dynamodbResult && dynamodbResult.Items) {
        return dynamodbResult.Items[0] as any;
    }
    if ("Attributes" in dynamodbResult && dynamodbResult.Attributes) {
        return dynamodbResult.Attributes as any;
    }
    return null;
};
