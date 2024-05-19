import { DateTime } from "luxon";

import { DefinedUserContext } from "../../index";
import { UserStats } from "../../types";
import { Timeframe, leaderboardTimeframeFromQueryArgument } from "../Query/leaderboard";

interface Parent {
    id: string;
}

interface Args {
    timeframe: keyof typeof Timeframe;
}

const stats = async (
    parent: Parent,
    args: Args,
    context: DefinedUserContext,
    info: any
): Promise<UserStats | undefined> => {
    const timeframe = leaderboardTimeframeFromQueryArgument(
        DateTime.now(),
        Timeframe[args.timeframe]
    );
    const stats = await context.dataloaders.leaderboard.load({ id: parent.id, timeframe });
    console.log(`Finished retrieving stats for user ${parent.id}: ${stats}`);
    return stats;
};

export default stats;
