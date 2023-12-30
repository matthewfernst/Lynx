// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class GetLogsQuery: GraphQLQuery {
    public static let operationName: String = "GetLogs"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetLogs($system: MeasurementSystem!) {
          selfLookup {
            __typename
            logbook {
              __typename
              id
              originalFileName
              distance(system: $system)
              conditions
              duration
              startDate
              endDate
              locationName
              runCount
              topSpeed(system: $system)
              verticalDistance(system: $system)
              details {
                __typename
                type
                averageSpeed(system: $system)
                distance(system: $system)
                duration
                startDate
                endDate
                maxAltitude(system: $system)
                minAltitude(system: $system)
                topSpeed(system: $system)
                topSpeedAltitude(system: $system)
                verticalDistance(system: $system)
              }
            }
          }
        }
        """#
      ))

    public var system: GraphQLEnum<MeasurementSystem>

    public init(system: GraphQLEnum<MeasurementSystem>) {
      self.system = system
    }

    public var __variables: Variables? { ["system": system] }

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
          .field("logbook", [Logbook].self),
        ] }

        public var logbook: [Logbook] { __data["logbook"] }

        /// SelfLookup.Logbook
        ///
        /// Parent Type: `Log`
        public struct Logbook: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Log }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", ApolloGeneratedGraphQL.ID.self),
            .field("originalFileName", String.self),
            .field("distance", Double.self, arguments: ["system": .variable("system")]),
            .field("conditions", String?.self),
            .field("duration", Double.self),
            .field("startDate", String.self),
            .field("endDate", String.self),
            .field("locationName", String.self),
            .field("runCount", Int.self),
            .field("topSpeed", Double.self, arguments: ["system": .variable("system")]),
            .field("verticalDistance", Double.self, arguments: ["system": .variable("system")]),
            .field("details", [Detail].self),
          ] }

          public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
          public var originalFileName: String { __data["originalFileName"] }
          public var distance: Double { __data["distance"] }
          public var conditions: String? { __data["conditions"] }
          public var duration: Double { __data["duration"] }
          public var startDate: String { __data["startDate"] }
          public var endDate: String { __data["endDate"] }
          public var locationName: String { __data["locationName"] }
          public var runCount: Int { __data["runCount"] }
          public var topSpeed: Double { __data["topSpeed"] }
          public var verticalDistance: Double { __data["verticalDistance"] }
          public var details: [Detail] { __data["details"] }

          /// SelfLookup.Logbook.Detail
          ///
          /// Parent Type: `LogDetail`
          public struct Detail: ApolloGeneratedGraphQL.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.LogDetail }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("type", GraphQLEnum<ApolloGeneratedGraphQL.LogDetailType>.self),
              .field("averageSpeed", Double.self, arguments: ["system": .variable("system")]),
              .field("distance", Double.self, arguments: ["system": .variable("system")]),
              .field("duration", Double.self),
              .field("startDate", String.self),
              .field("endDate", String.self),
              .field("maxAltitude", Double.self, arguments: ["system": .variable("system")]),
              .field("minAltitude", Double.self, arguments: ["system": .variable("system")]),
              .field("topSpeed", Double.self, arguments: ["system": .variable("system")]),
              .field("topSpeedAltitude", Double.self, arguments: ["system": .variable("system")]),
              .field("verticalDistance", Double.self, arguments: ["system": .variable("system")]),
            ] }

            public var type: GraphQLEnum<ApolloGeneratedGraphQL.LogDetailType> { __data["type"] }
            public var averageSpeed: Double { __data["averageSpeed"] }
            public var distance: Double { __data["distance"] }
            public var duration: Double { __data["duration"] }
            public var startDate: String { __data["startDate"] }
            public var endDate: String { __data["endDate"] }
            public var maxAltitude: Double { __data["maxAltitude"] }
            public var minAltitude: Double { __data["minAltitude"] }
            public var topSpeed: Double { __data["topSpeed"] }
            public var topSpeedAltitude: Double { __data["topSpeedAltitude"] }
            public var verticalDistance: Double { __data["verticalDistance"] }
          }
        }
      }
    }
  }

}