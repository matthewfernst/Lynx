import { captureAWSv3Client } from "aws-xray-sdk";
import { DynamoDBClientConfig, DynamoDB } from "@aws-sdk/client-dynamodb";
import {
    DynamoDBDocument,
    DeleteCommand,
    GetCommand,
    UpdateCommand,
    PutCommand,
    QueryCommand
} from "@aws-sdk/lib-dynamodb";
import { GraphQLError } from "graphql";

import {
    USERS_TABLE,
    LEADERBOARD_TABLE,
    INVITES_TABLE,
    PARTIES_TABLE
} from "../../infrastructure/lynxStack";
import { LOG_LEVEL } from "../types";
import {
    DEPENDENCY_ERROR,
    INTERNAL_SERVER_ERROR,
    Invite,
    LeaderboardEntry,
    Party,
    User
} from "../types";

export type Table =
    | typeof USERS_TABLE
    | typeof LEADERBOARD_TABLE
    | typeof INVITES_TABLE
    | typeof PARTIES_TABLE;

type ObjectType<T extends Table> = 
    T extends typeof USERS_TABLE ? User :
    T extends typeof LEADERBOARD_TABLE ? LeaderboardEntry :
    T extends typeof INVITES_TABLE ? Invite :
    T extends typeof PARTIES_TABLE ? Party :
    unknown;

if (!process.env.AWS_REGION) throw new GraphQLError("AWS_REGION Is Not Defined");

const serviceConfigOptions: DynamoDBClientConfig = {
    region: process.env.AWS_REGION,
    ...(process.env.IS_OFFLINE && { endpoint: "http://localhost:8080" })
};

const awsClient = new DynamoDB(serviceConfigOptions);
const dynamodbClient = captureAWSv3Client(awsClient)
export const documentClient = DynamoDBDocument.from(dynamodbClient);

