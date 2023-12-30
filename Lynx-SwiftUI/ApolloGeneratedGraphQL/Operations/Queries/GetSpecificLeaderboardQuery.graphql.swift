// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class GetSpecificLeaderboardQuery: GraphQLQuery {
    public static let operationName: String = "GetSpecificLeaderboard"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetSpecificLeaderboard($timeframe: Timeframe!, $sortBy: LeaderboardSort!, $measurementSystem: MeasurementSystem!) {
          leaderboard(sortBy: $sortBy, timeframe: $timeframe) {
            __typename
            ...leaderboardFields
            stats(timeframe: $timeframe) {
              __typename
              distance(system: $measurementSystem)
              runCount
              topSpeed(system: $measurementSystem)
              verticalDistance(system: $measurementSystem)
            }
          }
        }
        """#,
        fragments: [LeaderboardFields.self]
      ))

    public var timeframe: GraphQLEnum<Timeframe>
    public var sortBy: GraphQLEnum<LeaderboardSort>
    public var measurementSystem: GraphQLEnum<MeasurementSystem>

    public init(
      timeframe: GraphQLEnum<Timeframe>,
      sortBy: GraphQLEnum<LeaderboardSort>,
      measurementSystem: GraphQLEnum<MeasurementSystem>
    ) {
      self.timeframe = timeframe
      self.sortBy = sortBy
      self.measurementSystem = measurementSystem
    }

    public var __variables: Variables? { [
      "timeframe": timeframe,
      "sortBy": sortBy,
      "measurementSystem": measurementSystem
    ] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("leaderboard", [Leaderboard].self, arguments: [
          "sortBy": .variable("sortBy"),
          "timeframe": .variable("timeframe")
        ]),
      ] }

      public var leaderboard: [Leaderboard] { __data["leaderboard"] }

      /// Leaderboard
      ///
      /// Parent Type: `User`
      public struct Leaderboard: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("stats", Stats?.self, arguments: ["timeframe": .variable("timeframe")]),
          .fragment(LeaderboardFields.self),
        ] }

        public var stats: Stats? { __data["stats"] }
        public var profilePictureUrl: String? { __data["profilePictureUrl"] }
        public var firstName: String { __data["firstName"] }
        public var lastName: String { __data["lastName"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var leaderboardFields: LeaderboardFields { _toFragment() }
        }

        /// Leaderboard.Stats
        ///
        /// Parent Type: `UserStats`
        public struct Stats: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.UserStats }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("distance", Double.self, arguments: ["system": .variable("measurementSystem")]),
            .field("runCount", Int.self),
            .field("topSpeed", Double.self, arguments: ["system": .variable("measurementSystem")]),
            .field("verticalDistance", Double.self, arguments: ["system": .variable("measurementSystem")]),
          ] }

          public var distance: Double { __data["distance"] }
          public var runCount: Int { __data["runCount"] }
          public var topSpeed: Double { __data["topSpeed"] }
          public var verticalDistance: Double { __data["verticalDistance"] }
        }
      }
    }
  }

}