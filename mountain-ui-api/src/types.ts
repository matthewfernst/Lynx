export interface User {
    [key: string]: any;
    id: string;
    appleId?: string;
    googleId?: string;
    validatedInvite: boolean;
    email: string;
    firstName?: string;
    lastName?: string;
    profilePictureUrl?: string;
}

export interface Log {
    id: string;
    originalFileName: string;
    centerLat: number;
    centerLong: number;
    conditions: string;
    distance: number;
    duration: number;
    start: string;
    end: string;
    locationName: string;
    runCount: string;
    topSpeed: number;
    vertical: number;
    details: LogDetail[];
}

export interface LogDetail {
    type: LogDetailType;
    averageSpeed: number;
    distance: number;
    duration: number;
    startDate: string;
    endDate: string;
    maxAltitude: number;
    minAltitude: number;
    topSpeed: number;
    topSpeedAltitude: number;
    verticalDistance: number;
}

export type MeasurementSystem = "METRIC" | "IMPERIAL";
export type LogDetailType = "RUN" | "LIFT";

export interface Invite {
    id: string;
    ttl: number;
}
