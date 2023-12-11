"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
require("dotenv/config");
const apollo_server_lambda_1 = require("apollo-server-lambda");
const schema_graphql_1 = __importDefault(require("./schema.graphql"));
const auth_1 = require("./auth");
const resolvers_1 = require("./resolvers");
const server = new apollo_server_lambda_1.ApolloServer({
    typeDefs: schema_graphql_1.default,
    resolvers: resolvers_1.resolvers,
    formatError: (err) => {
        if (!err.extensions) {
            throw Error("Extensions Object Does Not Exist On Error");
        }
        if (err.extensions.code === "INTERNAL_SERVER_ERROR") {
            if (err.extensions)
                console.error(`${err.extensions.code}: ${err.message}`);
            else
                console.error(err);
        }
        if (process.env.IS_OFFLINE) {
            console.log(err);
        }
        return err;
    },
    context: async ({ express }) => ({
        userId: (0, auth_1.authenticateHTTPAccessToken)(express.req)
    })
});
exports.handler = server.createHandler({
    expressGetMiddlewareOptions: {
        cors: {
            origin: true,
            credentials: true
        }
    }
});
