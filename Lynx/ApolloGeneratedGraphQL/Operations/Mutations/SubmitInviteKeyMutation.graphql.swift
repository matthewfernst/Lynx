// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class SubmitInviteKeyMutation: GraphQLMutation {
    public static let operationName: String = "SubmitInviteKey"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation SubmitInviteKey($inviteKey: ID!) {
          resolveInviteKey(inviteKey: $inviteKey) {
            __typename
            validatedInvite
          }
        }
        """#
      ))

    public var inviteKey: ID

    public init(inviteKey: ID) {
      self.inviteKey = inviteKey
    }

    public var __variables: Variables? { ["inviteKey": inviteKey] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("resolveInviteKey", ResolveInviteKey.self, arguments: ["inviteKey": .variable("inviteKey")]),
      ] }

      public var resolveInviteKey: ResolveInviteKey { __data["resolveInviteKey"] }

      /// ResolveInviteKey
      ///
      /// Parent Type: `User`
      public struct ResolveInviteKey: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("validatedInvite", Bool.self),
        ] }

        public var validatedInvite: Bool { __data["validatedInvite"] }
      }
    }
  }

}