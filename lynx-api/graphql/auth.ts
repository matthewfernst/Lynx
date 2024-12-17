import { ApolloServerErrorCode } from "@apollo/server/errors";
import { APIGatewayProxyEvent } from "aws-lambda";
import { GraphQLError } from "graphql";
import { IncomingMessage } from "http";
import jwt from "jsonwebtoken";

import { Context, DefinedUserContext } from "./index";
import { FORBIDDEN, Party, UNAUTHENTICATED, DatabaseUser } from "./types";

export interface AccessToken {
    id: string;
}

export enum GrantType {
    AUTH,
    REFRESH
}

export function generateToken(id: string, grantType: GrantType): string {
    console.info(`Generating ${GrantType[grantType]} token for user ${id}`);
    const key = process.env[`${grantType}_KEY`] || GrantType[grantType];
    return jwt.sign({ id }, key, { expiresIn: "6h" });
}

export function decryptToken(token: string, grantType: GrantType): AccessToken {
    console.info(`Decrypting access token for user with token ${token}`);
    const key = process.env[`${grantType}_KEY`] || GrantType[grantType];
    return jwt.verify(token, key) as AccessToken;
}

export function authenticateHTTPAccessToken(
    req: IncomingMessage | APIGatewayProxyEvent
): string | null {
    const authHeader = req.headers?.authorization || req.headers?.Authorization;
    if (!authHeader || Array.isArray(authHeader)) {
        return null;
    }

    const token = authHeader.split(" ")[1];
    if (!token) {
        console.error("Authentication Token Not Specified");
        throw new GraphQLError("Authentication Token Not Specified", {
            extensions: { code: UNAUTHENTICATED }
        });
    }

    try {
        return decryptToken(token, GrantType.AUTH).id;
    } catch (err) {
        console.error(err);
        throw new GraphQLError("Invalid Authentication Token", {
            extensions: { code: UNAUTHENTICATED, token }
        });
    }
}

export function checkIsMe(
    parent: DatabaseUser,
    context: DefinedUserContext,
    fieldName: string | undefined = undefined
) {
    if (parent.id !== context.userId) {
        throw new GraphQLError("Permissions Invalid For Requested Field", {
            extensions: { code: FORBIDDEN, userId: context.userId, fieldName }
        });
    }
}

export function checkHasUserId(context: Context): asserts context is DefinedUserContext {
    if (!context.userId) {
        throw new GraphQLError("Must Be Logged In", { extensions: { code: FORBIDDEN } });
    }
}

export async function checkIsValidUser(context: DefinedUserContext): Promise<DatabaseUser> {
    const userRecord = await context.dataloaders.users.load(context.userId);
    if (!userRecord) {
        throw new GraphQLError("User Does Not Exist", {
            extensions: { code: UNAUTHENTICATED, userId: context.userId }
        });
    }
    return userRecord;
}

export async function checkIsValidUserAndHasValidInvite(context: DefinedUserContext) {
    const userRecord = await checkIsValidUser(context);
    if (!userRecord.validatedInvite) {
        throw new GraphQLError("No Validated Invite", {
            extensions: { code: UNAUTHENTICATED, userId: context.userId }
        });
    }
}

export async function checkIsValidParty(
    context: DefinedUserContext,
    partyId: string
): Promise<Party> {
    const party = await context.dataloaders.parties.load(partyId);
    if (!party) {
        throw new GraphQLError("Party Does Not Exist", {
            extensions: { code: ApolloServerErrorCode.BAD_REQUEST, partyId }
        });
    }
    return party;
}

export async function checkIsValidPartyAndIsPartyOwner(
    context: DefinedUserContext,
    partyId: string
) {
    const party = await checkIsValidParty(context, partyId);
    if (party.partyManager !== context.userId) {
        throw new GraphQLError("User Is Not Party Owner", {
            extensions: { code: FORBIDDEN, userId: context.userId, partyId }
        });
    }
}
