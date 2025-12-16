// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ApolloGeneratedGraphQL {
  public class DeleteAccountMutation: GraphQLMutation {
    public static let operationName: String = "DeleteAccount"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation DeleteAccount {
          deleteUser {
            __typename
            id
          }
        }
        """#
      ))

    public init() {}

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType {
        ApolloGeneratedGraphQL.Objects.Mutation
      }
      public static var __selections: [ApolloAPI.Selection] {
        [
          .field("deleteUser", DeleteUser.self)
        ]
      }

      public var deleteUser: DeleteUser { __data["deleteUser"] }

      /// DeleteUser
      ///
      /// Parent Type: `User`
      public struct DeleteUser: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
        public static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("id", ApolloGeneratedGraphQL.ID.self),
          ]
        }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
      }
    }
  }

}
