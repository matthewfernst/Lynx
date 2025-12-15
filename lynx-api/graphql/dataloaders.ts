import { GetCommand } from "@aws-sdk/lib-dynamodb";
import DataLoader from "dataloader";
import { GraphQLError } from "graphql";
import { v5 as uuidv5 } from "uuid";

import {
  LEADERBOARD_TABLE,
  PARTIES_TABLE,
  PROFILE_PICS_BUCKET,
  SLOPES_UNZIPPED_BUCKET,
  USERS_TABLE,
} from "../infrastructure/stacks/lynxApiStack";

import { documentClient, getItem } from "./aws/dynamodb";
import {
  checkIfObjectInBucket,
  getObjectNamesInBucket,
  getRecordFromBucket,
} from "./aws/s3";
import { xmlToActivity, getOriginalFileName } from "./resolvers/User/logbook";
import {
  DEPENDENCY_ERROR,
  Party,
  DatabaseUser,
  UserStats,
  ParsedLog,
} from "./types";

// Namespace for generating deterministic UUIDs for leaderboard uniqueness-ids
export const LEADERBOARD_NAMESPACE = "8648700c-adf5-43c1-8262-64e5340b0969";

/**
 * Generates a deterministic UUID v5 for leaderboard uniqueness-id
 * Same timeframe + resort combination will always produce the same UUID
 */
export function generateUniquenessId(timeframe: string, resort: string): string {
  return uuidv5(`${timeframe}-${resort}`, LEADERBOARD_NAMESPACE);
}

export const usersDataLoader = new DataLoader(usersDataLoaderImpl);
export const partiesDataLoader = new DataLoader(partiesDataLoaderImpl);
export const leaderboardDataLoader = new DataLoader(leaderboardDataLoaderImpl, {
  cacheKeyFn: (key) => JSON.stringify(key),
});

function retrieveAllDataLoaders() {
  return {
    users: usersDataLoader,
    parties: partiesDataLoader,
    leaderboard: leaderboardDataLoader,
    logs: new DataLoader(logsDataLoader),
    profilePictures: new DataLoader(profilePictureDataloader, {
      cacheKeyFn: (user) => user.id,
    }),
  };
}

async function usersDataLoaderImpl(
  userIds: readonly string[],
): Promise<(DatabaseUser | undefined)[]> {
  return Promise.all(userIds.map((userId) => getItem(USERS_TABLE, userId)));
}

async function partiesDataLoaderImpl(
  partyIds: readonly string[],
): Promise<(Party | undefined)[]> {
  return Promise.all(
    partyIds.map((partyId) => getItem(PARTIES_TABLE, partyId)),
  );
}

async function leaderboardDataLoaderImpl(
  leaderboardTableKeys: readonly { id: string; timeframe: string; resort?: string }[],
) {
  return Promise.all(
    leaderboardTableKeys.map(async ({ id, timeframe, resort }) => {
      try {
        const resortValue = resort || "ALL";
        const uniquenessId = generateUniquenessId(timeframe, resortValue);
        const queryRequest = new GetCommand({
          TableName: LEADERBOARD_TABLE,
          Key: { id, "uniqueness-id": uniquenessId },
        });
        const itemOutput = await documentClient.send(queryRequest);
        console.log(
          `Retrieved leaderboard item for id ${id}, timeframe ${timeframe}, and resort ${resortValue}`,
        );
        return itemOutput.Item as UserStats;
      } catch (err) {
        console.error(err);
        throw new GraphQLError("DynamoDB Call Failed", {
          extensions: { code: DEPENDENCY_ERROR },
        });
      }
    }),
  );
}

export async function profilePictureDataloader(
  users: readonly DatabaseUser[],
): Promise<(string | null)[]> {
  return Promise.all(
    users.map(async (user) => {
      if (await checkIfObjectInBucket(PROFILE_PICS_BUCKET, user.id)) {
        console.info(`Found S3 profile picture for user ${user.id}`);
        return `https://${PROFILE_PICS_BUCKET}.s3.us-west-1.amazonaws.com/${user.id}`;
      } else if (user.profilePictureUrl) {
        return user.profilePictureUrl;
      } else {
        return null;
      }
    }),
  );
}

export async function logsDataLoader(
  userIds: readonly string[],
): Promise<ParsedLog[][]> {
  return Promise.all(
    userIds.map(async (userId) => {
      const recordNames = await getObjectNamesInBucket(
        SLOPES_UNZIPPED_BUCKET,
        userId,
      );
      return Promise.all(
        recordNames.map(async (path) => {
          const unzippedRecord = await getRecordFromBucket(
            SLOPES_UNZIPPED_BUCKET,
            path,
          );
          const activity = await xmlToActivity(unzippedRecord);
          activity.originalFileName = getOriginalFileName(path);
          return activity;
        }),
      );
    }),
  );
}

export default retrieveAllDataLoaders;
