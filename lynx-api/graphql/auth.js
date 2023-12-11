"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkIsMe = exports.checkIsLoggedInAndHasValidInvite = exports.checkIsLoggedIn = exports.authenticateHTTPAccessToken = exports.decryptToken = exports.generateToken = void 0;
const apollo_server_express_1 = require("apollo-server-express");
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const dynamodb_1 = require("./aws/dynamodb");
const generateToken = (id) => {
    console.log(`Generating token for user with id ${id}`);
    return jsonwebtoken_1.default.sign({ id }, process.env.AUTH_KEY || "AUTH", { expiresIn: "6h" });
};
exports.generateToken = generateToken;
const decryptToken = (token) => {
    console.log(`Decrypting token for user with token ${token}`);
    return jsonwebtoken_1.default.verify(token, process.env.AUTH_KEY || "AUTH");
};
exports.decryptToken = decryptToken;
const authenticateHTTPAccessToken = (req) => {
    const authHeader = req.headers?.authorization;
    if (!authHeader)
        return null;
    const token = authHeader.split(" ")[1];
    if (!token)
        throw new apollo_server_express_1.AuthenticationError("Authentication Token Not Specified");
    try {
        return (0, exports.decryptToken)(token).id;
    }
    catch (err) {
        throw new apollo_server_express_1.AuthenticationError("Invalid Authentication Token");
    }
};
exports.authenticateHTTPAccessToken = authenticateHTTPAccessToken;
const checkIsLoggedIn = async (context) => {
    if (!context.userId) {
        throw new apollo_server_express_1.AuthenticationError("Must Be Logged In");
    }
    const queryOutput = await (0, dynamodb_1.getItem)(dynamodb_1.DYNAMODB_TABLE_USERS, context.userId);
    const userRecord = (0, dynamodb_1.getItemFromDynamoDBResult)(queryOutput);
    if (!userRecord) {
        throw new apollo_server_express_1.AuthenticationError("User Does Not Exist");
    }
};
exports.checkIsLoggedIn = checkIsLoggedIn;
const checkIsLoggedInAndHasValidInvite = async (context) => {
    if (!context.userId) {
        throw new apollo_server_express_1.AuthenticationError("Must Be Logged In");
    }
    const queryOutput = await (0, dynamodb_1.getItem)(dynamodb_1.DYNAMODB_TABLE_USERS, context.userId);
    const userRecord = (0, dynamodb_1.getItemFromDynamoDBResult)(queryOutput);
    if (!userRecord || !userRecord.validatedInvite) {
        throw new apollo_server_express_1.AuthenticationError("User Does Not Exist Or No Validated Invite");
    }
};
exports.checkIsLoggedInAndHasValidInvite = checkIsLoggedInAndHasValidInvite;
const checkIsMe = async (parent, context) => {
    if (!context.userId || parent.id?.toString() !== context.userId) {
        throw new apollo_server_express_1.AuthenticationError("Permissions Invalid For Requested Field");
    }
};
exports.checkIsMe = checkIsMe;
