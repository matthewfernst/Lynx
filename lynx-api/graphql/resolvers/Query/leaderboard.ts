import { Context } from "../../index";
import { User } from "../../types";
import { DYNAMODB_TABLE_USERS, scanAllItems } from "../../aws/dynamodb";
import { populateLogbookDataForUser } from "./selfLookup";

type LeaderboardSort = "DISTANCE" | "RUN_COUNT" | "TOP_SPEED" | "VERTICAL_DISTANCE";

interface Args {
    sortBy: LeaderboardSort;
    limit: number;
}

export const leaderboardSortTypesToQueryFields: { [key in LeaderboardSort]: string } = {
    DISTANCE: "distance",
    RUN_COUNT: "runCount",
    TOP_SPEED: "topSpeed",
    VERTICAL_DISTANCE: "verticalDistance"
};

const leaderboard = async (_: any, args: Args, context: Context, info: any): Promise<User[]> => {
    const scanOutput = await scanAllItems(DYNAMODB_TABLE_USERS);
    const rawUsers = scanOutput.Items as unknown[] as User[];
    const users = await Promise.all(
        rawUsers.map(async (user) => await populateLogbookDataForUser(user))
    );

    const sortProperty = leaderboardSortTypesToQueryFields[args.sortBy];
    return users
        .sort((a, b) => b.userStats!![sortProperty] - a.userStats!![sortProperty])
        .slice(0, args.limit || 5);
};

export default leaderboard;
