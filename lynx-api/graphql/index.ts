import { ApolloServer, GraphQLRequest } from "@apollo/server";
import { ApolloServerErrorCode } from "@apollo/server/errors";
import { startStandaloneServer } from "@apollo/server/standalone";
import { startServerAndCreateLambdaHandler, handlers } from "@as-integrations/aws-lambda";
import { loadSchemaSync } from "@graphql-tools/load";
import { GraphQLFileLoader } from "@graphql-tools/graphql-file-loader";
import dotenv from "dotenv";
import { getOperationAST, GraphQLError, OperationTypeNode, parse } from "graphql";

import { authenticateHTTPAccessToken } from "./auth";
import createDataloaders from "./dataloaders";
import resolvers from "./resolvers";

export interface Context {
    userId: string | null;
    dataloaders: ReturnType<typeof createDataloaders>;
}

export interface DefinedUserContext extends Context {
    userId: string;
}

dotenv.config();

const isProduction = process.env.NODE_ENV === "production";
const schemaPath = isProduction
    ? __dirname + "/schema.graphql"
    : __dirname + "../../Lynx-SwiftUI" + "/schema.graphql";
const server = new ApolloServer<Context>({
    typeDefs: loadSchemaSync(schemaPath, { loaders: [new GraphQLFileLoader()] }),
    resolvers,
    formatError: (err) => {
        if (err.extensions?.code === ApolloServerErrorCode.INTERNAL_SERVER_ERROR) {
            if (err.extensions) console.error(`${err.extensions.code}: ${err.message}`);
            else console.error(err);
        }
        if (process.env.IS_OFFLINE) {
            console.error(err);
        }
        return err;
    }
});

async function runDevelopmentServer() {
    const { url } = await startStandaloneServer(server, {
        context: async ({ req }) => ({
            userId: authenticateHTTPAccessToken(req),
            dataloaders: createDataloaders()
        }),
        listen: { port: 8000 }
    });
    console.log(`🚀  Server ready at: ${url}`);
}

/* eslint-disable @typescript-eslint/require-await */

function runProductionServer() {
    return startServerAndCreateLambdaHandler(
        server,
        handlers.createAPIGatewayProxyEventRequestHandler(),
        {
            context: async ({ event }) => ({
                userId: await authenticateHTTPAccessToken(event),
                dataloaders: createDataloaders()
            }),
            middleware: [
                async (event) => {
                    if (!event.body) return;
                    const parsedBody = JSON.parse(event.body) as GraphQLRequest;
                    if (!parsedBody.query) {
                        throw new GraphQLError("No Query Found", {
                            extensions: { code: ApolloServerErrorCode.BAD_REQUEST }
                        });
                    }
                    const operationAST = getOperationAST(
                        parse(parsedBody.query),
                        parsedBody.operationName
                    );
                    if (operationAST && operationAST.operation === OperationTypeNode.SUBSCRIPTION) {
                        throw new GraphQLError("Subscriptions Are Not Supported");
                    }
                },
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
}

export const handler = isProduction ? runProductionServer() : runDevelopmentServer();
