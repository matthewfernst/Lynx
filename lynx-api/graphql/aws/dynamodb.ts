import { DynamoDBClientConfig, DynamoDB } from "@aws-sdk/client-dynamodb";
import {
    DynamoDBDocument,
    DeleteCommand,
    GetCommand,
    UpdateCommand,
    PutCommand,
    QueryCommand
} from "@aws-sdk/lib-dynamodb";

import { Invite, LeaderboardEntry, Party, User } from "../types";

export const USERS_TABLE = "lynx-users";
export const LEADERBOARD_TABLE = "leaderboard-table";
export const INVITES_TABLE = "lynx-invites";
export const PARTIES_TABLE = "lynx-parties";

export type Table = 
    typeof USERS_TABLE |
    typeof LEADERBOARD_TABLE |
    typeof INVITES_TABLE |
    typeof PARTIES_TABLE;

type ObjectType<T extends Table> = 
    T extends typeof USERS_TABLE ? User :
    T extends typeof LEADERBOARD_TABLE ? LeaderboardEntry : 
    T extends typeof INVITES_TABLE ? Invite :
    T extends typeof PARTIES_TABLE ? Party :
    unknown;

export const createDocumentClient = (): DynamoDBDocument => {
    if (!process.env.AWS_REGION) throw new Error("AWS_REGION Is Not Defined");

    const serviceConfigOptions: DynamoDBClientConfig = {
        region: process.env.AWS_REGION,
        ...(process.env.IS_OFFLINE && { endpoint: "http://localhost:8080" })
    };

    const dynamodbClient = new DynamoDB(serviceConfigOptions);
    return DynamoDBDocument.from(dynamodbClient);
};

export const getItem = async <T extends Table>(
    table: T,
    id: string
): Promise<ObjectType<T> | undefined> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Getting item from ${table} with id ${id}`);
        const getItemRequest = new GetCommand({ TableName: table, Key: { id } });
        const itemOutput = await documentClient.send(getItemRequest);
        return itemOutput.Item as ObjectType<T> | undefined;
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Get Call Failed");
    }
};

export const getItemByIndex = async <T extends Table>(
    table: T,
    key: string,
    value: string
): Promise<ObjectType<T> | undefined> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Getting item from ${table} with ${key} ${value}`);
        const queryRequest = new QueryCommand({
            TableName: table,
            IndexName: key,
            KeyConditionExpression: "#indexKey = :value",
            ExpressionAttributeNames: { "#indexKey": key },
            ExpressionAttributeValues: { ":value": value }
        });
        const itemOutput = await documentClient.send(queryRequest);
        return itemOutput.Items?.[0] as ObjectType<T> | undefined;
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Query Call Failed");
    }
};

export const putItem = async <T extends Table>(
    table: T,
    item: Object
): Promise<ObjectType<T> | undefined> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Putting item into ${table}`);
        const putItemRequest = new PutCommand({
            TableName: table,
            Item: item,
            ReturnValues: "ALL_OLD"
        });
        const itemOutput = await documentClient.send(putItemRequest);
        return itemOutput.Attributes as ObjectType<T> | undefined;
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Put Call Failed");
    }
};

export const updateItem = async <T extends Table>(
    table: T,
    id: string,
    key: string,
    value: any
): Promise<ObjectType<T> | undefined> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Updating item in ${table} with id ${id}. New ${key} is ${value}`);
        const updateItemRequest = new UpdateCommand({
            TableName: table,
            Key: { id },
            UpdateExpression: "set #updateKey = :value",
            ExpressionAttributeNames: { "#updateKey": key },
            ExpressionAttributeValues: { ":value": value },
            ReturnValues: "ALL_NEW"
        });
        const itemOutput = await documentClient.send(updateItemRequest);
        return itemOutput.Attributes as ObjectType<T> | undefined;
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Update Call Failed");
    }
};

export const addItemsToArray = async <T extends Table>(
    table: T,
    id: string,
    key: string,
    values: string[]
): Promise<ObjectType<T> | undefined> => {
    const documentClient = createDocumentClient();
    try {
        console.log(
            `Updating item in ${table} with id ${id}. ${key} now has the following as values: ${values}`
        );
        const updateItemRequest = new UpdateCommand({
            TableName: table,
            Key: { id },
            UpdateExpression: "set #updateKey = list_append(#updateKey, :value)",
            ExpressionAttributeNames: { "#updateKey": key },
            ExpressionAttributeValues: { ":value": values },
            ReturnValues: "ALL_NEW"
        });
        const itemOutput = await documentClient.send(updateItemRequest);
        return itemOutput.Attributes as ObjectType<T> | undefined;
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Update Call Failed");
    }
};

export const deleteItemsFromArray = async <T extends Table>(
    table: T,
    id: string,
    key: string,
    values: string[]
): Promise<ObjectType<T> | undefined> => {
    const documentClient = createDocumentClient();
    try {
        console.log(
            `Updating item in ${table} with id ${id}. ${key} no longer has the following as values: ${values}`
        );
        const item = await getItem(table, id);
        if (!item) {
            throw new Error("Error finding item for this userId");
        }
        const indices = (item[key] as unknown as any[]).map((listItem: string) =>
            (item[key] as unknown as any[]).indexOf(listItem)
        );
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
        const itemOutput = await documentClient.send(updateItemRequest);
        return itemOutput.Attributes as ObjectType<T> | undefined;
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Update Call Failed");
    }
};

export const deleteItem = async <T extends Table>(
    table: T,
    id: string
): Promise<ObjectType<T> | undefined> => {
    const documentClient = createDocumentClient();
    try {
        console.log(`Deleting item from ${table} with id ${id}`);
        const deleteItemRequest = new DeleteCommand({
            TableName: table,
            Key: { id },
            ReturnValues: "ALL_OLD"
        });
        const itemOutput = await documentClient.send(deleteItemRequest);
        return itemOutput.Attributes as ObjectType<T> | undefined;
    } catch (err) {
        console.error(err);
        throw Error("DynamoDB Delete Call Failed");
    }
};
