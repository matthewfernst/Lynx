// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class GetSelectedLeaderboardQuery: GraphQLQuery {
    public static let operationName: String = "GetSelectedLeaderboard"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetSelectedLeaderboard($limit: Int, $measurementSystem: MeasurementSystem!, $selectedLeaderboard: LeaderboardSort!) {
          leaderboard(sortBy: $selectedLeaderboard, limit: $limit) {
            __typename
            ...leaderboardFields
            logbook {
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

    public var limit: GraphQLNullable<Int>
    public var measurementSystem: GraphQLEnum<MeasurementSystem>
    public var selectedLeaderboard: GraphQLEnum<LeaderboardSort>

    public init(
      limit: GraphQLNullable<Int>,
      measurementSystem: GraphQLEnum<MeasurementSystem>,
      selectedLeaderboard: GraphQLEnum<LeaderboardSort>
    ) {
      self.limit = limit
      self.measurementSystem = measurementSystem
      self.selectedLeaderboard = selectedLeaderboard
    }

    public var __variables: Variables? { [
      "limit": limit,
      "measurementSystem": measurementSystem,
      "selectedLeaderboard": selectedLeaderboard
    ] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("leaderboard", [Leaderboard].self, arguments: [
          "sortBy": .variable("selectedLeaderboard"),
          "limit": .variable("limit")
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
          .field("logbook", [Logbook].self),
          .fragment(LeaderboardFields.self),
        ] }

        public var logbook: [Logbook] { __data["logbook"] }
        public var profilePictureUrl: String? { __data["profilePictureUrl"] }
        public var firstName: String { __data["firstName"] }
        public var lastName: String { __data["lastName"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var leaderboardFields: LeaderboardFields { _toFragment() }
        }

        /// Leaderboard.Logbook
        ///
        /// Parent Type: `Log`
        public struct Logbook: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Log }
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