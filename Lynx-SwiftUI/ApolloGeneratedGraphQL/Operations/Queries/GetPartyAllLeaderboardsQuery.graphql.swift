// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ApolloGeneratedGraphQL {
  public class GetPartyAllLeaderboardsQuery: GraphQLQuery {
    public static let operationName: String = "GetPartyAllLeaderboards"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetPartyAllLeaderboards($partyId: ID!, $timeframe: Timeframe = SEASON, $limit: Int = 3, $system: MeasurementSystem = IMPERIAL) {
          partyLookupById(id: $partyId) {
            __typename
            id
            name
            distance: leaderboard(sortBy: DISTANCE, timeframe: $timeframe, limit: $limit) {
              __typename
              id
              firstName
              lastName
              profilePictureUrl
              stats(timeframe: $timeframe) {
                __typename
                distance(system: $system)
              }
            }
            runCount: leaderboard(sortBy: RUN_COUNT, timeframe: $timeframe, limit: $limit) {
              __typename
              id
              firstName
              lastName
              profilePictureUrl
              stats(timeframe: $timeframe) {
                __typename
                runCount
              }
            }
            topSpeed: leaderboard(sortBy: TOP_SPEED, timeframe: $timeframe, limit: $limit) {
              __typename
              id
              firstName
              lastName
              profilePictureUrl
              stats(timeframe: $timeframe) {
                __typename
                topSpeed(system: $system)
              }
            }
            verticalDistance: leaderboard(
              sortBy: VERTICAL_DISTANCE
              timeframe: $timeframe
              limit: $limit
            ) {
              __typename
              id
              firstName
              lastName
              profilePictureUrl
              stats(timeframe: $timeframe) {
                __typename
                verticalDistance(system: $system)
              }
            }
          }
        }
        """#
      ))

    public var partyId: ID
    public var timeframe: GraphQLNullable<GraphQLEnum<Timeframe>>
    public var limit: GraphQLNullable<Int>
    public var system: GraphQLNullable<GraphQLEnum<MeasurementSystem>>

    public init(
      partyId: ID,
      timeframe: GraphQLNullable<GraphQLEnum<Timeframe>> = .init(.season),
      limit: GraphQLNullable<Int> = 3,
      system: GraphQLNullable<GraphQLEnum<MeasurementSystem>> = .init(.imperial)
    ) {
      self.partyId = partyId
      self.timeframe = timeframe
      self.limit = limit
      self.system = system
    }

    public var __variables: Variables? {
      [
        "partyId": partyId,
        "timeframe": timeframe,
        "limit": limit,
        "system": system,
      ]
    }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] {
        [
          .field("partyLookupById", PartyLookupById?.self, arguments: ["id": .variable("partyId")])
        ]
      }

      public var partyLookupById: PartyLookupById? { __data["partyLookupById"] }

      /// PartyLookupById
      ///
      /// Parent Type: `Party`
      public struct PartyLookupById: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType {
          ApolloGeneratedGraphQL.Objects.Party
        }
        public static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("id", ApolloGeneratedGraphQL.ID.self),
            .field("name", String.self),
            .field(
              "leaderboard", alias: "distance", [Distance].self,
              arguments: [
                "sortBy": "DISTANCE",
                "timeframe": .variable("timeframe"),
                "limit": .variable("limit"),
              ]),
            .field(
              "leaderboard", alias: "runCount", [RunCount].self,
              arguments: [
                "sortBy": "RUN_COUNT",
                "timeframe": .variable("timeframe"),
                "limit": .variable("limit"),
              ]),
            .field(
              "leaderboard", alias: "topSpeed", [TopSpeed].self,
              arguments: [
                "sortBy": "TOP_SPEED",
                "timeframe": .variable("timeframe"),
                "limit": .variable("limit"),
              ]),
            .field(
              "leaderboard", alias: "verticalDistance", [VerticalDistance].self,
              arguments: [
                "sortBy": "VERTICAL_DISTANCE",
                "timeframe": .variable("timeframe"),
                "limit": .variable("limit"),
              ]),
          ]
        }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var distance: [Distance] { __data["distance"] }
        public var runCount: [RunCount] { __data["runCount"] }
        public var topSpeed: [TopSpeed] { __data["topSpeed"] }
        public var verticalDistance: [VerticalDistance] { __data["verticalDistance"] }

        /// PartyLookupById.Distance
        ///
        /// Parent Type: `User`
        public struct Distance: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType {
            ApolloGeneratedGraphQL.Objects.User
          }
          public static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("id", ApolloGeneratedGraphQL.ID.self),
              .field("firstName", String.self),
              .field("lastName", String.self),
              .field("profilePictureUrl", String?.self),
              .field("stats", Stats?.self, arguments: ["timeframe": .variable("timeframe")]),
            ]
          }

          public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
          public var firstName: String { __data["firstName"] }
          public var lastName: String { __data["lastName"] }
          public var profilePictureUrl: String? { __data["profilePictureUrl"] }
          public var stats: Stats? { __data["stats"] }

          /// PartyLookupById.Distance.Stats
          ///
          /// Parent Type: `UserStats`
          public struct Stats: ApolloGeneratedGraphQL.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType {
              ApolloGeneratedGraphQL.Objects.UserStats
            }
            public static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("distance", Double.self, arguments: ["system": .variable("system")]),
              ]
            }

            public var distance: Double { __data["distance"] }
          }
        }

        /// PartyLookupById.RunCount
        ///
        /// Parent Type: `User`
        public struct RunCount: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType {
            ApolloGeneratedGraphQL.Objects.User
          }
          public static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("id", ApolloGeneratedGraphQL.ID.self),
              .field("firstName", String.self),
              .field("lastName", String.self),
              .field("profilePictureUrl", String?.self),
              .field("stats", Stats?.self, arguments: ["timeframe": .variable("timeframe")]),
            ]
          }

          public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
          public var firstName: String { __data["firstName"] }
          public var lastName: String { __data["lastName"] }
          public var profilePictureUrl: String? { __data["profilePictureUrl"] }
          public var stats: Stats? { __data["stats"] }

          /// PartyLookupById.RunCount.Stats
          ///
          /// Parent Type: `UserStats`
          public struct Stats: ApolloGeneratedGraphQL.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType {
              ApolloGeneratedGraphQL.Objects.UserStats
            }
            public static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("runCount", Int.self),
              ]
            }

            public var runCount: Int { __data["runCount"] }
          }
        }

        /// PartyLookupById.TopSpeed
        ///
        /// Parent Type: `User`
        public struct TopSpeed: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType {
            ApolloGeneratedGraphQL.Objects.User
          }
          public static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("id", ApolloGeneratedGraphQL.ID.self),
              .field("firstName", String.self),
              .field("lastName", String.self),
              .field("profilePictureUrl", String?.self),
              .field("stats", Stats?.self, arguments: ["timeframe": .variable("timeframe")]),
            ]
          }

          public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
          public var firstName: String { __data["firstName"] }
          public var lastName: String { __data["lastName"] }
          public var profilePictureUrl: String? { __data["profilePictureUrl"] }
          public var stats: Stats? { __data["stats"] }

          /// PartyLookupById.TopSpeed.Stats
          ///
          /// Parent Type: `UserStats`
          public struct Stats: ApolloGeneratedGraphQL.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType {
              ApolloGeneratedGraphQL.Objects.UserStats
            }
            public static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("topSpeed", Double.self, arguments: ["system": .variable("system")]),
              ]
            }

            public var topSpeed: Double { __data["topSpeed"] }
          }
        }

        /// PartyLookupById.VerticalDistance
        ///
        /// Parent Type: `User`
        public struct VerticalDistance: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType {
            ApolloGeneratedGraphQL.Objects.User
          }
          public static var __selections: [ApolloAPI.Selection] {
            [
              .field("__typename", String.self),
              .field("id", ApolloGeneratedGraphQL.ID.self),
              .field("firstName", String.self),
              .field("lastName", String.self),
              .field("profilePictureUrl", String?.self),
              .field("stats", Stats?.self, arguments: ["timeframe": .variable("timeframe")]),
            ]
          }

          public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
          public var firstName: String { __data["firstName"] }
          public var lastName: String { __data["lastName"] }
          public var profilePictureUrl: String? { __data["profilePictureUrl"] }
          public var stats: Stats? { __data["stats"] }

          /// PartyLookupById.VerticalDistance.Stats
          ///
          /// Parent Type: `UserStats`
          public struct Stats: ApolloGeneratedGraphQL.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType {
              ApolloGeneratedGraphQL.Objects.UserStats
            }
            public static var __selections: [ApolloAPI.Selection] {
              [
                .field("__typename", String.self),
                .field("verticalDistance", Double.self, arguments: ["system": .variable("system")]),
              ]
            }

            public var verticalDistance: Double { __data["verticalDistance"] }
          }
        }
      }
    }
  }

}
