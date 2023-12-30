// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class CreateUserProfilePictureUploadUrlMutation: GraphQLMutation {
    public static let operationName: String = "CreateUserProfilePictureUploadUrl"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation CreateUserProfilePictureUploadUrl {
          createUserProfilePictureUploadUrl
        }
        """#
      ))

    public init() {}

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createUserProfilePictureUploadUrl", String.self),
      ] }

      public var createUserProfilePictureUploadUrl: String { __data["createUserProfilePictureUploadUrl"] }
    }
  }

}