import { Context } from "../../index";
import { User, UserStats } from "../../types";
import { USERS_TABLE, getItem } from "../../aws/dynamodb";
import { getLogbookInformationFromS3 } from "../User/logbook";
import { checkHasUserId } from "../../auth";

const selfLookup = async (
    _: any,
    args: {},
    context: Context,
    info: any
): Promise<User | undefined> => {
    const userId = checkHasUserId(context.userId);
    let userInformation = await getItem(USERS_TABLE, userId);
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
