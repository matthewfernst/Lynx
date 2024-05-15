import { APIGatewayProxyEvent } from "aws-lambda";
import { GraphQLError } from "graphql";
import jwt from "jsonwebtoken";

import { Context, DefinedUserContext } from "./index";
import { LOG_LEVEL, BAD_REQUEST, FORBIDDEN, Party, UNAUTHENTICATED, User } from "./types";

export interface AccessToken {
    id: string;
}

export enum GrantType {
    AUTH,
    REFRESH
}

export function generateToken(id: string, grantType: GrantType): string {
    console[LOG_LEVEL](`Generating ${GrantType[grantType]} token for user ${id}`);
    const key = process.env[`${grantType}_KEY`] || GrantType[grantType];
    return jwt.sign({ id }, key, { expiresIn: "6h" });
}

export function decryptToken(token: string, grantType: GrantType): AccessToken {
    console[LOG_LEVEL](`Decrypting access token for user with token ${token}`);
    const key = process.env[`${grantType}_KEY`] || GrantType[grantType];
    return jwt.verify(token, key) as AccessToken;
}

export function authenticateHTTPAccessToken(req: APIGatewayProxyEvent): string | undefined {
    const authHeader = req.headers?.Authorization;
    if (!authHeader) return undefined;

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
    parent: User,
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

export async function checkIsValidUser(context: DefinedUserContext): Promise<User> {
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
            extensions: { code: BAD_REQUEST, partyId }
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
