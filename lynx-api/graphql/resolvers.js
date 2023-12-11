"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolvers = void 0;
const selfLookup_1 = __importDefault(require("./resolvers/Query/selfLookup"));
const userLookupById_1 = __importDefault(require("./resolvers/Query/userLookupById"));
const leaderboard_1 = __importDefault(require("./resolvers/Query/leaderboard"));
const createUserOrSignIn_1 = __importDefault(require("./resolvers/Mutation/createUserOrSignIn"));
const combineOAuthAccounts_1 = __importDefault(require("./resolvers/Mutation/combineOAuthAccounts"));
const createUserProfilePictureUploadUrl_1 = __importDefault(require("./resolvers/Mutation/createUserProfilePictureUploadUrl"));
const createUserRecordUploadUrl_1 = __importDefault(require("./resolvers/Mutation/createUserRecordUploadUrl"));
const deleteUser_1 = __importDefault(require("./resolvers/Mutation/deleteUser"));
const editUser_1 = __importDefault(require("./resolvers/Mutation/editUser"));
const createInviteKey_1 = __importDefault(require("./resolvers/Mutation/createInviteKey"));
const resolveInviteKey_1 = __importDefault(require("./resolvers/Mutation/resolveInviteKey"));
const email_1 = __importDefault(require("./resolvers/User/email"));
const oauthLoginIds_1 = __importDefault(require("./resolvers/User/oauthLoginIds"));
const profilePictureUrl_1 = __importDefault(require("./resolvers/User/profilePictureUrl"));
const logbook_1 = __importDefault(require("./resolvers/User/logbook"));
const distance_1 = __importDefault(require("./resolvers/UserStats/distance"));
const topSpeed_1 = __importDefault(require("./resolvers/UserStats/topSpeed"));
const verticalDistance_1 = __importDefault(require("./resolvers/UserStats/verticalDistance"));
const id_1 = __importDefault(require("./resolvers/Log/id"));
const details_1 = __importDefault(require("./resolvers/Log/details"));
const distance_2 = __importDefault(require("./resolvers/Log/distance"));
const startDate_1 = __importDefault(require("./resolvers/Log/startDate"));
const endDate_1 = __importDefault(require("./resolvers/Log/endDate"));
const topSpeed_2 = __importDefault(require("./resolvers/Log/topSpeed"));
const verticalDistance_2 = __importDefault(require("./resolvers/Log/verticalDistance"));
const type_1 = __importDefault(require("./resolvers/LogDetail/type"));
const averageSpeed_1 = __importDefault(require("./resolvers/LogDetail/averageSpeed"));
const distance_3 = __importDefault(require("./resolvers/LogDetail/distance"));
const startDate_2 = __importDefault(require("./resolvers/LogDetail/startDate"));
const endDate_2 = __importDefault(require("./resolvers/LogDetail/endDate"));
const minAltitude_1 = __importDefault(require("./resolvers/LogDetail/minAltitude"));
const maxAltitude_1 = __importDefault(require("./resolvers/LogDetail/maxAltitude"));
const topSpeed_3 = __importDefault(require("./resolvers/LogDetail/topSpeed"));
const topSpeedAltitude_1 = __importDefault(require("./resolvers/LogDetail/topSpeedAltitude"));
const verticalDistance_3 = __importDefault(require("./resolvers/LogDetail/verticalDistance"));
exports.resolvers = {
    Query: { selfLookup: selfLookup_1.default, userLookupById: userLookupById_1.default, leaderboard: leaderboard_1.default },
    Mutation: {
        createUserOrSignIn: createUserOrSignIn_1.default,
        combineOAuthAccounts: combineOAuthAccounts_1.default,
        createUserProfilePictureUploadUrl: createUserProfilePictureUploadUrl_1.default,
        createUserRecordUploadUrl: createUserRecordUploadUrl_1.default,
        deleteUser: deleteUser_1.default,
        editUser: editUser_1.default,
        createInviteKey: createInviteKey_1.default,
        resolveInviteKey: resolveInviteKey_1.default
    },
    User: { email: email_1.default, oauthLoginIds: oauthLoginIds_1.default, profilePictureUrl: profilePictureUrl_1.default, logbook: logbook_1.default },
    UserStats: {
        distance: distance_1.default,
        topSpeed: topSpeed_1.default,
        verticalDistance: verticalDistance_1.default
    },
    Log: {
        id: id_1.default,
        details: details_1.default,
        distance: distance_2.default,
        startDate: startDate_1.default,
        endDate: endDate_1.default,
        topSpeed: topSpeed_2.default,
        verticalDistance: verticalDistance_2.default
    },
    LogDetail: {
        type: type_1.default,
        averageSpeed: averageSpeed_1.default,
        distance: distance_3.default,
        startDate: startDate_2.default,
        endDate: endDate_2.default,
        minAltitude: minAltitude_1.default,
        maxAltitude: maxAltitude_1.default,
        topSpeed: topSpeed_3.default,
        topSpeedAltitude: topSpeedAltitude_1.default,
        verticalDistance: verticalDistance_3.default
    }
};
