// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class GetUploadedLogsQuery: GraphQLQuery {
    public static let operationName: String = "GetUploadedLogs"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        query GetUploadedLogs {
          selfLookup {
            __typename
            logbook {
              __typename
              originalFileName
            }
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
          .field("logbook", [Logbook].self),
        ] }

        public var logbook: [Logbook] { __data["logbook"] }

        /// SelfLookup.Logbook
        ///
        /// Parent Type: `Log`
        public struct Logbook: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Log }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("originalFileName", String.self),
          ] }

          public var originalFileName: String { __data["originalFileName"] }
        }
      }
    }
  }

}