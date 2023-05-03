// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class LoginOrCreateUserMutation: GraphQLMutation {
    public static let operationName: String = "LoginOrCreateUser"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation LoginOrCreateUser($type: LoginType!, $id: ID!, $token: ID!, $email: String, $userData: [KeyValuePair!]) {
          createUserOrSignIn(
            type: $type
            id: $id
            token: $token
            email: $email
            userData: $userData
          ) {
            __typename
            token
            expiryDate
          }
        }
        """#
      ))

    public var type: GraphQLEnum<LoginType>
    public var id: ID
    public var token: ID
    public var email: GraphQLNullable<String>
    public var userData: GraphQLNullable<[KeyValuePair]>

    public init(
      type: GraphQLEnum<LoginType>,
      id: ID,
      token: ID,
      email: GraphQLNullable<String>,
      userData: GraphQLNullable<[KeyValuePair]>
    ) {
      self.type = type
      self.id = id
      self.token = token
      self.email = email
      self.userData = userData
    }

    public var __variables: Variables? { [
      "type": type,
      "id": id,
      "token": token,
      "email": email,
      "userData": userData
    ] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createUserOrSignIn", CreateUserOrSignIn?.self, arguments: [
          "type": .variable("type"),
          "id": .variable("id"),
          "token": .variable("token"),
          "email": .variable("email"),
          "userData": .variable("userData")
        ]),
      ] }

      public var createUserOrSignIn: CreateUserOrSignIn? { __data["createUserOrSignIn"] }

      /// CreateUserOrSignIn
      ///
      /// Parent Type: `AuthorizationToken`
      public struct CreateUserOrSignIn: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.AuthorizationToken }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("token", ApolloGeneratedGraphQL.ID.self),
          .field("expiryDate", String.self),
        ] }

        public var token: ApolloGeneratedGraphQL.ID { __data["token"] }
        public var expiryDate: String { __data["expiryDate"] }
      }
    }
  }

}