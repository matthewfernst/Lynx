const getDefault = async (path: string) => {
    const module = await import(path);
    return module.default;
};

export default {
    Query: {
        selfLookup: await getDefault("./resolvers/Query/selfLookup"),
        userLookupById: await getDefault("./resolvers/Query/userLookupById"),
        leaderboard: await getDefault("./resolvers/Query/leaderboard")
    },
    Mutation: {
        createUserOrSignIn: await getDefault("./resolvers/Mutation/createUserOrSignIn"),
        combineOAuthAccounts: await getDefault("./resolvers/Mutation/combineOAuthAccounts"),
        createUserProfilePictureUploadUrl: await getDefault(
            "./resolvers/Mutation/createUserProfilePictureUploadUrl"
        ),
        createUserRecordUploadUrl: await getDefault(
            "./resolvers/Mutation/createUserRecordUploadUrl"
        ),
        deleteUser: await getDefault("./resolvers/Mutation/deleteUser"),
        editUser: await getDefault("./resolvers/Mutation/editUser"),
        createInviteKey: await getDefault("./resolvers/Mutation/createInviteKey"),
        resolveInviteKey: await getDefault("./resolvers/Mutation/resolveInviteKey"),
        createParty: await getDefault("./resolvers/Mutation/createParty"),
        deleteParty: await getDefault("./resolvers/Mutation/deleteParty"),
        createPartyInvite: await getDefault("./resolvers/Mutation/createPartyInvite"),
        deletePartyInvite: await getDefault("./resolvers/Mutation/deletePartyInvite"),
        removeUserFromParty: await getDefault("./resolvers/Mutation/removeUserFromParty"),
        joinParty: await getDefault("./resolvers/Mutation/joinParty"),
        leaveParty: await getDefault("./resolvers/Mutation/leaveParty")
    },
    User: {
        email: await getDefault("./resolvers/User/email"),
        oauthLoginIds: await getDefault("./resolvers/User/oauthLoginIds"),
        profilePictureUrl: await getDefault("./resolvers/User/profilePictureUrl"),
        stats: await getDefault("./resolvers/User/stats"),
        logbook: await getDefault("./resolvers/User/logbook"),
        parties: await getDefault("./resolvers/User/parties")
    },
    UserStats: {
        distance: await getDefault("./resolvers/UserStats/distance"),
        topSpeed: await getDefault("./resolvers/UserStats/topSpeed"),
        verticalDistance: await getDefault("./resolvers/UserStats/verticalDistance")
    },
    Log: {
        id: await getDefault("./resolvers/Log/id"),
        details: await getDefault("./resolvers/Log/details"),
        distance: await getDefault("./resolvers/Log/distance"),
        startDate: await getDefault("./resolvers/Log/startDate"),
        endDate: await getDefault("./resolvers/Log/endDate"),
        topSpeed: await getDefault("./resolvers/Log/topSpeed"),
        verticalDistance: await getDefault("./resolvers/Log/verticalDistance")
    },
    LogDetail: {
        type: await getDefault("./resolvers/LogDetail/type"),
        averageSpeed: await getDefault("./resolvers/LogDetail/averageSpeed"),
        distance: await getDefault("./resolvers/LogDetail/distance"),
        startDate: await getDefault("./resolvers/LogDetail/startDate"),
        endDate: await getDefault("./resolvers/LogDetail/endDate"),
        minAltitude: await getDefault("./resolvers/LogDetail/minAltitude"),
        maxAltitude: await getDefault("./resolvers/LogDetail/maxAltitude"),
        topSpeed: await getDefault("./resolvers/LogDetail/topSpeed"),
        topSpeedAltitude: await getDefault("./resolvers/LogDetail/topSpeedAltitude"),
        verticalDistance: await getDefault("./resolvers/LogDetail/verticalDistance")
    },
    Party: {
        partyManager: await getDefault("./resolvers/Party/partyManager"),
        users: await getDefault("./resolvers/Party/users"),
        leaderboard: await getDefault("./resolvers/Party/leaderboard")
    }
};
