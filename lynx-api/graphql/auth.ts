import { GraphQLError } from "graphql";

import { APIGatewayProxyEvent } from "aws-lambda";

import jwt from "jsonwebtoken";

import { Context } from "./index";
import { User } from "./types";
import { DYNAMODB_TABLE_USERS, getItem, getItemFromDynamoDBResult } from "./aws/dynamodb";

interface Parent {
    id: string;
}

export const generateToken = (id: string): string => {
    console.log(`Generating token for user with id ${id}`);
    return jwt.sign({ id }, process.env.AUTH_KEY || "AUTH", { expiresIn: "6h" });
};

export const decryptToken = (token: string): User => {
    console.log(`Decrypting token for user with token ${token}`);
    return jwt.verify(token, process.env.AUTH_KEY || "AUTH") as User;
};

export const authenticateHTTPAccessToken = (req: APIGatewayProxyEvent): string | null => {
    const authHeader = req.headers?.authorization;
    if (!authHeader) return null;

    const token = authHeader.split(" ")[1];
    if (!token) throw new GraphQLError("Authentication Token Not Specified");

    try {
        return decryptToken(token).id;
    } catch (err) {
        throw new GraphQLError("Invalid Authentication Token");
    }
};

export const checkIsLoggedIn = async (context: Context): Promise<void> => {
    if (!context.userId) {
        throw new GraphQLError("Must Be Logged In");
    }
    const queryOutput = await getItem(DYNAMODB_TABLE_USERS, context.userId);
    const userRecord = getItemFromDynamoDBResult(queryOutput);
    if (!userRecord) {
        throw new GraphQLError("User Does Not Exist");
    }
};

export const checkIsLoggedInAndHasValidInvite = async (context: Context): Promise<void> => {
    if (!context.userId) {
        throw new GraphQLError("Must Be Logged In");
    }
    const queryOutput = await getItem(DYNAMODB_TABLE_USERS, context.userId);
    const userRecord = getItemFromDynamoDBResult(queryOutput) as User | null;
    if (!userRecord || !userRecord.validatedInvite) {
        throw new GraphQLError("User Does Not Exist Or No Validated Invite");
    }
};

export const checkIsMe = async (parent: Parent, context: Context): Promise<void> => {
    if (!context.userId || parent.id?.toString() !== context.userId) {
        throw new GraphQLError("Permissions Invalid For Requested Field");
    }
};
