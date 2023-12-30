// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class CreateInviteKeyMutation: GraphQLMutation {
    public static let operationName: String = "CreateInviteKey"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation CreateInviteKey {
          createInviteKey
        }
        """#
      ))

    public init() {}

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("createInviteKey", String.self),
      ] }

      public var createInviteKey: String { __data["createInviteKey"] }
    }
  }

}