export const getItem = async <T extends Table>(
    table: T,
    id: string
): Promise<ObjectType<T> | undefined> => {
    try {
        console[LOG_LEVEL](`Getting item from ${table} with id ${id}`);
        const getItemRequest = new GetCommand({ TableName: table, Key: { id } });
        const itemOutput = await documentClient.send(getItemRequest);
        return itemOutput.Item as ObjectType<T> | undefined;
    } catch (err) {
        console.error(err);
        throw new GraphQLError("DynamoDB Get Call Failed", {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export const getItemByIndex = async <T extends Table>(
    table: T,
    key: string,
    value: string
): Promise<ObjectType<T> | undefined> => {
    try {
        console[LOG_LEVEL](`Getting item from ${table} with ${key} ${value}`);
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
        throw new GraphQLError("DynamoDB Query Call Failed", {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export const putItem = async <T extends Table>(table: T, item: Object): Promise<ObjectType<T>> => {
    try {
        console[LOG_LEVEL](`Putting item into ${table}`);
        const putItemRequest = new PutCommand({
            TableName: table,
            Item: item,
            ReturnValues: "ALL_OLD"
        });
        const itemOutput = await documentClient.send(putItemRequest);
        return itemOutput.Attributes as ObjectType<T>;
    } catch (err) {
        console.error(err);
        throw new GraphQLError("DynamoDB Put Call Failed", {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export const updateItem = async <T extends Table>(
    table: T,
    id: string,
    key: string,
    value: any
): Promise<ObjectType<T>> => {
    try {
        console[LOG_LEVEL](`Updating item in ${table} with id ${id}. New ${key} is ${value}`);
        const updateItemRequest = new UpdateCommand({
            TableName: table,
            Key: { id },
            UpdateExpression: "SET #updateKey = :value",
            ExpressionAttributeNames: { "#updateKey": key },
            ExpressionAttributeValues: { ":value": value },
            ReturnValues: "ALL_NEW"
        });
        const itemOutput = await documentClient.send(updateItemRequest);
        const object = itemOutput.Attributes as ObjectType<T> | undefined;
        if (!object) {
            throw new GraphQLError("Called DynamoDB Without Validating Item Exists", {
                extensions: { code: INTERNAL_SERVER_ERROR, table, id }
            });
        }
        return object;
    } catch (err) {
        console.error(err);
        throw new GraphQLError("DynamoDB Update Call Failed", {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export const addItemsToArray = async <T extends Table>(
    table: T,
    id: string,
    key: string,
    values: string[]
): Promise<ObjectType<T>> => {
    try {
        console[LOG_LEVEL](
            `Updating item in ${table} with id ${id}. ${key} now has the following as values: ${values}`
        );
        const updateItemRequest = new UpdateCommand({
            TableName: table,
            Key: { id },
            UpdateExpression:
                "SET #updateKey = list_append(if_not_exists(#updateKey, :empty_list), :value)",
            ExpressionAttributeNames: { "#updateKey": key },
            ExpressionAttributeValues: { empty_list: [], ":value": values },
            ReturnValues: "ALL_NEW"
        });
        const itemOutput = await documentClient.send(updateItemRequest);
        const object = itemOutput.Attributes as ObjectType<T> | undefined;
        if (!object) {
            throw new GraphQLError("Called DynamoDB Without Validating Item Exists", {
                extensions: { code: INTERNAL_SERVER_ERROR, table, id }
            });
        }
        return object;
    } catch (err) {
        console.error(err);
        throw new GraphQLError("DynamoDB Update Call Failed", {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export const deleteItemsFromArray = async <T extends Table>(
    table: T,
    id: string,
    key: string,
    values: string[]
): Promise<ObjectType<T>> => {
    try {
        console[LOG_LEVEL](
            `Updating item in ${table} with id ${id}. ${key} no longer has the following as values: ${values}`
        );
        const item = await getItem(table, id);
        if (!item) {
            throw new GraphQLError("Error finding item for this userId", {
                extensions: { code: INTERNAL_SERVER_ERROR }
            });
        }
        const indices = values.map((value: string) => (item as any)[key].indexOf(value));
        const updateItemRequest = new UpdateCommand({
            TableName: table,
            Key: { id },
            UpdateExpression:
                "REMOVE " +
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
        const object = itemOutput.Attributes as ObjectType<T> | undefined;
        if (!object) {
            throw new GraphQLError("Called DynamoDB Without Validating Item Exists", {
                extensions: { code: INTERNAL_SERVER_ERROR, table, id }
            });
        }
        return object;
    } catch (err) {
        console.error(err);
        throw new GraphQLError("DynamoDB Update Call Failed", {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export const deleteItem = async <T extends Table>(table: T, id: string): Promise<ObjectType<T>> => {
    try {
        console[LOG_LEVEL](`Deleting item from ${table} with id ${id}`);
        const deleteItemRequest = new DeleteCommand({
            TableName: table,
            Key: { id },
            ReturnValues: "ALL_OLD"
        });
        const itemOutput = await documentClient.send(deleteItemRequest);
        const object = itemOutput.Attributes as ObjectType<T> | undefined;
        if (!object) {
            throw new GraphQLError("Called DynamoDB Without Validating Item Exists", {
                extensions: { code: INTERNAL_SERVER_ERROR, table, id }
            });
        }
        return object;
    } catch (err) {
        console.error(err);
        throw new GraphQLError("DynamoDB Delete Call Failed", {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

export const deleteAllItems = async <T extends Table>(
    table: T,
    id: string
): Promise<ObjectType<T>[]> => {
    try {
        console[LOG_LEVEL](`Deleting all items from ${table} with id ${id}`);
        const queryRequest = new QueryCommand({
            TableName: table,
            KeyConditionExpression: "#indexKey = :value",
            ExpressionAttributeNames: { "#indexKey": "id" },
            ExpressionAttributeValues: { ":value": id }
        });
        const allItemsWithId = await documentClient.send(queryRequest);
        if (!allItemsWithId.Items) {
            return [];
        }
        return Promise.all(
            allItemsWithId.Items.map(async (item) => {
                const sortKey = tableToSortKey[table];
                if (!sortKey) {
                    throw new GraphQLError("Called Wrong DynamoDB Delete", {
                        extensions: { code: INTERNAL_SERVER_ERROR, table, id }
                    });
                }
                const deleteItemRequest = new DeleteCommand({
                    TableName: table,
                    Key: { id: item.id, [sortKey]: item[sortKey] },
                    ReturnValues: "ALL_OLD"
                });
                const itemOutput = await documentClient.send(deleteItemRequest);
                return itemOutput.Attributes as ObjectType<T>;
            })
        );
    } catch (err) {
        console.error(err);
        throw new GraphQLError("DynamoDB Delete Call Failed", {
            extensions: { code: DEPENDENCY_ERROR }
        });
    }
};

const tableToSortKey: { [key in Table]: string | undefined } = {
    [USERS_TABLE]: undefined,
    [LEADERBOARD_TABLE]: "timeframe",
    [INVITES_TABLE]: undefined,
    [PARTIES_TABLE]: undefined
};
