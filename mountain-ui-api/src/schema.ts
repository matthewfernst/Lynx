import fs from "fs";
import path from "path";

import { gql } from "apollo-server-express";

import { buildSchema } from "graphql";

const schema = fs.readFileSync(path.join(__dirname, "../schema.graphql"), "utf8");
export const typeDefs = gql(schema);
export const gqlSchema = buildSchema(schema);

import selfLookup from "./resolvers/Query/selfLookup";
import userLookup from "./resolvers/Query/userLookup";
import leaderboard from "./resolvers/Query/leaderboard";
import createUserOrSignIn from "./resolvers/Mutation/createUserOrSignIn";
import combineOAuthAccounts from "./resolvers/Mutation/combineOAuthAccounts";
import createUserProfilePictureUploadUrl from "./resolvers/Mutation/createUserProfilePictureUploadUrl";
import createUserRecordUploadUrl from "./resolvers/Mutation/createUserRecordUploadUrl";
import deleteUser from "./resolvers/Mutation/deleteUser";
import editUser from "./resolvers/Mutation/editUser";
import createInviteKey from "./resolvers/Mutation/createInviteKey";
import resolveInviteKey from "./resolvers/Mutation/resolveInviteKey";
import email from "./resolvers/User/email";
import profilePictureUrl from "./resolvers/User/profilePictureUrl";
import logbook from "./resolvers/User/logbook";
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

export const resolvers = {
    Query: { selfLookup, userLookup, leaderboard },
    Mutation: {
        createUserOrSignIn,
        combineOAuthAccounts,
        createUserProfilePictureUploadUrl,
        createUserRecordUploadUrl,
        deleteUser,
        editUser,
        createInviteKey,
        resolveInviteKey
    },
    User: { email, profilePictureUrl, logbook },
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
    }
};
