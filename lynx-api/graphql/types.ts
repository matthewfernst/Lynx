import { Timeframe } from "./resolvers/Query/leaderboard";

export const UNAUTHENTICATED = "UNAUTHENTICATED";
export const FORBIDDEN = "FORBIDDEN";
export const DEPENDENCY_ERROR = "DEPENDENCY_ERROR";

export interface DatabaseUser {
    id: string;
    appleId?: string;
    googleId?: string;
    facebookId?: string;
    validatedInvite: boolean;
    email: string;
    firstName?: string;
    lastName?: string;
    profilePictureUrl?: string;
    parties: string[];
    partyInvites: string[];
}

export interface UserStats {
    runCount: number;
    distance: number;
    topSpeed: number;
    verticalDistance: number;
}

export interface ParsedLog {
    attributes: {
        altitudeOffset: number;
        centerLat: number;
        centerLong: number;
        conditions: string;
        distance: number;
        duration: number;
        end: string;
        equipment: number;
        identifier: string;
        isFavorite: number;
        locationId: string;
        locationName: string;
        overrides: string;
        peakAltitude: number;
        processedByBuild: number;
        recordEnd: string;
        recordStart: string;
        rodeWith: string;
        runCount: number;
        source: number;
        sport: number;
        start: string;
        timeZoneOffset: number;
        topSpeed: number;
        vertical: number;
    };
    actions: {
        action: ParsedLogDetails[];
    }[];
    originalFileName: string;
}

export interface ParsedLogDetails {
    attributes: {
        avgSpeed: number;
        distance: number;
        duration: number;
        end: string;
        maxAlt: number;
        maxLat: number;
        maxLong: number;
        minAlt: number;
        minLat: string;
        minLong: string;
        minSpeed: number;
        numberOfType: number;
        start: string;
        topSpeed: number;
        topSpeedAlt: number;
        topSpeedLat: number;
        topSpeedLong: number;
        trackIDs: string;
        type: string;
        vertical: number;
    };
}

export enum MeasurementSystem {
    METRIC,
    IMPERIAL
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
