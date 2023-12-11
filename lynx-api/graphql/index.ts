import "dotenv/config";

import { ApolloServer } from "apollo-server-lambda";

import typeDefs from "./schema.graphql";

import { authenticateHTTPAccessToken } from "./auth";
import { resolvers } from "./resolvers";

export interface Context {
    userId: string | null;
}

const server = new ApolloServer({
    typeDefs,
    resolvers,
    formatError: (err) => {
        if (!err.extensions) {
            throw Error("Extensions Object Does Not Exist On Error");
        }
        if (err.extensions.code === "INTERNAL_SERVER_ERROR") {
            if (err.extensions) console.error(`${err.extensions.code}: ${err.message}`);
            else console.error(err);
        }
        if (process.env.IS_OFFLINE) {
            console.log(err);
        }
        return err;
    },
    context: async ({ express }): Promise<Context> => ({
        userId: authenticateHTTPAccessToken(express.req)
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
