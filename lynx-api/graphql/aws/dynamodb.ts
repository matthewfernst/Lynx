import { ApolloServerErrorCode } from "@apollo/server/errors";
import {
  ConditionalCheckFailedException,
  DynamoDB,
  ReturnValue,
} from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocument,
  DeleteCommand,
  GetCommand,
  UpdateCommand,
  PutCommand,
  QueryCommand,
} from "@aws-sdk/lib-dynamodb";
import { captureAWSv3Client } from "aws-xray-sdk-core";
import { GraphQLError } from "graphql";

import {
  USERS_TABLE,
  LEADERBOARD_TABLE,
  PARTIES_TABLE,
} from "../../infrastructure/stacks/lynxApiStack";
import {
  leaderboardDataLoader,
  partiesDataLoader,
  usersDataLoader,
} from "../dataloaders";
import {
  DEPENDENCY_ERROR,
  LeaderboardEntry,
  Party,
  DatabaseUser,
} from "../types";

export type Table =
  | typeof USERS_TABLE
  | typeof LEADERBOARD_TABLE
  | typeof PARTIES_TABLE;

// prettier-ignore
type TableDataLoader<T extends Table> =
  T extends typeof USERS_TABLE ? typeof usersDataLoader :
  T extends typeof PARTIES_TABLE ? typeof partiesDataLoader :
  T extends typeof LEADERBOARD_TABLE ? typeof leaderboardDataLoader :
  never;

// prettier-ignore
type TableObject<T extends Table> =
  T extends typeof USERS_TABLE ? DatabaseUser :
  T extends typeof LEADERBOARD_TABLE ? LeaderboardEntry :
  T extends typeof PARTIES_TABLE ? Party :
  unknown;

type TableArrayOptions = {
  uniqueValues: boolean;
};

if (!process.env.AWS_REGION)
  throw new GraphQLError("AWS_REGION Is Not Defined");
const awsClient = new DynamoDB({ region: process.env.AWS_REGION });
const dynamodbClient = captureAWSv3Client(awsClient);
export const documentClient = DynamoDBDocument.from(dynamodbClient);

function clearKeyFromTableDataLoader<T extends Table>(table: T, key: string) {
  const tableMapping: {
    [K in Table]: TableDataLoader<K>;
  } = {
    [USERS_TABLE]: usersDataLoader,
    [PARTIES_TABLE]: partiesDataLoader,
    [LEADERBOARD_TABLE]: leaderboardDataLoader,
  };
  const dataloader = tableMapping[table];
  // @ts-expect-error Can't infer DataLoader to key mapping through generics
  dataloader.clear(key);
}

export const getItem = async <T extends Table>(
  table: T,
  id: string,
): Promise<TableObject<T> | undefined> => {
  try {
    console.info(`Getting item from ${table} with id ${id}`);
    const getItemRequest = new GetCommand({ TableName: table, Key: { id } });
    const itemOutput = await documentClient.send(getItemRequest);
    return itemOutput.Item as TableObject<T> | undefined;
  } catch (err) {
    console.error(err);
    throw new GraphQLError("DynamoDB Get Call Failed", {
      extensions: { code: DEPENDENCY_ERROR },
    });
  }
};

export const getItemByIndex = async <T extends Table>(
  table: T,
  key: string,
  value: string,
): Promise<TableObject<T> | undefined> => {
  try {
    console.info(`Getting item from ${table} with ${key} ${value}`);
    const queryRequest = new QueryCommand({
      TableName: table,
      IndexName: key,
      KeyConditionExpression: "#indexKey = :value",
      ExpressionAttributeNames: { "#indexKey": key },
      ExpressionAttributeValues: { ":value": value },
    });
    const itemOutput = await documentClient.send(queryRequest);
    return itemOutput.Items?.[0] as TableObject<T> | undefined;
  } catch (err) {
    console.error(err);
    throw new GraphQLError("DynamoDB Query Call Failed", {
      extensions: { code: DEPENDENCY_ERROR },
    });
  }
};

export const putItem = async <T extends Table>(
  table: T,
  item: Partial<TableObject<T>>,
): Promise<TableObject<T>> => {
  try {
    console.info(`Putting item into ${table}`);
    const putItemRequest = new PutCommand({
      TableName: table,
      Item: item,
    });
    const itemOutput = await documentClient.send(putItemRequest);
    return itemOutput.Attributes as TableObject<T>;
  } catch (err) {
    console.error(err);
    throw new GraphQLError("DynamoDB Put Call Failed", {
      extensions: { code: DEPENDENCY_ERROR },
    });
  }
};

export const updateItem = async <T extends Table>(
  table: T,
  id: string,
  key: string,
  value: any,
): Promise<TableObject<T>> => {
  try {
    console.info(
      `Updating item in ${table} with id ${id}. New ${key} is ${value}`,
    );
    clearKeyFromTableDataLoader(table, key);
    const updateItemRequest = new UpdateCommand({
      TableName: table,
      Key: { id },
      UpdateExpression: "SET #updateKey = :value",
      ExpressionAttributeNames: { "#updateKey": key },
      ExpressionAttributeValues: { ":value": value },
      ReturnValues: "ALL_NEW",
    });
    const itemOutput = await documentClient.send(updateItemRequest);
    const object = itemOutput.Attributes as TableObject<T> | undefined;
    if (!object) {
      throw new GraphQLError("Called DynamoDB Without Validating Item Exists", {
        extensions: {
          code: ApolloServerErrorCode.INTERNAL_SERVER_ERROR,
          table,
          id,
        },
      });
    }
    return object;
  } catch (err) {
    console.error(err);
    throw new GraphQLError("DynamoDB Update Call Failed", {
      extensions: { code: DEPENDENCY_ERROR },
    });
  }
};

