// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public extension ApolloGeneratedGraphQL {
  struct UserDataPair: InputObject {
    public private(set) var __data: InputDict

    public init(_ data: InputDict) {
      __data = data
    }

    public init(
      key: String,
      value: String
    ) {
      __data = InputDict([
        "key": key,
        "value": value
      ])
    }

    public var key: String {
      get { __data["key"] }
      set { __data["key"] = newValue }
    }

    public var value: String {
      get { __data["value"] }
      set { __data["value"] = newValue }
    }
  }

}