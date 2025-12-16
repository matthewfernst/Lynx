// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ApolloGeneratedGraphQL {
  public class DeletePartyMutation: GraphQLMutation {
    public static let operationName: String = "DeleteParty"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation DeleteParty($partyId: ID!) {
          deleteParty(partyId: $partyId) {
            __typename
            id
            name
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

      public static var __parentType: ApolloAPI.ParentType {
        ApolloGeneratedGraphQL.Objects.Mutation
      }
      public static var __selections: [ApolloAPI.Selection] {
        [
          .field("deleteParty", DeleteParty.self, arguments: ["partyId": .variable("partyId")])
        ]
      }

      public var deleteParty: DeleteParty { __data["deleteParty"] }

      /// DeleteParty
      ///
      /// Parent Type: `Party`
      public struct DeleteParty: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType {
          ApolloGeneratedGraphQL.Objects.Party
        }
        public static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("id", ApolloGeneratedGraphQL.ID.self),
            .field("name", String.self),
          ]
        }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        public var name: String { __data["name"] }
      }
    }
  }

}
