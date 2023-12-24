export default {
    Query: {
        selfLookup: import("./resolvers/Query/selfLookup"),
        userLookupById: import("./resolvers/Query/userLookupById"),
        leaderboard: import("./resolvers/Query/leaderboard")
    },
    Mutation: {
        createUserOrSignIn: import("./resolvers/Mutation/createUserOrSignIn"),
        combineOAuthAccounts: import("./resolvers/Mutation/combineOAuthAccounts"),
        createUserProfilePictureUploadUrl: import(
            "./resolvers/Mutation/createUserProfilePictureUploadUrl"
        ),
        createUserRecordUploadUrl: import("./resolvers/Mutation/createUserRecordUploadUrl"),
        deleteUser: import("./resolvers/Mutation/deleteUser"),
        editUser: import("./resolvers/Mutation/editUser"),
        createInviteKey: import("./resolvers/Mutation/createInviteKey"),
        resolveInviteKey: import("./resolvers/Mutation/resolveInviteKey"),
        createParty: import("./resolvers/Mutation/createParty"),
        deleteParty: import("./resolvers/Mutation/deleteParty"),
        createPartyInvite: import("./resolvers/Mutation/createPartyInvite"),
        deletePartyInvite: import("./resolvers/Mutation/deletePartyInvite"),
        removeUserFromParty: import("./resolvers/Mutation/removeUserFromParty"),
        joinParty: import("./resolvers/Mutation/joinParty"),
        leaveParty: import("./resolvers/Mutation/leaveParty")
    },
    User: {
        email: import("./resolvers/User/email"),
        oauthLoginIds: import("./resolvers/User/oauthLoginIds"),
        profilePictureUrl: import("./resolvers/User/profilePictureUrl"),
        stats: import("./resolvers/User/stats"),
        logbook: import("./resolvers/User/logbook"),
        parties: import("./resolvers/User/parties")
    },
    UserStats: {
        distance: import("./resolvers/UserStats/distance"),
        topSpeed: import("./resolvers/UserStats/topSpeed"),
        verticalDistance: import("./resolvers/UserStats/verticalDistance")
    },
    Log: {
        id: import("./resolvers/Log/id"),
        details: import("./resolvers/Log/details"),
        distance: import("./resolvers/Log/distance"),
        startDate: import("./resolvers/Log/startDate"),
        endDate: import("./resolvers/Log/endDate"),
        topSpeed: import("./resolvers/Log/topSpeed"),
        verticalDistance: import("./resolvers/Log/verticalDistance")
    },
    LogDetail: {
        type: import("./resolvers/LogDetail/type"),
        averageSpeed: import("./resolvers/LogDetail/averageSpeed"),
        distance: import("./resolvers/LogDetail/distance"),
        startDate: import("./resolvers/LogDetail/startDate"),
        endDate: import("./resolvers/LogDetail/endDate"),
        minAltitude: import("./resolvers/LogDetail/minAltitude"),
        maxAltitude: import("./resolvers/LogDetail/maxAltitude"),
        topSpeed: import("./resolvers/LogDetail/topSpeed"),
        topSpeedAltitude: import("./resolvers/LogDetail/topSpeedAltitude"),
        verticalDistance: import("./resolvers/LogDetail/verticalDistance")
    },
    Party: {
        partyManager: import("./resolvers/Party/partyManager"),
        users: import("./resolvers/Party/users"),
        leaderboard: import("./resolvers/Party/leaderboard")
    }
};
