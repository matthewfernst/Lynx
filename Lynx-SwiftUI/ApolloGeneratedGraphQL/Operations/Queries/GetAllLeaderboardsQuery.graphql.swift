// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class GetAllLeaderboardsQuery: GraphQLQuery {
    public static let operationName: String = "GetAllLeaderboards"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetAllLeaderboards($timeframe: Timeframe!, $limit: Int, $measurementSystem: MeasurementSystem!) {
          distanceLeaders: leaderboard(
            sortBy: DISTANCE
            timeframe: $timeframe
            limit: $limit
          ) {
            __typename
            ...leaderboardFields
            stats(timeframe: $timeframe) {
              __typename
              distance(system: $measurementSystem)
            }
          }
          runCountLeaders: leaderboard(
            sortBy: RUN_COUNT
            timeframe: $timeframe
            limit: $limit
          ) {
            __typename
            ...leaderboardFields
            stats(timeframe: $timeframe) {
              __typename
              runCount
            }
          }
          topSpeedLeaders: leaderboard(
            sortBy: TOP_SPEED
            timeframe: $timeframe
            limit: $limit
          ) {
            __typename
            ...leaderboardFields
            stats(timeframe: $timeframe) {
              __typename
              topSpeed(system: $measurementSystem)
            }
          }
          verticalDistanceLeaders: leaderboard(
            sortBy: VERTICAL_DISTANCE
            timeframe: $timeframe
            limit: $limit
          ) {
            __typename
            ...leaderboardFields
            stats(timeframe: $timeframe) {
              __typename
              verticalDistance(system: $measurementSystem)
            }
          }
        }
        """#,
        fragments: [LeaderboardFields.self]
      ))

    public var timeframe: GraphQLEnum<Timeframe>
    public var limit: GraphQLNullable<Int>
    public var measurementSystem: GraphQLEnum<MeasurementSystem>

    public init(
      timeframe: GraphQLEnum<Timeframe>,
      limit: GraphQLNullable<Int>,
      measurementSystem: GraphQLEnum<MeasurementSystem>
    ) {
      self.timeframe = timeframe
      self.limit = limit
      self.measurementSystem = measurementSystem
    }

    public var __variables: Variables? { [
      "timeframe": timeframe,
      "limit": limit,
      "measurementSystem": measurementSystem
    ] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("leaderboard", alias: "distanceLeaders", [DistanceLeader].self, arguments: [
          "sortBy": "DISTANCE",
          "timeframe": .variable("timeframe"),
          "limit": .variable("limit")
        ]),
        .field("leaderboard", alias: "runCountLeaders", [RunCountLeader].self, arguments: [
          "sortBy": "RUN_COUNT",
          "timeframe": .variable("timeframe"),
          "limit": .variable("limit")
        ]),
        .field("leaderboard", alias: "topSpeedLeaders", [TopSpeedLeader].self, arguments: [
          "sortBy": "TOP_SPEED",
          "timeframe": .variable("timeframe"),
          "limit": .variable("limit")
        ]),
        .field("leaderboard", alias: "verticalDistanceLeaders", [VerticalDistanceLeader].self, arguments: [
          "sortBy": "VERTICAL_DISTANCE",
          "timeframe": .variable("timeframe"),
          "limit": .variable("limit")
        ]),
      ] }

      public var distanceLeaders: [DistanceLeader] { __data["distanceLeaders"] }
      public var runCountLeaders: [RunCountLeader] { __data["runCountLeaders"] }
      public var topSpeedLeaders: [TopSpeedLeader] { __data["topSpeedLeaders"] }
      public var verticalDistanceLeaders: [VerticalDistanceLeader] { __data["verticalDistanceLeaders"] }

      /// DistanceLeader
      ///
      /// Parent Type: `User`
      public struct DistanceLeader: ApolloGeneratedGraphQL.SelectionSet {
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

        /// DistanceLeader.Stats
        ///
        /// Parent Type: `UserStats`
        public struct Stats: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.UserStats }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("distance", Double.self, arguments: ["system": .variable("measurementSystem")]),
          ] }

          public var distance: Double { __data["distance"] }
        }
      }

      /// RunCountLeader
      ///
      /// Parent Type: `User`
      public struct RunCountLeader: ApolloGeneratedGraphQL.SelectionSet {
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

        /// RunCountLeader.Stats
        ///
        /// Parent Type: `UserStats`
        public struct Stats: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.UserStats }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("runCount", Int.self),
          ] }

          public var runCount: Int { __data["runCount"] }
        }
      }

      /// TopSpeedLeader
      ///
      /// Parent Type: `User`
      public struct TopSpeedLeader: ApolloGeneratedGraphQL.SelectionSet {
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

        /// TopSpeedLeader.Stats
        ///
        /// Parent Type: `UserStats`
        public struct Stats: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.UserStats }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("topSpeed", Double.self, arguments: ["system": .variable("measurementSystem")]),
          ] }

          public var topSpeed: Double { __data["topSpeed"] }
        }
      }

      /// VerticalDistanceLeader
      ///
      /// Parent Type: `User`
      public struct VerticalDistanceLeader: ApolloGeneratedGraphQL.SelectionSet {
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

        /// VerticalDistanceLeader.Stats
        ///
        /// Parent Type: `UserStats`
        public struct Stats: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.UserStats }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("verticalDistance", Double.self, arguments: ["system": .variable("measurementSystem")]),
          ] }

          public var verticalDistance: Double { __data["verticalDistance"] }
        }
      }
    }
  }

}