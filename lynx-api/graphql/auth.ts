import { GraphQLError } from "graphql";
import { APIGatewayProxyEvent } from "aws-lambda";
import jwt from "jsonwebtoken";

import { User } from "./types";
import { getItem } from "./aws/dynamodb";
import { USERS_TABLE } from "../infrastructure/lib/infrastructure";

export const BAD_REQUEST = "BAD_REQUEST";
export const UNAUTHENTICATED = "UNAUTHENTICATED";
export const FORBIDDEN = "FORBIDDEN";

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

export const authenticateHTTPAccessToken = (req: APIGatewayProxyEvent): string | undefined => {
    const authHeader = req.headers?.Authorization;
    if (!authHeader) return undefined;

    const token = authHeader.split(" ")[1];
    if (!token)
        throw new GraphQLError("Authentication Token Not Specified", {
            extensions: { code: UNAUTHENTICATED }
        });

    try {
        return decryptToken(token).id;
    } catch (err) {
        throw new GraphQLError("Invalid Authentication Token", {
            extensions: { code: UNAUTHENTICATED, token }
        });
    }
};

export const checkHasUserId = (userId: string | undefined): string => {
    if (!userId) {
        throw new GraphQLError("Must Be Logged In", { extensions: { code: FORBIDDEN } });
    }
    return userId;
};

export const checkIsLoggedIn = async (userId: string): Promise<User> => {
    const userRecord = await getItem(USERS_TABLE, userId);
    if (!userRecord) {
        throw new GraphQLError("User Does Not Exist", {
            extensions: { code: UNAUTHENTICATED, userId }
        });
    }
    return userRecord;
};

export const checkIsLoggedInAndHasValidInvite = async (userId: string): Promise<User> => {
    const userRecord = await checkIsLoggedIn(userId);
    if (!userRecord.validatedInvite) {
        throw new GraphQLError("No Validated Invite", {
            extensions: { code: UNAUTHENTICATED, userId: userId }
        });
    }
    return userRecord;
};

export const checkIsMe = (parent: Parent, userId: string | undefined): string => {
    if (!userId || parent.id?.toString() !== userId) {
        throw new GraphQLError("Permissions Invalid For Requested Field", {
            extensions: { code: FORBIDDEN, userId }
        });
    }
    return userId;
};
