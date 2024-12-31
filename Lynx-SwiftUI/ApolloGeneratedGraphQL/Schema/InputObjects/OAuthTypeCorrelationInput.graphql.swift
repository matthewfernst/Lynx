// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension ApolloGeneratedGraphQL {
  struct OAuthTypeCorrelationInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      type: GraphQLEnum<OAuthType>,
      id: ID,
      token: ID
    ) {
      __data = InputDict([
        "type": type,
        "id": id,
        "token": token
      ])
    }

    public var type: GraphQLEnum<OAuthType> {
      get { __data["type"] }
      set { __data["type"] = newValue }
    }

    public var id: ID {
      get { __data["id"] }
      set { __data["id"] = newValue }
    }

    public var token: ID {
      get { __data["token"] }
      set { __data["token"] = newValue }
    }
  }

}