// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class GetPartyDetailsQuery: GraphQLQuery {
    public static let operationName: String = "GetPartyDetails"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetPartyDetails($partyId: ID!, $sortBy: LeaderboardSort = VERTICAL_DISTANCE, $timeframe: Timeframe = SEASON, $limit: Int = 5) {
          partyLookupById(id: $partyId) {
            __typename
            id
            name
            partyManager {
              __typename
              id
              firstName
              lastName
              profilePictureUrl
            }
            users {
              __typename
              id
              firstName
              lastName
              profilePictureUrl
            }
            invitedUsers {
              __typename
              id
              firstName
              lastName
              profilePictureUrl
            }
            leaderboard(sortBy: $sortBy, timeframe: $timeframe, limit: $limit) {
              __typename
              id
              firstName
              lastName
              profilePictureUrl
              stats(timeframe: $timeframe) {
                __typename
                runCount
                distance
                topSpeed
                verticalDistance
              }
            }
          }
        }
        """#
      ))

    public var partyId: ID
    public var sortBy: GraphQLNullable<GraphQLEnum<LeaderboardSort>>
    public var timeframe: GraphQLNullable<GraphQLEnum<Timeframe>>
    public var limit: GraphQLNullable<Int>

    public init(
      partyId: ID,
      sortBy: GraphQLNullable<GraphQLEnum<LeaderboardSort>> = .init(.verticalDistance),
      timeframe: GraphQLNullable<GraphQLEnum<Timeframe>> = .init(.season),
      limit: GraphQLNullable<Int> = 5
    ) {
      self.partyId = partyId
      self.sortBy = sortBy
      self.timeframe = timeframe
      self.limit = limit
    }

    public var __variables: Variables? { [
      "partyId": partyId,
      "sortBy": sortBy,
      "timeframe": timeframe,
      "limit": limit
    ] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("partyLookupById", PartyLookupById?.self, arguments: ["id": .variable("partyId")]),
      ] }

      public var partyLookupById: PartyLookupById? { __data["partyLookupById"] }

      /// PartyLookupById
      ///
      /// Parent Type: `Party`
      public struct PartyLookupById: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Party }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ApolloGeneratedGraphQL.ID.self),
          .field("name", String.self),
          .field("partyManager", PartyManager.self),
          .field("users", [User].self),
          .field("invitedUsers", [InvitedUser].self),
          .field("leaderboard", [Leaderboard].self, arguments: [
            "sortBy": .variable("sortBy"),
            "timeframe": .variable("timeframe"),
            "limit": .variable("limit")
          ]),
        ] }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var partyManager: PartyManager { __data["partyManager"] }
        public var users: [User] { __data["users"] }
        public var invitedUsers: [InvitedUser] { __data["invitedUsers"] }
        public var leaderboard: [Leaderboard] { __data["leaderboard"] }

        /// PartyLookupById.PartyManager
        ///
        /// Parent Type: `User`
        public struct PartyManager: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", ApolloGeneratedGraphQL.ID.self),
            .field("firstName", String.self),
            .field("lastName", String.self),
            .field("profilePictureUrl", String?.self),
          ] }

          public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
          public var firstName: String { __data["firstName"] }
          public var lastName: String { __data["lastName"] }
          public var profilePictureUrl: String? { __data["profilePictureUrl"] }
        }

        /// PartyLookupById.User
        ///
        /// Parent Type: `User`
        public struct User: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", ApolloGeneratedGraphQL.ID.self),
            .field("firstName", String.self),
            .field("lastName", String.self),
            .field("profilePictureUrl", String?.self),
          ] }

          public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
          public var firstName: String { __data["firstName"] }
          public var lastName: String { __data["lastName"] }
          public var profilePictureUrl: String? { __data["profilePictureUrl"] }
        }

        /// PartyLookupById.InvitedUser
        ///
        /// Parent Type: `User`
        public struct InvitedUser: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", ApolloGeneratedGraphQL.ID.self),
            .field("firstName", String.self),
            .field("lastName", String.self),
            .field("profilePictureUrl", String?.self),
          ] }

          public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
          public var firstName: String { __data["firstName"] }
          public var lastName: String { __data["lastName"] }
          public var profilePictureUrl: String? { __data["profilePictureUrl"] }
        }

        /// PartyLookupById.Leaderboard
        ///
        /// Parent Type: `User`
        public struct Leaderboard: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", ApolloGeneratedGraphQL.ID.self),
            .field("firstName", String.self),
            .field("lastName", String.self),
            .field("profilePictureUrl", String?.self),
            .field("stats", Stats?.self, arguments: ["timeframe": .variable("timeframe")]),
          ] }

          public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
          public var firstName: String { __data["firstName"] }
          public var lastName: String { __data["lastName"] }
          public var profilePictureUrl: String? { __data["profilePictureUrl"] }
          public var stats: Stats? { __data["stats"] }

          /// PartyLookupById.Leaderboard.Stats
          ///
          /// Parent Type: `UserStats`
          public struct Stats: ApolloGeneratedGraphQL.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.UserStats }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("runCount", Int.self),
              .field("distance", Double.self),
              .field("topSpeed", Double.self),
              .field("verticalDistance", Double.self),
            ] }

            public var runCount: Int { __data["runCount"] }
            public var distance: Double { __data["distance"] }
            public var topSpeed: Double { __data["topSpeed"] }
            public var verticalDistance: Double { __data["verticalDistance"] }
          }
        }
      }
    }
  }

}