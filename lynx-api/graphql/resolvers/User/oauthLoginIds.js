"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const auth_1 = require("../../auth");
const oauthLoginIds = (parent, args, context, info) => {
    (0, auth_1.checkIsMe)(parent, context);
    return [
        parent.appleId && { type: "APPLE", id: parent.appleId },
        parent.googleId && { type: "GOOGLE", id: parent.googleId }
    ].filter(Boolean);
};
exports.default = oauthLoginIds;
