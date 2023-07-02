// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension ApolloGeneratedGraphQL {
  struct LoginTypeCorrelationInput: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      type: GraphQLEnum<LoginType>,
      id: String
    ) {
      __data = InputDict([
        "type": type,
        "id": id
      ])
    }

    public var type: GraphQLEnum<LoginType> {
      get { __data["type"] }
      set { __data["type"] = newValue }
    }

    public var id: String {
      get { __data["id"] }
      set { __data["id"] = newValue }
    }
  }

}