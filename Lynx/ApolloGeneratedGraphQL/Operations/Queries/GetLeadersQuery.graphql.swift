// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class GetLeadersQuery: GraphQLQuery {
    public static let operationName: String = "GetLeaders"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetLeaders($sortBy: LeaderboardSort!, $limit: Int, $measurementSystem: MeasurementSystem!) {
          leaderboard(sortBy: $sortBy, limit: $limit) {
            __typename
            profilePictureUrl
            firstName
            lastName
            logbook {
              __typename
              distance(system: $measurementSystem)
              runCount
              topSpeed(system: $measurementSystem)
              verticalDistance(system: $measurementSystem)
            }
          }
        }
        """#
      ))

    public var sortBy: GraphQLEnum<LeaderboardSort>
    public var limit: GraphQLNullable<Int>
    public var measurementSystem: GraphQLEnum<MeasurementSystem>

    public init(
      sortBy: GraphQLEnum<LeaderboardSort>,
      limit: GraphQLNullable<Int>,
      measurementSystem: GraphQLEnum<MeasurementSystem>
    ) {
      self.sortBy = sortBy
      self.limit = limit
      self.measurementSystem = measurementSystem
    }

    public var __variables: Variables? { [
      "sortBy": sortBy,
      "limit": limit,
      "measurementSystem": measurementSystem
    ] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("leaderboard", [Leaderboard].self, arguments: [
          "sortBy": .variable("sortBy"),
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
          .field("profilePictureUrl", String?.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("logbook", [Logbook].self),
        ] }

        public var profilePictureUrl: String? { __data["profilePictureUrl"] }
        public var firstName: String { __data["firstName"] }
        public var lastName: String { __data["lastName"] }
        public var logbook: [Logbook] { __data["logbook"] }

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