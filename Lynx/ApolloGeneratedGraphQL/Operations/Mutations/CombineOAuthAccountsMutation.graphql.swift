// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class CombineOAuthAccountsMutation: GraphQLMutation {
    public static let operationName: String = "CombineOAuthAccounts"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation CombineOAuthAccounts($combineWith: LoginTypeCorrelationInput!) {
          combineOAuthAccounts(combineWith: $combineWith) {
            __typename
            id
            oauthLoginIds {
              __typename
              type
              id
            }
          }
        }
        """#
      ))

    public var combineWith: LoginTypeCorrelationInput

    public init(combineWith: LoginTypeCorrelationInput) {
      self.combineWith = combineWith
    }

    public var __variables: Variables? { ["combineWith": combineWith] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("combineOAuthAccounts", CombineOAuthAccounts.self, arguments: ["combineWith": .variable("combineWith")]),
      ] }

      public var combineOAuthAccounts: CombineOAuthAccounts { __data["combineOAuthAccounts"] }

      /// CombineOAuthAccounts
      ///
      /// Parent Type: `User`
      public struct CombineOAuthAccounts: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ApolloGeneratedGraphQL.ID.self),
          .field("oauthLoginIds", [OauthLoginId].self),
        ] }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        public var oauthLoginIds: [OauthLoginId] { __data["oauthLoginIds"] }

        /// CombineOAuthAccounts.OauthLoginId
        ///
        /// Parent Type: `LoginTypeCorrelation`
        public struct OauthLoginId: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.LoginTypeCorrelation }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("type", GraphQLEnum<ApolloGeneratedGraphQL.LoginType>.self),
            .field("id", String.self),
          ] }

          public var type: GraphQLEnum<ApolloGeneratedGraphQL.LoginType> { __data["type"] }
          public var id: String { __data["id"] }
        }
      }
    }
  }

}