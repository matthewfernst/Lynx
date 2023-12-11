"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.xmlToActivity = exports.getLogbookInformationFromS3 = void 0;
const s3_1 = require("../../aws/s3");
const xml2js_1 = require("xml2js");
const reverseRenameFileFunction = (originalFileName) => {
    return `${originalFileName.split(".")[0]}.slopes`;
};
const logbook = async (parent, args, context, info) => {
    if (!parent.logbook) {
        return await (0, exports.getLogbookInformationFromS3)(parent.id);
    }
    return parent.logbook;
};
const getLogbookInformationFromS3 = async (userId) => {
    const recordNames = await (0, s3_1.getObjectNamesInBucket)(s3_1.toRunRecordsBucket, userId);
    return Promise.all(recordNames.map(async (recordName) => {
        const unzippedRecord = await (0, s3_1.getRecordFromBucket)(s3_1.toRunRecordsBucket, recordName);
        const activity = await (0, exports.xmlToActivity)(unzippedRecord);
        activity.originalFileName = reverseRenameFileFunction(recordName);
        return activity;
    }));
};
exports.getLogbookInformationFromS3 = getLogbookInformationFromS3;
const xmlToActivity = async (xml) => {
    const { activity } = await (0, xml2js_1.parseStringPromise)(xml, {
        normalize: true,
        mergeAttrs: true,
        explicitArray: false,
        tagNameProcessors: [xml2js_1.processors.firstCharLowerCase],
        attrNameProcessors: [xml2js_1.processors.firstCharLowerCase],
        valueProcessors: [xml2js_1.processors.parseBooleans, xml2js_1.processors.parseNumbers],
        attrValueProcessors: [xml2js_1.processors.parseBooleans, xml2js_1.processors.parseNumbers]
    });
    return activity;
};
exports.xmlToActivity = xmlToActivity;
exports.default = logbook;
