// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class CreateRunRecordUploadUrlMutation: GraphQLMutation {
    public static let operationName: String = "CreateRunRecordUploadUrl"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation CreateRunRecordUploadUrl($requestedPaths: [String!]!) {
          createUserRecordUploadUrl(requestedPaths: $requestedPaths)
        }
        """#
      ))

    public var requestedPaths: [String]

    public init(requestedPaths: [String]) {
      self.requestedPaths = requestedPaths
    }

    public var __variables: Variables? { ["requestedPaths": requestedPaths] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createUserRecordUploadUrl", [String?].self, arguments: ["requestedPaths": .variable("requestedPaths")]),
      ] }

      public var createUserRecordUploadUrl: [String?] { __data["createUserRecordUploadUrl"] }
    }
  }

}