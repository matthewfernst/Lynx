import { ApolloServer } from "@apollo/server";
import { startServerAndCreateLambdaHandler, handlers } from "@as-integrations/aws-lambda";
import { loadSchemaSync } from "@graphql-tools/load";
import { GraphQLFileLoader } from "@graphql-tools/graphql-file-loader";
import dotenv from "dotenv";

import { authenticateHTTPAccessToken } from "./auth";
import createDataloaders from "./dataloaders";
import { INTERNAL_SERVER_ERROR } from "./types";

// @ts-expect-error - Uses ESBuild Plugin Unsupported By Typescript
import resolvers from "./resolvers/**/*";

export interface Context {
    userId: string | undefined;
    dataloaders: ReturnType<typeof createDataloaders>;
}

export interface DefinedUserContext extends Context {
    userId: string;
}

dotenv.config();

export const LOG_LEVEL = "info";
const server = new ApolloServer<Context>({
    typeDefs: loadSchemaSync(__dirname + "/schema.graphql", { loaders: [new GraphQLFileLoader()] }),
    resolvers,
    formatError: (err) => {
        if (err.extensions?.code === INTERNAL_SERVER_ERROR) {
            if (err.extensions) console.error(`${err.extensions.code}: ${err.message}`);
            else console.error(err);
        }
        if (process.env.IS_OFFLINE) {
            console.error(err);
        }
        return err;
    }
});

export const handler = startServerAndCreateLambdaHandler(
    server,
    handlers.createAPIGatewayProxyEventRequestHandler(),
    {
        context: async ({ event }) => ({
            userId: authenticateHTTPAccessToken(event),
            dataloaders: createDataloaders()
        }),
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
