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
            appleId
            googleId
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
          .field("appleId", ApolloGeneratedGraphQL.ID?.self),
          .field("googleId", ApolloGeneratedGraphQL.ID?.self),
          .field("email", String.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("profilePictureUrl", String?.self),
        ] }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        public var appleId: ApolloGeneratedGraphQL.ID? { __data["appleId"] }
        public var googleId: ApolloGeneratedGraphQL.ID? { __data["googleId"] }
        public var email: String { __data["email"] }
        public var firstName: String { __data["firstName"] }
        public var lastName: String { __data["lastName"] }
        public var profilePictureUrl: String? { __data["profilePictureUrl"] }
      }
    }
  }

}