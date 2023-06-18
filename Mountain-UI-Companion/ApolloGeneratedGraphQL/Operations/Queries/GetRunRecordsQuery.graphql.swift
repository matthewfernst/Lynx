// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class GetRunRecordsQuery: GraphQLQuery {
    public static let operationName: String = "GetRunRecords"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetRunRecords {
          selfLookup {
            __typename
            runRecords {
              __typename
              conditions
              distance
              duration
              start
              end
              locationName
              runCount
              topSpeed
              vertical
            }
          }
        }
        """#
      ))

    public init() {}

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("selfLookup", SelfLookup?.self),
      ] }

      public var selfLookup: SelfLookup? { __data["selfLookup"] }

      /// SelfLookup
      ///
      /// Parent Type: `User`
      public struct SelfLookup: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("runRecords", [RunRecord].self),
        ] }

        public var runRecords: [RunRecord] { __data["runRecords"] }

        /// SelfLookup.RunRecord
        ///
        /// Parent Type: `RunRecord`
        public struct RunRecord: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.RunRecord }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("conditions", String.self),
            .field("distance", Double.self),
            .field("duration", Double.self),
            .field("start", String.self),
            .field("end", String.self),
            .field("locationName", String.self),
            .field("runCount", String.self),
            .field("topSpeed", Double.self),
            .field("vertical", Double.self),
          ] }

          public var conditions: String { __data["conditions"] }
          public var distance: Double { __data["distance"] }
          public var duration: Double { __data["duration"] }
          public var start: String { __data["start"] }
          public var end: String { __data["end"] }
          public var locationName: String { __data["locationName"] }
          public var runCount: String { __data["runCount"] }
          public var topSpeed: Double { __data["topSpeed"] }
          public var vertical: Double { __data["vertical"] }
        }
      }
    }
  }

}