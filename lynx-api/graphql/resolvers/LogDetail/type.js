"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const type = (parent, args, context, info) => {
    return parent.type.toUpperCase();
};
exports.default = type;
