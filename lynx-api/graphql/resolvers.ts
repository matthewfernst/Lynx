import selfLookup from "./resolvers/Query/selfLookup";
import userLookupById from "./resolvers/Query/userLookupById";
import leaderboard from "./resolvers/Query/leaderboard";
import createUserOrSignIn from "./resolvers/Mutation/createUserOrSignIn";
import combineOAuthAccounts from "./resolvers/Mutation/combineOAuthAccounts";
import createUserProfilePictureUploadUrl from "./resolvers/Mutation/createUserProfilePictureUploadUrl";
import createUserRecordUploadUrl from "./resolvers/Mutation/createUserRecordUploadUrl";
import deleteUser from "./resolvers/Mutation/deleteUser";
import editUser from "./resolvers/Mutation/editUser";
import createInviteKey from "./resolvers/Mutation/createInviteKey";
import resolveInviteKey from "./resolvers/Mutation/resolveInviteKey";
import createParty from "./resolvers/Mutation/createParty";
import deleteParty from "./resolvers/Mutation/deleteParty";
import createPartyInvite from "./resolvers/Mutation/createPartyInvite";
import deletePartyInvite from "./resolvers/Mutation/deletePartyInvite";
import removeUserFromParty from "./resolvers/Mutation/removeUserFromParty";
import joinParty from "./resolvers/Mutation/joinParty";
import leaveParty from "./resolvers/Mutation/leaveParty";
import email from "./resolvers/User/email";
import oauthLoginIds from "./resolvers/User/oauthLoginIds";
import profilePictureUrl from "./resolvers/User/profilePictureUrl";
import stats from "./resolvers/User/stats";
import logbook from "./resolvers/User/logbook";
import parties from "./resolvers/User/parties";
import userStatsDistance from "./resolvers/UserStats/distance";
import userStatsTopSpeed from "./resolvers/UserStats/topSpeed";
import userStatsVerticalDistance from "./resolvers/UserStats/verticalDistance";
import id from "./resolvers/Log/id";
import details from "./resolvers/Log/details";
import logDistance from "./resolvers/Log/distance";
import logStartDate from "./resolvers/Log/startDate";
import logEndDate from "./resolvers/Log/endDate";
import logTopSpeed from "./resolvers/Log/topSpeed";
import logVerticalDistance from "./resolvers/Log/verticalDistance";
import logDetailType from "./resolvers/LogDetail/type";
import averageSpeed from "./resolvers/LogDetail/averageSpeed";
import logDetailDistance from "./resolvers/LogDetail/distance";
import logDetailStartDate from "./resolvers/LogDetail/startDate";
import logDetailEndDate from "./resolvers/LogDetail/endDate";
import minAltitude from "./resolvers/LogDetail/minAltitude";
import maxAltitude from "./resolvers/LogDetail/maxAltitude";
import logDetailTopSpeed from "./resolvers/LogDetail/topSpeed";
import topSpeedAltitude from "./resolvers/LogDetail/topSpeedAltitude";
import logDetailVerticalDistance from "./resolvers/LogDetail/verticalDistance";
import partyLeaderboard from "./resolvers/Party/leaderboard";
import partyUsers from "./resolvers/Party/users";
import partyManager from "./resolvers/Party/partyManager";

export const resolvers = {
    Query: { selfLookup, userLookupById, leaderboard },
    Mutation: {
        createUserOrSignIn,
        combineOAuthAccounts,
        createUserProfilePictureUploadUrl,
        createUserRecordUploadUrl,
        deleteUser,
        editUser,
        createInviteKey,
        resolveInviteKey,
        createParty,
        deleteParty,
        createPartyInvite,
        deletePartyInvite,
        removeUserFromParty,
        joinParty,
        leaveParty
    },
    User: { email, oauthLoginIds, profilePictureUrl, stats, logbook, parties },
    UserStats: {
        distance: userStatsDistance,
        topSpeed: userStatsTopSpeed,
        verticalDistance: userStatsVerticalDistance
    },
    Log: {
        id,
        details,
        distance: logDistance,
        startDate: logStartDate,
        endDate: logEndDate,
        topSpeed: logTopSpeed,
        verticalDistance: logVerticalDistance
    },
    LogDetail: {
        type: logDetailType,
        averageSpeed,
        distance: logDetailDistance,
        startDate: logDetailStartDate,
        endDate: logDetailEndDate,
        minAltitude,
        maxAltitude,
        topSpeed: logDetailTopSpeed,
        topSpeedAltitude,
        verticalDistance: logDetailVerticalDistance
    },
    Party: {
        partyManager: partyManager,
        users: partyUsers,
        leaderboard: partyLeaderboard
    }
};
