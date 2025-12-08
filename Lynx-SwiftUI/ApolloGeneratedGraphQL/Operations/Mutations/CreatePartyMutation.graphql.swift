// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class CreatePartyMutation: GraphQLMutation {
    public static let operationName: String = "CreateParty"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation CreateParty($name: String!, $description: String) {
          createParty(name: $name, description: $description) {
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

    public var name: String
    public var description: GraphQLNullable<String>

    public init(
      name: String,
      description: GraphQLNullable<String>
    ) {
      self.name = name
      self.description = description
    }

    public var __variables: Variables? { [
      "name": name,
      "description": description
    ] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createParty", CreateParty.self, arguments: [
          "name": .variable("name"),
          "description": .variable("description")
        ]),
      ] }

      public var createParty: CreateParty { __data["createParty"] }

      /// CreateParty
      ///
      /// Parent Type: `Party`
      public struct CreateParty: ApolloGeneratedGraphQL.SelectionSet {
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

        /// CreateParty.PartyManager
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

        /// CreateParty.User
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

        /// CreateParty.InvitedUser
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