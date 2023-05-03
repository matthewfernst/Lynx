import "dotenv/config";

import { AuthenticationError, ExpressContext } from "apollo-server-express";
import { APIGatewayEvent } from "aws-lambda";

import jwt from "jsonwebtoken";

import { Context } from "./index";
import { User } from "./types";
import { DYNAMODB_TABLE_NAME_USERS, getItem, getItemFromDynamoDBResult } from "./aws/dynamodb";
import { UserInputError } from "apollo-server-lambda";

interface Parent {
    id: string;
    friends?: string[];
}

export const generateToken = (id: string): string => {
    console.log(`Generating token for user with id ${id}`);
    return jwt.sign({ id }, process.env.AUTH_KEY || "AUTH", { expiresIn: "1h" });
};

export const decryptToken = (token: string): User => {
    console.log(`Decrypting token for user with token ${token}`);
    return jwt.verify(token, process.env.AUTH_KEY || "AUTH") as User;
};

export const authenticateHTTPAccessToken = (
    req: ExpressContext["req"] | APIGatewayEvent
): string | null => {
    const authHeader = req.headers?.authorization;
    if (!authHeader) return null;

    const token = authHeader.split(" ")[1];
    if (!token) throw new AuthenticationError("Authentication Token Not Specified");

    try {
        return decryptToken(token).id;
    } catch (err) {
        throw new AuthenticationError("Invalid Authentication Token");
    }
};

export const checkIsLoggedIn = async (context: Context): Promise<void> => {
    if (!context.userId) {
        throw new AuthenticationError("Must Be Logged In");
    }
    const queryOutput = await getItem(DYNAMODB_TABLE_NAME_USERS, context.userId);
    const userRecord = getItemFromDynamoDBResult(queryOutput);
    if (!userRecord) {
        throw new AuthenticationError("User Does Not Exist");
    }
};

export const checkIsMe = async (parent: Parent, context: Context): Promise<void> => {
    if (!context.userId || parent.id?.toString() !== context.userId) {
        throw new AuthenticationError("Permissions Invalid For Requested Field");
    }
};

export const checkInMyFriends = async (context: Context, friendId: string): Promise<void> => {
    const queryOutput = await getItem(DYNAMODB_TABLE_NAME_USERS, context.userId as string);
    const userRecord = getItemFromDynamoDBResult(queryOutput);
    if (!userRecord || !userRecord.friends.includes(friendId)) {
        throw new UserInputError("Not Friends With Provided User");
    }
};
