import { Timeframe } from "./resolvers/Query/leaderboard";

export const LOG_LEVEL = "info";

export const BAD_REQUEST = "BAD_REQUEST";
export const UNAUTHENTICATED = "UNAUTHENTICATED";
export const FORBIDDEN = "FORBIDDEN";
export const DEPENDENCY_ERROR = "DEPENDENCY_ERROR";
export const INTERNAL_SERVER_ERROR = "INTERNAL_SERVER_ERROR";

export interface User {
    id: string;
    appleId?: string;
    googleId?: string;
    facebookId?: string;
    validatedInvite: boolean;
    email: string;
    firstName?: string;
    lastName?: string;
    profilePictureUrl?: string;
    stats?: UserStats;
    logbook: Log[];
}

export interface UserStats {
    runCount: number;
    distance: number;
    topSpeed: number;
    verticalDistance: number;
}

export interface Log {
    id: string;
    originalFileName: string;
    centerLat: number;
    centerLong: number;
    conditions: string[];
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
    type: keyof typeof LogDetailType;
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

export enum MeasurementSystem {
    METRIC,
    IMPERIAL
}

export enum LogDetailType {
    RUN,
    LIFT
}

export interface Invite {
    id: string;
    ttl: number;
}

export interface LeaderboardEntry {
    id: string;
    timeframe: keyof typeof Timeframe;
    distance: number;
    runCount: number;
    topSpeed: number;
    verticalDistance: number;
    ttl: number;
}

export interface Party {
    id: string;
    name: string;
    partyManager: string;
    users: string[];
    invitedUsers: string[];
}
