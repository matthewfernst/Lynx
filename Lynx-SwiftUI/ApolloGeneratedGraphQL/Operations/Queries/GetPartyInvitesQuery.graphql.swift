// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class GetPartyInvitesQuery: GraphQLQuery {
    public static let operationName: String = "GetPartyInvites"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetPartyInvites {
          selfLookup {
            __typename
            id
            partyInvites {
              __typename
              id
              name
              description
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
          .field("id", ApolloGeneratedGraphQL.ID.self),
          .field("partyInvites", [PartyInvite].self),
        ] }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        public var partyInvites: [PartyInvite] { __data["partyInvites"] }

        /// SelfLookup.PartyInvite
        ///
        /// Parent Type: `Party`
        public struct PartyInvite: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Party }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", ApolloGeneratedGraphQL.ID.self),
            .field("name", String.self),
            .field("description", String?.self),
            .field("partyManager", PartyManager.self),
            .field("users", [User].self),
          ] }

          public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
          public var name: String { __data["name"] }
          public var description: String? { __data["description"] }
          public var partyManager: PartyManager { __data["partyManager"] }
          public var users: [User] { __data["users"] }

          /// SelfLookup.PartyInvite.PartyManager
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

          /// SelfLookup.PartyInvite.User
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
        }
      }
    }
  }

}