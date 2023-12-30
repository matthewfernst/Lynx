// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class LoginOrCreateUserMutation: GraphQLMutation {
    public static let operationName: String = "LoginOrCreateUser"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation LoginOrCreateUser($oauthLoginId: OAuthTypeCorrelationInput!, $email: String, $userData: [UserDataPair!]) {
          createUserOrSignIn(
            oauthLoginId: $oauthLoginId
            email: $email
            userData: $userData
          ) {
            __typename
            token
            expiryDate
            validatedInvite
          }
        }
        """#
      ))

    public var oauthLoginId: OAuthTypeCorrelationInput
    public var email: GraphQLNullable<String>
    public var userData: GraphQLNullable<[UserDataPair]>

    public init(
      oauthLoginId: OAuthTypeCorrelationInput,
      email: GraphQLNullable<String>,
      userData: GraphQLNullable<[UserDataPair]>
    ) {
      self.oauthLoginId = oauthLoginId
      self.email = email
      self.userData = userData
    }

    public var __variables: Variables? { [
      "oauthLoginId": oauthLoginId,
      "email": email,
      "userData": userData
    ] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createUserOrSignIn", CreateUserOrSignIn?.self, arguments: [
          "oauthLoginId": .variable("oauthLoginId"),
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
          .field("validatedInvite", Bool.self),
        ] }

        public var token: ApolloGeneratedGraphQL.ID { __data["token"] }
        public var expiryDate: String { __data["expiryDate"] }
        public var validatedInvite: Bool { __data["validatedInvite"] }
      }
    }
  }

}