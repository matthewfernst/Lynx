// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class RefreshAccessTokenMutation: GraphQLMutation {
    public static let operationName: String = "RefreshAccessToken"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation RefreshAccessToken($refreshToken: ID!) {
          refreshLynxToken(refreshToken: $refreshToken) {
            __typename
            accessToken
            expiryDate
            refreshToken
          }
        }
        """#
      ))

    public var refreshToken: ID

    public init(refreshToken: ID) {
      self.refreshToken = refreshToken
    }

    public var __variables: Variables? { ["refreshToken": refreshToken] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("refreshLynxToken", RefreshLynxToken?.self, arguments: ["refreshToken": .variable("refreshToken")]),
      ] }

      public var refreshLynxToken: RefreshLynxToken? { __data["refreshLynxToken"] }

      /// RefreshLynxToken
      ///
      /// Parent Type: `AuthorizationToken`
      public struct RefreshLynxToken: ApolloGeneratedGraphQL.SelectionSet {
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