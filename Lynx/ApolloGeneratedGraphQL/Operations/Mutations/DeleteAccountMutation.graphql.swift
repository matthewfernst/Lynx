// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class DeleteAccountMutation: GraphQLMutation {
    public static let operationName: String = "DeleteAccount"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation DeleteAccount($options: DeleteUserOptions!) {
          deleteUser(options: $options) {
            __typename
            id
          }
        }
        """#
      ))

    public var options: DeleteUserOptions

    public init(options: DeleteUserOptions) {
      self.options = options
    }

    public var __variables: Variables? { ["options": options] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("deleteUser", DeleteUser.self, arguments: ["options": .variable("options")]),
      ] }

      public var deleteUser: DeleteUser { __data["deleteUser"] }

      /// DeleteUser
      ///
      /// Parent Type: `User`
      public struct DeleteUser: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ApolloGeneratedGraphQL.ID.self),
        ] }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
      }
    }
  }

}