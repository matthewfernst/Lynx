// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class LeavePartyMutation: GraphQLMutation {
    public static let operationName: String = "LeaveParty"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation LeaveParty($partyId: ID!) {
          leaveParty(partyId: $partyId) {
            __typename
            id
            parties {
              __typename
              id
              name
            }
          }
        }
        """#
      ))

    public var partyId: ID

    public init(partyId: ID) {
      self.partyId = partyId
    }

    public var __variables: Variables? { ["partyId": partyId] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("leaveParty", LeaveParty.self, arguments: ["partyId": .variable("partyId")]),
      ] }

      public var leaveParty: LeaveParty { __data["leaveParty"] }

      /// LeaveParty
      ///
      /// Parent Type: `User`
      public struct LeaveParty: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ApolloGeneratedGraphQL.ID.self),
          .field("parties", [Party].self),
        ] }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        public var parties: [Party] { __data["parties"] }

        /// LeaveParty.Party
        ///
        /// Parent Type: `Party`
        public struct Party: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Party }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", ApolloGeneratedGraphQL.ID.self),
            .field("name", String.self),
          ] }

          public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
          public var name: String { __data["name"] }
        }
      }
    }
  }

}