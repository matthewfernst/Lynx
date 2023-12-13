import { Context } from "../../index";
import { User } from "../../types";
import { USERS_TABLE, getItemsByIndex } from "../../aws/dynamodb";
import { populateLogbookDataForUser } from "./selfLookup";

type LeaderboardSort = "DISTANCE" | "RUN_COUNT" | "TOP_SPEED" | "VERTICAL_DISTANCE";

interface Args {
    sortBy: LeaderboardSort;
    limit: number;
}

export const LEADERBOARD_PARTITIONS = 2;
export const leaderboardSortTypesToQueryFields: { [key in LeaderboardSort]: string } = {
    DISTANCE: "distance",
    RUN_COUNT: "runCount",
    TOP_SPEED: "topSpeed",
    VERTICAL_DISTANCE: "verticalDistance"
};

const leaderboard = async (_: any, args: Args, context: Context, info: any): Promise<User[]> => {
    const usersByPartition = (
        await Promise.all(
            [...Array(LEADERBOARD_PARTITIONS).keys()].map(async (partition) => {
                return await getItemsByIndex(
                    USERS_TABLE,
                    partition,
                    leaderboardSortTypesToQueryFields[args.sortBy],
                    args.limit,
                    false
                );
            })
        )
    )
        .flat()
        .sort(
            (a, b) =>
                (b[leaderboardSortTypesToQueryFields[args.sortBy]] as number) -
                (a[leaderboardSortTypesToQueryFields[args.sortBy]] as number)
        )
        .slice(0, args.limit);
    return await Promise.all(
        usersByPartition.map(async (user) => await populateLogbookDataForUser(user))
    );
};

export default leaderboard;
