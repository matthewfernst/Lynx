// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class OauthSignInMutation: GraphQLMutation {
    public static let operationName: String = "oauthSignIn"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation oauthSignIn($oauthLoginId: OAuthTypeCorrelationInput!, $email: String, $userData: [KeyValuePair!]) {
          oauthSignIn(oauthLoginId: $oauthLoginId, email: $email, userData: $userData) {
            __typename
            accessToken
            expiryDate
            refreshToken
          }
        }
        """#
      ))

    public var oauthLoginId: OAuthTypeCorrelationInput
    public var email: GraphQLNullable<String>
    public var userData: GraphQLNullable<[KeyValuePair]>

    public init(
      oauthLoginId: OAuthTypeCorrelationInput,
      email: GraphQLNullable<String>,
      userData: GraphQLNullable<[KeyValuePair]>
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
        .field("oauthSignIn", OauthSignIn?.self, arguments: [
          "oauthLoginId": .variable("oauthLoginId"),
          "email": .variable("email"),
          "userData": .variable("userData")
        ]),
      ] }

      public var oauthSignIn: OauthSignIn? { __data["oauthSignIn"] }

      /// OauthSignIn
      ///
      /// Parent Type: `AuthorizationToken`
      public struct OauthSignIn: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.AuthorizationToken }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("accessToken", ApolloGeneratedGraphQL.ID.self),
          .field("expiryDate", String.self),
          .field("refreshToken", ApolloGeneratedGraphQL.ID.self),
        ] }

        public var accessToken: ApolloGeneratedGraphQL.ID { __data["accessToken"] }
        public var expiryDate: String { __data["expiryDate"] }
        public var refreshToken: ApolloGeneratedGraphQL.ID { __data["refreshToken"] }
      }
    }
  }

}