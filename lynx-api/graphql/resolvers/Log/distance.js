"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const convert_units_1 = __importDefault(require("convert-units"));
const distance = (parent, args, context, info) => {
    if (args.system === "IMPERIAL") {
        return (0, convert_units_1.default)(parent.distance).from("m").to("ft");
    }
    return parent.distance;
};
exports.default = distance;
