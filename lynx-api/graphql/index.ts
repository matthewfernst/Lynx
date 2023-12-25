import dotenv from "dotenv";

import { ApolloServer } from "@apollo/server";
import { startServerAndCreateLambdaHandler, handlers } from "@as-integrations/aws-lambda";
import { loadSchemaSync } from "@graphql-tools/load";
import { GraphQLFileLoader } from "@graphql-tools/graphql-file-loader";

import { authenticateHTTPAccessToken } from "./auth";
import dataloaders from "./dataloaders";

// @ts-expect-error - Uses ESBuild Plugin Unsupported By Typescript
import resolvers from "./resolvers/**/*";

export interface Context {
    userId: string | undefined;
    dataloaders: typeof dataloaders;
}

export const BAD_REQUEST = "BAD_REQUEST";
export const UNAUTHENTICATED = "UNAUTHENTICATED";
export const FORBIDDEN = "FORBIDDEN";
export const DEPENDENCY_ERROR = "DEPENDENCY_ERROR";
export const INTERNAL_SERVER_ERROR = "INTERNAL_SERVER_ERROR";

dotenv.config();

const server = new ApolloServer<Context>({
    typeDefs: loadSchemaSync(__dirname + "/schema.graphql", { loaders: [new GraphQLFileLoader()] }),
    resolvers,
    formatError: (err) => {
        if (err.extensions?.code === INTERNAL_SERVER_ERROR) {
            if (err.extensions) console.error(`${err.extensions.code}: ${err.message}`);
            else console.error(err);
        }
        if (process.env.IS_OFFLINE) {
            console.log(err);
        }
        return err;
    }
});

export const handler = startServerAndCreateLambdaHandler(
    server,
    handlers.createAPIGatewayProxyEventRequestHandler(),
    {
        context: async ({ event }) => ({ userId: authenticateHTTPAccessToken(event), dataloaders }),
        middleware: [
            async (event) => {
                return async (result) => {
                    result.headers = {
                        "Access-Control-Allow-Origin": event.headers.Origin || "*",
                        ...result.headers
                    };
                };
            }
        ]
    }
);
