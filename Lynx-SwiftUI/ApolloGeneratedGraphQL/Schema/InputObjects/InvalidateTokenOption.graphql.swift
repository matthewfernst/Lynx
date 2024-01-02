// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension ApolloGeneratedGraphQL {
  struct InvalidateTokenOption: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      type: GraphQLEnum<OAuthType>,
      token: ID
    ) {
      __data = InputDict([
        "type": type,
        "token": token
      ])
    }

    public var type: GraphQLEnum<OAuthType> {
      get { __data["type"] }
      set { __data["type"] = newValue }
    }

    public var token: ID {
      get { __data["token"] }
      set { __data["token"] = newValue }
    }
  }

}