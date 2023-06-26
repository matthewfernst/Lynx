import { Context } from "../../index";
import { User } from "../../types";
import { DYNAMODB_TABLE_NAME_USERS, scanAllItems } from "../../aws/dynamodb";
import logbook from "../User/logbook";

type LeaderboardSort = "DISTANCE" | "RUN_COUNT" | "TOP_SPEED" | "VERTICAL_DISTANCE";

interface Args {
    sortBy: LeaderboardSort;
    limit: number;
}

const leaderboard = async (_: any, args: Args, context: Context, info: any): Promise<User[]> => {
    const scanOutput = await scanAllItems(DYNAMODB_TABLE_NAME_USERS);
    const users = scanOutput.Items as User[];

    const usersWithPulledLogBook = await Promise.all(
        users.map(async (user) => {
            const logs = await logbook({ id: user.id }, {}, context, {});
            const sumArray = (array) => array.reduce((a, b) => a + b, 0);
            return {
                ...user,
                distance: sumArray(logs.map((log) => log.distance)),
                runCount: sumArray(logs.map((log) => log.runCount)),
                topSpeed: sumArray(logs.map((log) => log.topSpeed)),
                verticalDistance: sumArray(logs.map((log) => log.vertical))
            };
        })
    );

    const sortProperty = getSortProperty(args.sortBy);
    return usersWithPulledLogBook
        .sort((a, b) => a[sortProperty] - b[sortProperty])
        .slice(0, args.limit || 5);
};

const getSortProperty = (type: LeaderboardSort) => {
    switch (type) {
        case "DISTANCE":
            return "distance";
        case "RUN_COUNT":
            return "runCount";
        case "TOP_SPEED":
            return "topSpeed";
        case "VERTICAL_DISTANCE":
            return "verticalDistance";
    }
};

export default leaderboard;
