// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class UserLookupByEmailQuery: GraphQLQuery {
    public static let operationName: String = "UserLookupByEmail"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query UserLookupByEmail($email: String!) {
          userLookupByEmail(email: $email) {
            __typename
            id
            firstName
            lastName
            email
            profilePictureUrl
          }
        }
        """#
      ))

    public var email: String

    public init(email: String) {
      self.email = email
    }

    public var __variables: Variables? { ["email": email] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Query }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("userLookupByEmail", UserLookupByEmail?.self, arguments: ["email": .variable("email")]),
      ] }

      public var userLookupByEmail: UserLookupByEmail? { __data["userLookupByEmail"] }

      /// UserLookupByEmail
      ///
      /// Parent Type: `User`
      public struct UserLookupByEmail: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ApolloGeneratedGraphQL.ID.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("email", String.self),
          .field("profilePictureUrl", String?.self),
        ] }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        public var firstName: String { __data["firstName"] }
        public var lastName: String { __data["lastName"] }
        public var email: String { __data["email"] }
        public var profilePictureUrl: String? { __data["profilePictureUrl"] }
      }
    }
  }

}