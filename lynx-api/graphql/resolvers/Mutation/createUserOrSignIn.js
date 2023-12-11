"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.idKeyFromIdType = exports.verifyToken = void 0;
const uuid_1 = require("uuid");
const luxon_1 = require("luxon");
const apple_signin_auth_1 = __importDefault(require("apple-signin-auth"));
const google_auth_library_1 = require("google-auth-library");
const apollo_server_lambda_1 = require("apollo-server-lambda");
const auth_1 = require("../../auth");
const dynamodb_1 = require("../../aws/dynamodb");
const createUserOrSignIn = async (_, args, context, info) => {
    const { type, id, token } = args.oauthLoginId;
    if (!token) {
        throw new apollo_server_lambda_1.UserInputError("Token Is Mandatory");
    }
    await (0, exports.verifyToken)(type, id, token);
    return await oauthLogin((0, exports.idKeyFromIdType)(type), id, args.email, args.userData);
};
const verifyToken = async (type, id, token) => {
    switch (type) {
        case "APPLE":
            return await verifyAppleToken(id, token);
        case "GOOGLE":
            return await verifyGoogleToken(id, token);
    }
};
exports.verifyToken = verifyToken;
const verifyAppleToken = async (id, token) => {
    const { sub } = await apple_signin_auth_1.default.verifyIdToken(token, {
        audience: process.env.APPLE_CLIENT_ID
    });
    return sub === id;
};
const verifyGoogleToken = async (id, token) => {
    const client = new google_auth_library_1.OAuth2Client(process.env.GOOGLE_CLIENT_ID);
    const ticket = await client.verifyIdToken({
        idToken: token,
        audience: process.env.GOOGLE_CLIENT_ID
    });
    return ticket.getUserId() === id;
};
const idKeyFromIdType = (idType) => {
    switch (idType) {
        case "APPLE":
            return "appleId";
        case "GOOGLE":
            return "googleId";
    }
};
exports.idKeyFromIdType = idKeyFromIdType;
const oauthLogin = async (idFieldName, id, email, userData) => {
    const dynamodbResult = await (0, dynamodb_1.getItemsByIndex)(dynamodb_1.DYNAMODB_TABLE_USERS, idFieldName, id);
    const user = (await (0, dynamodb_1.getItemFromDynamoDBResult)(dynamodbResult));
    const oneHourFromNow = luxon_1.DateTime.now().plus({ hours: 1 }).toMillis().toString();
    if (user) {
        return {
            token: (0, auth_1.generateToken)(user.id),
            expiryDate: oneHourFromNow,
            validatedInvite: user.validatedInvite
        };
    }
    else {
        if (!email || !userData) {
            throw new apollo_server_lambda_1.UserInputError("Must Provide Email And UserData On Account Creation");
        }
        const lynxAppId = (0, uuid_1.v4)();
        const validatedInvite = false;
        await (0, dynamodb_1.putItem)(dynamodb_1.DYNAMODB_TABLE_USERS, {
            id: lynxAppId,
            [idFieldName]: id,
            validatedInvite,
            email,
            ...Object.assign({}, ...userData.map((item) => ({ [item.key]: item.value })))
        });
        return {
            token: (0, auth_1.generateToken)(lynxAppId),
            expiryDate: oneHourFromNow,
            validatedInvite
        };
    }
};
exports.default = createUserOrSignIn;
