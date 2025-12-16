// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension ApolloGeneratedGraphQL {
  public class JoinPartyMutation: GraphQLMutation {
    public static let operationName: String = "JoinParty"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation JoinParty($partyId: ID!) {
          joinParty(partyId: $partyId) {
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

      public static var __parentType: ApolloAPI.ParentType {
        ApolloGeneratedGraphQL.Objects.Mutation
      }
      public static var __selections: [ApolloAPI.Selection] {
        [
          .field("joinParty", JoinParty.self, arguments: ["partyId": .variable("partyId")])
        ]
      }

      public var joinParty: JoinParty { __data["joinParty"] }

      /// JoinParty
      ///
      /// Parent Type: `User`
      public struct JoinParty: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
        public static var __selections: [ApolloAPI.Selection] {
          [
            .field("__typename", String.self),
            .field("id", ApolloGeneratedGraphQL.ID.self),
            .field("parties", [Party].self),
          ]
        }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        public var parties: [Party] { __data["parties"] }

        /// JoinParty.Party
        ///
        /// Parent Type: `Party`
        public struct Party: ApolloGeneratedGraphQL.SelectionSet {
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

}
