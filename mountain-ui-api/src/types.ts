export interface User {
    id: string;
    appleId?: string;
    googleId?: string;
    email: string;
    firstName?: string;
    lastName?: string;
    profilePictureUrl?: string;
    incomingFriendRequests: string[];
    outgoingFriendRequests: string[];
    friends: string[];
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
