// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  struct LeaderboardFields: ApolloGeneratedGraphQL.SelectionSet, Fragment {
    public static var fragmentDefinition: StaticString { """
      fragment leaderboardFields on User {
        __typename
        profilePictureUrl
        firstName
        lastName
      }
      """ }

    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("profilePictureUrl", String?.self),
      .field("firstName", String.self),
      .field("lastName", String.self),
    ] }

    public var profilePictureUrl: String? { __data["profilePictureUrl"] }
    public var firstName: String { __data["firstName"] }
    public var lastName: String { __data["lastName"] }
  }

}