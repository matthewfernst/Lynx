// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension ApolloGeneratedGraphQL {
  struct DeleteUserOptions: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      tokensToInvalidate: GraphQLNullable<[InvalidateTokenOption]> = nil
    ) {
      __data = InputDict([
        "tokensToInvalidate": tokensToInvalidate
      ])
    }

    public var tokensToInvalidate: GraphQLNullable<[InvalidateTokenOption]> {
      get { __data["tokensToInvalidate"] }
      set { __data["tokensToInvalidate"] = newValue }
    }
  }

}