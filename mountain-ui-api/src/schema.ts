import fs from "fs";
import path from "path";

import { gql } from "apollo-server-express";

import { buildSchema } from "graphql";

const schema = fs.readFileSync(path.join(__dirname, "../../schema.graphql"), "utf8");
export const typeDefs = gql(schema);
export const gqlSchema = buildSchema(schema);

import selfLookup from "./resolvers/Query/selfLookup";
import runRecords from "./resolvers/User/runRecords";

export const resolvers = {
    Query: { selfLookup },
    User: { runRecords },
    RunRecord: {}
};