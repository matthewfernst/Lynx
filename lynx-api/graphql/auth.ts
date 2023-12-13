import { GraphQLError } from "graphql";

import { APIGatewayProxyEvent } from "aws-lambda";

import jwt from "jsonwebtoken";

import { Context } from "./index";
import { User } from "./types";
import { USERS_TABLE, getItem } from "./aws/dynamodb";

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

export const authenticateHTTPAccessToken = (req: APIGatewayProxyEvent): string | null => {
    const authHeader = req.headers?.Authorization;
    if (!authHeader) return null;

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

export const checkIsLoggedIn = async (context: Context): Promise<User> => {
    if (!context.userId) {
        throw new GraphQLError("Must Be Logged In", { extensions: { code: FORBIDDEN } });
    }
    const userRecord = await getItem(USERS_TABLE, context.userId);
    if (!userRecord) {
        throw new GraphQLError("User Does Not Exist", {
            extensions: { code: UNAUTHENTICATED, userId: context.userId }
        });
    }
    return userRecord;
};

export const checkIsLoggedInAndHasValidInvite = async (context: Context): Promise<User> => {
    const userRecord = await checkIsLoggedIn(context);
    if (!userRecord.validatedInvite) {
        throw new GraphQLError("No Validated Invite", {
            extensions: { code: UNAUTHENTICATED, userId: context.userId }
        });
    }
    return userRecord;
};

export const checkIsMe = async (parent: Parent, context: Context): Promise<void> => {
    if (!context.userId || parent.id?.toString() !== context.userId) {
        throw new GraphQLError("Permissions Invalid For Requested Field", {
            extensions: { code: FORBIDDEN, userId: context.userId }
        });
    }
};
