// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class GetOAuthLoginsQuery: GraphQLQuery {
    public static let operationName: String = "GetOAuthLogins"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetOAuthLogins {
          selfLookup {
            __typename
            oauthLoginIds {
              __typename
              type
              id
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
          .field("oauthLoginIds", [ApolloGeneratedGraphQL.OAuthTypeCorrelation].self),
        ] }

        public var oauthLoginIds: [ApolloGeneratedGraphQL.OAuthTypeCorrelation] { __data["oauthLoginIds"] }
      }
    }
  }

}