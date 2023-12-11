"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const convert_units_1 = __importDefault(require("convert-units"));
const topSpeed = (parent, args, context, info) => {
    if (args.system === "METRIC") {
        return (0, convert_units_1.default)(parent.topSpeed).from("m/h").to("km/h");
    }
    return parent.topSpeed;
};
exports.default = topSpeed;
