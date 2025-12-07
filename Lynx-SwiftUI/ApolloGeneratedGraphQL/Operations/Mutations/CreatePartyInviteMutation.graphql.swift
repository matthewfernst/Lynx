// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class CreatePartyInviteMutation: GraphQLMutation {
    public static let operationName: String = "CreatePartyInvite"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation CreatePartyInvite($partyId: ID!, $userId: ID!) {
          createPartyInvite(partyId: $partyId, userId: $userId) {
            __typename
            id
            name
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
    public var userId: ID

    public init(
      partyId: ID,
      userId: ID
    ) {
      self.partyId = partyId
      self.userId = userId
    }

    public var __variables: Variables? { [
      "partyId": partyId,
      "userId": userId
    ] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createPartyInvite", CreatePartyInvite.self, arguments: [
          "partyId": .variable("partyId"),
          "userId": .variable("userId")
        ]),
      ] }

      public var createPartyInvite: CreatePartyInvite { __data["createPartyInvite"] }

      /// CreatePartyInvite
      ///
      /// Parent Type: `Party`
      public struct CreatePartyInvite: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Party }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ApolloGeneratedGraphQL.ID.self),
          .field("name", String.self),
          .field("invitedUsers", [InvitedUser].self),
        ] }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        public var name: String { __data["name"] }
        public var invitedUsers: [InvitedUser] { __data["invitedUsers"] }

        /// CreatePartyInvite.InvitedUser
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