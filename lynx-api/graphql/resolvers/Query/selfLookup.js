"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.populateLogbookDataForUser = void 0;
const dynamodb_1 = require("../../aws/dynamodb");
const logbook_1 = require("../User/logbook");
const selfLookup = async (_, args, context, info) => {
    if (!context.userId) {
        return null;
    }
    const queryOutput = await (0, dynamodb_1.getItem)(dynamodb_1.DYNAMODB_TABLE_USERS, context.userId);
    let userInformation = (0, dynamodb_1.getItemFromDynamoDBResult)(queryOutput);
    if (userInformation) {
        userInformation = await (0, exports.populateLogbookDataForUser)(userInformation);
    }
    return userInformation;
};
const populateLogbookDataForUser = async (user) => {
    const logbookInformation = await (0, logbook_1.getLogbookInformationFromS3)(user.id);
    const sumArray = (array) => array.reduce((a, b) => a + b, 0);
    const stats = {
        distance: sumArray(logbookInformation.map((log) => log.distance)),
        runCount: sumArray(logbookInformation.map((log) => log.runCount)),
        topSpeed: sumArray(logbookInformation.map((log) => log.topSpeed)),
        verticalDistance: sumArray(logbookInformation.map((log) => log.vertical))
    };
    user.userStats = stats;
    user.logbook = logbookInformation;
    return user;
};
exports.populateLogbookDataForUser = populateLogbookDataForUser;
exports.default = selfLookup;
