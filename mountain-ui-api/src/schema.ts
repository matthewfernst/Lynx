import fs from "fs";
import path from "path";

import { gql } from "apollo-server-express";

import { buildSchema } from "graphql";

const schema = fs.readFileSync(path.join(__dirname, "../schema.graphql"), "utf8");
export const typeDefs = gql(schema);
export const gqlSchema = buildSchema(schema);

import createUserOrSignIn from "./resolvers/Mutation/createUserOrSignIn";
import createUserProfilePictureUploadUrl from "./resolvers/Mutation/createUserProfilePictureUploadUrl";
import createUserRecordUploadUrl from "./resolvers/Mutation/createUserRecordUploadUrl";
import deleteUser from "./resolvers/Mutation/deleteUser";
import editUser from "./resolvers/Mutation/editUser";
import requestFriend from "./resolvers/Mutation/requestFriend";
import resolveRequestFriend from "./resolvers/Mutation/resolveRequestFriend";
import selfLookup from "./resolvers/Query/selfLookup";
import userLookup from "./resolvers/Query/userLookup";
import email from "./resolvers/User/email";
import friends from "./resolvers/User/friends";
import profilePictureUrl from "./resolvers/User/profilePictureUrl";
import runRecords from "./resolvers/User/runRecords";

export const resolvers = {
    Query: { selfLookup, userLookup },
    Mutation: {
        createUserOrSignIn,
        createUserProfilePictureUploadUrl,
        createUserRecordUploadUrl,
        deleteUser,
        editUser,
        requestFriend,
        resolveRequestFriend
    },
    User: { email, friends, profilePictureUrl, runRecords }
};
