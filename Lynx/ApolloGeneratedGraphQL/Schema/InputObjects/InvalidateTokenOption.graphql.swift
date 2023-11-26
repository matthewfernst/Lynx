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
      token: ID,
      type: GraphQLEnum<OAuthType>
    ) {
      __data = InputDict([
        "token": token,
        "type": type
      ])
    }

    public var token: ID {
      get { __data["token"] }
      set { __data["token"] = newValue }
    }

    public var type: GraphQLEnum<OAuthType> {
      get { __data["type"] }
      set { __data["type"] = newValue }
    }
  }

}