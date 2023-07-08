import { Context } from "../../index";

export interface LogParent {
    conditions: string;
    distance: number;
    duration: number;
    end: string;
    identifier: string;
    locationName: string;
    originalFileName: string;
    runCount: number;
    start: string;
    topSpeed: number;
    vertical: number;
    actions: {
        action: [LogDetailParent];
    };
}

export interface LogDetailParent {
    avgSpeed: number;
    distance: number;
    duration: number;
    end: string;
    maxAlt: number;
    minAlt: number;
    start: string;
    topSpeed: number;
    topSpeedAlt: number;
    type: string;
    vertical: number;
}

const id = (parent: LogParent, args: any, context: Context, info: any) => {
    return parent.identifier;
};

export default id;
