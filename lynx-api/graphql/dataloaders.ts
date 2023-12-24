import DataLoader from "dataloader";

import { getItem } from "./aws/dynamodb";
import { USERS_TABLE } from "../infrastructure/lib/infrastructure";

export const usersDataLoader = new DataLoader(async (userIds: readonly string[]) =>
    userIds.map(async (userId) => await getItem(USERS_TABLE, userId))
);

export const logsDataLoader = new DataLoader(async (logIds: readonly string[]) =>
    logIds.map(async (logId) => await getItem(USERS_TABLE, logId))
);

export default { users: usersDataLoader, logs: logsDataLoader };
