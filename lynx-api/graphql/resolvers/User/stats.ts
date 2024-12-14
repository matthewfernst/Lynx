import { GraphQLResolveInfo } from "graphql";
import { DateTime } from "luxon";

import { DefinedUserContext } from "../../index";
import { User, UserStats } from "../../types";
import { Timeframe, leaderboardTimeframeFromQueryArgument } from "../Query/leaderboard";

interface Args {
    timeframe: keyof typeof Timeframe;
}

const stats = async (
    parent: User,
    args: Args,
    context: DefinedUserContext,
    _info: GraphQLResolveInfo
): Promise<UserStats | undefined> => {
    const timeframe = leaderboardTimeframeFromQueryArgument(
        DateTime.now(),
        Timeframe[args.timeframe]
    );
    return context.dataloaders.leaderboard.load({ id: parent.id, timeframe });
};

export default stats;