export async function addItemToArray<T extends Table>(
  table: T,
  id: string,
  key: string,
  value: any,
  options: TableArrayOptions = { uniqueValues: true },
): Promise<TableObject<T>> {
  console.debug(
    `Updating item in ${table} with id ${JSON.stringify(id)}. ${key} now has the following as a value: ${value.toString()}`,
  );
  clearKeyFromTableDataLoader(table, id);
  try {
    const updateItemRequest = new UpdateCommand({
      TableName: table,
      Key: { id },
      UpdateExpression:
        "SET #updateKey = list_append(if_not_exists(#updateKey, :empty_list), :value)",
      ...(options.uniqueValues && {
        ConditionExpression: "NOT contains (#updateKey, :value)",
      }),
      ExpressionAttributeNames: { "#updateKey": key },
      ExpressionAttributeValues: { ":empty_list": [], ":value": [value] },
      ReturnValues: "ALL_NEW",
    });
    const itemOutput = await documentClient.send(updateItemRequest);
    const object = itemOutput.Attributes as TableObject<T> | undefined;
    if (!object) {
      throw new Error("Called DynamoDB Without Validating Item Exists");
    }
    return object;
  } catch (err) {
    if (err instanceof ConditionalCheckFailedException) {
      console.info(err);
      throw new GraphQLError(
        `${value} Already Exists For ${JSON.stringify(id)} With Key ${key}`,
        {
          extensions: {
            code: ApolloServerErrorCode.BAD_REQUEST,
            table,
            key,
            value,
          },
        },
      );
    }
    console.error(err);
    throw new GraphQLError("DynamoDB Update Call Failed", {
      extensions: { code: DEPENDENCY_ERROR, table, key },
    });
  }
}

export async function addItemsToArray<T extends Table>(
  table: T,
  id: string,
  key: string,
  values: any[],
  options: TableArrayOptions = { uniqueValues: true },
): Promise<TableObject<T>> {
  let result;
  for (const value of values) {
    result = await addItemToArray(table, id, key, value, options);
  }
  return result!;
}

export const deleteItemsFromArray = async <T extends Table>(
  table: T,
  id: string,
  key: string,
  values: string[],
): Promise<TableObject<T>> => {
  try {
    console.info(
      `Updating item in ${table} with id ${id}. ${key} no longer has the following as values: ${values}`,
    );
    const item = await getItem(table, id);
    if (!item) {
      throw new GraphQLError("Error finding item for this userId", {
        extensions: { code: ApolloServerErrorCode.INTERNAL_SERVER_ERROR },
      });
    }
    const indices = values.map((value: string) =>
      (item as any)[key].indexOf(value),
    );
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
      ReturnValues: "ALL_NEW",
    });
    const itemOutput = await documentClient.send(updateItemRequest);
    const object = itemOutput.Attributes as TableObject<T> | undefined;
    if (!object) {
      throw new GraphQLError("Called DynamoDB Without Validating Item Exists", {
        extensions: {
          code: ApolloServerErrorCode.INTERNAL_SERVER_ERROR,
          table,
          id,
        },
      });
    }
    return object;
  } catch (err) {
    console.error(err);
    throw new GraphQLError("DynamoDB Update Call Failed", {
      extensions: { code: DEPENDENCY_ERROR },
    });
  }
};

export const deleteItem = async <T extends Table>(
  table: T,
  id: string,
): Promise<TableObject<T>> => {
  try {
    console.info(`Deleting item from ${table} with id ${id}`);
    const deleteItemRequest = new DeleteCommand({
      TableName: table,
      Key: { id },
      ReturnValues: "ALL_OLD",
    });
    const itemOutput = await documentClient.send(deleteItemRequest);
    const object = itemOutput.Attributes as TableObject<T> | undefined;
    if (!object) {
      throw new GraphQLError("Called DynamoDB Without Validating Item Exists", {
        extensions: {
          code: ApolloServerErrorCode.INTERNAL_SERVER_ERROR,
          table,
          id,
        },
      });
    }
    return object;
  } catch (err) {
    console.error(err);
    throw new GraphQLError("DynamoDB Delete Call Failed", {
      extensions: { code: DEPENDENCY_ERROR },
    });
  }
};

export const deleteAllItems = async <T extends Table>(
  table: T,
  id: string,
): Promise<TableObject<T>[]> => {
  try {
    console.info(`Deleting all items from ${table} with id ${id}`);
    const queryRequest = new QueryCommand({
      TableName: table,
      KeyConditionExpression: "#indexKey = :value",
      ExpressionAttributeNames: { "#indexKey": "id" },
      ExpressionAttributeValues: { ":value": id },
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
            extensions: {
              code: ApolloServerErrorCode.INTERNAL_SERVER_ERROR,
              table,
              id,
            },
          });
        }
        const deleteItemRequest = new DeleteCommand({
          TableName: table,
          Key: { id: item.id, [sortKey]: item[sortKey] },
          ReturnValues: "ALL_OLD",
        });
        const itemOutput = await documentClient.send(deleteItemRequest);
        return itemOutput.Attributes as TableObject<T>;
      }),
    );
  } catch (err) {
    console.error(err);
    throw new GraphQLError("DynamoDB Delete Call Failed", {
      extensions: { code: DEPENDENCY_ERROR },
    });
  }
};

const tableToSortKey: { [key in Table]: string | undefined } = {
  [USERS_TABLE]: undefined,
  [LEADERBOARD_TABLE]: "timeframe",
  [PARTIES_TABLE]: undefined,
};
