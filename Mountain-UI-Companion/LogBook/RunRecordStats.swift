//
//  LogBookStats.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 6/16/23.
//

import Foundation
import Apollo

struct RunRecordStats
{
    typealias RunRecord = ApolloGeneratedGraphQL.GetUploadedRunRecordsQuery.Data.SelfLookup.RunRecord
    var runRecords:  [RunRecord] = []
    
    public static func lifetimeVerticalFeet() -> String
    {
        return "11.5k"
    }
    
    public static func lifetimeDaysOnMountain() -> String
    {
        return "0"
    }
    
    public static func lifetimeRunsTime() -> String
    {
        return "0"
    }
    
    public static func lifetimeRuns() -> String
    {
        return "0"
    }
    
}
