"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.leaderboardSortTypesToQueryFields = void 0;
const dynamodb_1 = require("../../aws/dynamodb");
const selfLookup_1 = require("./selfLookup");
exports.leaderboardSortTypesToQueryFields = {
    DISTANCE: "distance",
    RUN_COUNT: "runCount",
    TOP_SPEED: "topSpeed",
    VERTICAL_DISTANCE: "verticalDistance"
};
const leaderboard = async (_, args, context, info) => {
    const scanOutput = await (0, dynamodb_1.scanAllItems)(dynamodb_1.DYNAMODB_TABLE_USERS);
    const rawUsers = scanOutput.Items;
    const users = await Promise.all(rawUsers.map(async (user) => await (0, selfLookup_1.populateLogbookDataForUser)(user)));
    const sortProperty = exports.leaderboardSortTypesToQueryFields[args.sortBy];
    return users
        .sort((a, b) => b.userStats[sortProperty] - a.userStats[sortProperty])
        .slice(0, args.limit || 5);
};
exports.default = leaderboard;
