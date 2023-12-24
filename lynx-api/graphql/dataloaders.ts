import DataLoader from "dataloader";

async function batchLoadUsers(userIds: readonly string[]) {
    return userIds.map((key) => key);
}

async function batchLoadLogs(logIds: readonly string[]) {
    return logIds.map((key) => key);
}

export default {
    users: new DataLoader(batchLoadUsers),
    logs: new DataLoader(batchLoadLogs)
};
