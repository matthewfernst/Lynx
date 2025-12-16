// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol ApolloGeneratedGraphQL_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI
    .RootSelectionSet
where Schema == ApolloGeneratedGraphQL.SchemaMetadata {}

public protocol ApolloGeneratedGraphQL_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI
    .InlineFragment
where Schema == ApolloGeneratedGraphQL.SchemaMetadata {}

public protocol ApolloGeneratedGraphQL_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == ApolloGeneratedGraphQL.SchemaMetadata {}

public protocol ApolloGeneratedGraphQL_MutableInlineFragment: ApolloAPI.MutableSelectionSet
    & ApolloAPI.InlineFragment
where Schema == ApolloGeneratedGraphQL.SchemaMetadata {}

extension ApolloGeneratedGraphQL {
  public typealias ID = String

  public typealias SelectionSet = ApolloGeneratedGraphQL_SelectionSet

  public typealias InlineFragment = ApolloGeneratedGraphQL_InlineFragment

  public typealias MutableSelectionSet = ApolloGeneratedGraphQL_MutableSelectionSet

  public typealias MutableInlineFragment = ApolloGeneratedGraphQL_MutableInlineFragment

  public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    public static func objectType(forTypename typename: String) -> Object? {
      switch typename {
      case "Query": return ApolloGeneratedGraphQL.Objects.Query
      case "User": return ApolloGeneratedGraphQL.Objects.User
      case "OAuthTypeCorrelation": return ApolloGeneratedGraphQL.Objects.OAuthTypeCorrelation
      case "UserStats": return ApolloGeneratedGraphQL.Objects.UserStats
      case "Party": return ApolloGeneratedGraphQL.Objects.Party
      case "Log": return ApolloGeneratedGraphQL.Objects.Log
      case "LogDetail": return ApolloGeneratedGraphQL.Objects.LogDetail
      case "Mutation": return ApolloGeneratedGraphQL.Objects.Mutation
      case "AuthorizationToken": return ApolloGeneratedGraphQL.Objects.AuthorizationToken
      default: return nil
      }
    }
  }

  public enum Objects {}
  public enum Interfaces {}
  public enum Unions {}

}
