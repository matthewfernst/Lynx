"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const auth_1 = require("../../auth");
const email = (parent, args, context, info) => {
    (0, auth_1.checkIsMe)(parent, context);
    return parent.email;
};
exports.default = email;
