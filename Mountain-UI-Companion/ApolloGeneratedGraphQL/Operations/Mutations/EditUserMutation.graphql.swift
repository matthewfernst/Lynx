// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public extension ApolloGeneratedGraphQL {
  class EditUserMutation: GraphQLMutation {
    public static let operationName: String = "EditUser"
    public static let document: ApolloAPI.DocumentType = .notPersisted(
      definition: .init(
        #"""
        mutation EditUser($userData: [KeyValuePair!]!) {
          editUser(userData: $userData) {
            __typename
            id
            appleId
            googleId
            email
            firstName
            lastName
            profilePictureUrl
            logbook {
              __typename
              id
              conditions
              distance
              duration
              startDate
              endDate
              locationName
              runCount
              topSpeed
              verticalDistance
            }
          }
        }
        """#
      ))

    public var userData: [KeyValuePair]

    public init(userData: [KeyValuePair]) {
      self.userData = userData
    }

    public var __variables: Variables? { ["userData": userData] }

    public struct Data: ApolloGeneratedGraphQL.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("editUser", EditUser.self, arguments: ["userData": .variable("userData")]),
      ] }

      public var editUser: EditUser { __data["editUser"] }

      /// EditUser
      ///
      /// Parent Type: `User`
      public struct EditUser: ApolloGeneratedGraphQL.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.User }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", ApolloGeneratedGraphQL.ID.self),
          .field("appleId", ApolloGeneratedGraphQL.ID?.self),
          .field("googleId", ApolloGeneratedGraphQL.ID?.self),
          .field("email", String.self),
          .field("firstName", String.self),
          .field("lastName", String.self),
          .field("profilePictureUrl", String?.self),
          .field("logbook", [Logbook].self),
        ] }

        public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
        public var appleId: ApolloGeneratedGraphQL.ID? { __data["appleId"] }
        public var googleId: ApolloGeneratedGraphQL.ID? { __data["googleId"] }
        public var email: String { __data["email"] }
        public var firstName: String { __data["firstName"] }
        public var lastName: String { __data["lastName"] }
        public var profilePictureUrl: String? { __data["profilePictureUrl"] }
        public var logbook: [Logbook] { __data["logbook"] }

        /// EditUser.Logbook
        ///
        /// Parent Type: `Log`
        public struct Logbook: ApolloGeneratedGraphQL.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { ApolloGeneratedGraphQL.Objects.Log }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("id", ApolloGeneratedGraphQL.ID.self),
            .field("conditions", String.self),
            .field("distance", Double.self),
            .field("duration", Double.self),
            .field("startDate", String.self),
            .field("endDate", String.self),
            .field("locationName", String.self),
            .field("runCount", Int.self),
            .field("topSpeed", Double.self),
            .field("verticalDistance", Double.self),
          ] }

          public var id: ApolloGeneratedGraphQL.ID { __data["id"] }
          public var conditions: String { __data["conditions"] }
          public var distance: Double { __data["distance"] }
          public var duration: Double { __data["duration"] }
          public var startDate: String { __data["startDate"] }
          public var endDate: String { __data["endDate"] }
          public var locationName: String { __data["locationName"] }
          public var runCount: Int { __data["runCount"] }
          public var topSpeed: Double { __data["topSpeed"] }
          public var verticalDistance: Double { __data["verticalDistance"] }
        }
      }
    }
  }

}