export interface User {
    [key: string]: string | number | boolean | UserStats | Log[] | undefined;
    id: string;
    appleId?: string;
    googleId?: string;
    validatedInvite: boolean;
    email: string;
    firstName?: string;
    lastName?: string;
    profilePictureUrl?: string;
    userStats?: UserStats;
    logbook?: Log[];
}

export interface UserStats {
    [key: string]: number;
    runCount: number;
    distance: number;
    topSpeed: number;
    verticalDistance: number;
}

export interface Log {
    [key: string]: string | number | LogDetail[];
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
    runCount: number;
    topSpeed: number;
    vertical: number;
    details: LogDetail[];
}

export interface LogDetail {
    [key: string]: string | number;
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
    [key: string]: string | number;
    id: string;
    ttl: number;
}
