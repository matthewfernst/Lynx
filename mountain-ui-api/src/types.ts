export interface User {
    id: string;
    appleId?: string;
    googleId?: string;
    email: string;
    firstName?: string;
    lastName?: string;
    profilePictureUrl?: string;
    friends: string[];
}

export interface RunRecord {
    id: string;
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
