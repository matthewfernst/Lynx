import { Context } from "../../index";
import { User, UserStats } from "../../types";
import { USERS_TABLE, getItem, getItemFromDynamoDBResult } from "../../aws/dynamodb";
import { getLogbookInformationFromS3 } from "../User/logbook";

const selfLookup = async (_: any, args: {}, context: Context, info: any): Promise<User | null> => {
    if (!context.userId) {
        return null;
    }
    const queryOutput = await getItem(USERS_TABLE, context.userId);
    let userInformation = getItemFromDynamoDBResult(queryOutput) as User | null;
    if (userInformation) {
        userInformation = await populateLogbookDataForUser(userInformation);
    }
    return userInformation;
};

export const populateLogbookDataForUser = async (user: User): Promise<User> => {
    const logbookInformation = await getLogbookInformationFromS3(user.id);
    const sumArray = (array: number[]) => array.reduce((a, b) => a + b, 0);
    const stats: UserStats = {
        distance: sumArray(logbookInformation.map((log) => log.distance)),
        runCount: sumArray(logbookInformation.map((log) => log.runCount)),
        topSpeed: sumArray(logbookInformation.map((log) => log.topSpeed)),
        verticalDistance: sumArray(logbookInformation.map((log) => log.vertical))
    };
    user.userStats = stats;
    user.logbook = logbookInformation;
    return user;
};

export default selfLookup;
