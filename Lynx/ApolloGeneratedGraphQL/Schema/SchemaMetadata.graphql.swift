// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol ApolloGeneratedGraphQL_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == ApolloGeneratedGraphQL.SchemaMetadata {}

public protocol ApolloGeneratedGraphQL_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == ApolloGeneratedGraphQL.SchemaMetadata {}

public protocol ApolloGeneratedGraphQL_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == ApolloGeneratedGraphQL.SchemaMetadata {}

public protocol ApolloGeneratedGraphQL_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == ApolloGeneratedGraphQL.SchemaMetadata {}

public extension ApolloGeneratedGraphQL {
  typealias ID = String

  typealias SelectionSet = ApolloGeneratedGraphQL_SelectionSet

  typealias InlineFragment = ApolloGeneratedGraphQL_InlineFragment

  typealias MutableSelectionSet = ApolloGeneratedGraphQL_MutableSelectionSet

  typealias MutableInlineFragment = ApolloGeneratedGraphQL_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    public static func objectType(forTypename typename: String) -> Object? {
      switch typename {
      case "Query": return ApolloGeneratedGraphQL.Objects.Query
      case "User": return ApolloGeneratedGraphQL.Objects.User
      case "OAuthTypeCorrelation": return ApolloGeneratedGraphQL.Objects.OAuthTypeCorrelation
      case "Log": return ApolloGeneratedGraphQL.Objects.Log
      case "LogDetail": return ApolloGeneratedGraphQL.Objects.LogDetail
      case "Mutation": return ApolloGeneratedGraphQL.Objects.Mutation
      case "AuthorizationToken": return ApolloGeneratedGraphQL.Objects.AuthorizationToken
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}