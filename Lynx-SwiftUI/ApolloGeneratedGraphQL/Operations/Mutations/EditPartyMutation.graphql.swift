// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class EditPartyMutation: GraphQLMutation {
    public static let operationName: String = "EditParty"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation EditParty($partyId: ID!, $partyData: [KeyValuePair!]!) {
          editParty(partyId: $partyId, partyData: $partyData) {
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
            invitedUsers {
              __typename
              id
              firstName
              lastName
              profilePictureUrl
            }
          }
        }
        """#
      ))

    public var partyId: ID
    public var partyData: [KeyValuePair]

    public init(
      partyId: ID,
      partyData: [KeyValuePair]
    ) {
      self.partyId = partyId
      self.partyData = partyData
    }

    public var __variables: Variables? { [
      "partyId": partyId,
      "partyData": partyData
    ] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("editParty", EditParty.self, arguments: [
          "partyId": .variable("partyId"),
          "partyData": .variable("partyData")
        ]),
      ] }

      public var editParty: EditParty { __data["editParty"] }

      /// EditParty
      ///
      /// Parent Type: `Party`
      public struct EditParty: ApolloGeneratedGraphQL.SelectionSet {
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
          .field("invitedUsers", [InvitedUser].self),
        ] }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var description: String? { __data["description"] }
        public var partyManager: PartyManager { __data["partyManager"] }
        public var users: [User] { __data["users"] }
        public var invitedUsers: [InvitedUser] { __data["invitedUsers"] }

        /// EditParty.PartyManager
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

        /// EditParty.User
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

        /// EditParty.InvitedUser
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
      }
    }
  }

}