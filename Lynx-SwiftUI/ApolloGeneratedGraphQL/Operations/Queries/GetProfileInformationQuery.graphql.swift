// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class GetProfileInformationQuery: GraphQLQuery {
    public static let operationName: String = "GetProfileInformation"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetProfileInformation {
          selfLookup {
            __typename
            id
            oauthLoginIds {
              __typename
              type
              id
            }
            email
            firstName
            lastName
            profilePictureUrl
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
          .field("id", ApolloGeneratedGraphQL.ID.self),
          .field("oauthLoginIds", [OauthLoginId].self),
          .field("email", String.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("profilePictureUrl", String?.self),
        ] }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        public var oauthLoginIds: [OauthLoginId] { __data["oauthLoginIds"] }
        public var email: String { __data["email"] }
        public var firstName: String { __data["firstName"] }
        public var lastName: String { __data["lastName"] }
        public var profilePictureUrl: String? { __data["profilePictureUrl"] }

        /// SelfLookup.OauthLoginId
        ///
        /// Parent Type: `OAuthTypeCorrelation`
        public struct OauthLoginId: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.OAuthTypeCorrelation }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("type", GraphQLEnum<ApolloGeneratedGraphQL.OAuthType>.self),
            .field("id", ApolloGeneratedGraphQL.ID.self),
          ] }

          public var type: GraphQLEnum<ApolloGeneratedGraphQL.OAuthType> { __data["type"] }
          public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        }
      }
    }
  }

}