//
//  Apollo.swift
//  Lynx
//
//  Created by Matthew Ernst on 4/29/23.
//

import Foundation
import Apollo
import OSLog


// MARK: - Apollo Typealiases
typealias Logbook = ApolloGeneratedGraphQL.GetLogsQuery.Data.SelfLookup.Logbook
typealias Logbooks = [Logbook]

typealias MeasurementSystem = ApolloGeneratedGraphQL.MeasurementSystem

typealias OAuthLoginIds = [ApolloGeneratedGraphQL.GetProfileInformationQuery.Data.SelfLookup.OauthLoginId]
typealias OAuthType = ApolloGeneratedGraphQL.OAuthType

typealias Timeframe = ApolloGeneratedGraphQL.Timeframe

protocol Leaderboard {
    var firstName: String { get }
    var lastName: String { get }
    var profilePictureUrl: String? { get }
    var stat: LeaderStat? { get }
}

extension ApolloGeneratedGraphQL.GetAllLeaderboardsQuery.Data.DistanceLeader: Leaderboard {
    var stat: LeaderStat? {
        .distanceStat(self.stats)
    }
}

extension ApolloGeneratedGraphQL.GetAllLeaderboardsQuery.Data.RunCountLeader: Leaderboard {
    var stat: LeaderStat? {
        .runCountStat(self.stats)
    }
}

extension ApolloGeneratedGraphQL.GetAllLeaderboardsQuery.Data.TopSpeedLeader: Leaderboard {
    var stat: LeaderStat? {
        .topSpeedStat(self.stats)
    }
}

extension ApolloGeneratedGraphQL.GetAllLeaderboardsQuery.Data.VerticalDistanceLeader: Leaderboard {
    var stat: LeaderStat? {
        .verticalDistanceStat(self.stats)
    }
}

extension ApolloGeneratedGraphQL.GetSpecificLeaderboardQuery.Data.Leaderboard: Leaderboard {
    var stat: LeaderStat? {
        .selectedLeaderStat(self.stats)
    }
}
typealias LeaderboardLeaders = [Leaderboard]

typealias LeaderboardSort = ApolloGeneratedGraphQL.LeaderboardSort

enum LeaderStat {
    case distanceStat(ApolloGeneratedGraphQL.GetAllLeaderboardsQuery.Data.DistanceLeader.Stats?)
    case runCountStat(ApolloGeneratedGraphQL.GetAllLeaderboardsQuery.Data.RunCountLeader.Stats?)
    case topSpeedStat(ApolloGeneratedGraphQL.GetAllLeaderboardsQuery.Data.TopSpeedLeader.Stats?)
    case verticalDistanceStat(ApolloGeneratedGraphQL.GetAllLeaderboardsQuery.Data.VerticalDistanceLeader.Stats?)
    case selectedLeaderStat(ApolloGeneratedGraphQL.GetSpecificLeaderboardQuery.Data.Leaderboard.Stats?)
}


class ApolloLynxClient {
    private static let graphQLEndpoint = "https://production.lynx-api.com/graphql"
    
    private static let apolloClient: ApolloClient = {
        // The cache is necessary to set up the store, which we're going
        // to hand to the provider
        let cache = InMemoryNormalizedCache()
        let store = ApolloStore(cache: cache)
        
        let client = URLSessionClient()
        let provider = NetworkInterceptorProvider(store: store, client: client)
        let url = URL(string: graphQLEndpoint)!
        
        let requestChainTransport = RequestChainNetworkTransport(
            interceptorProvider: provider,
            endpointURL: url
        )
        
        // Remember to give the store you already created to the client so it
        // doesn't create one on its own
        return ApolloClient(networkTransport: requestChainTransport, store: store)
    }()
    
    static func clearCache() {
        apolloClient.store.clearCache()
    }
    
    static func getProfileInformation(completion: @escaping (Result<ProfileAttributes, Error>) -> Void) {
        
        apolloClient.fetch(query: ApolloGeneratedGraphQL.GetProfileInformationQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                guard let selfLookup = graphQLResult.data?.selfLookup else {
                    Logger.apollo.error("selfLookup did not have any data.")
                    completion(.failure(UserError.noProfileAttributesReturned))
                    return
                }
                
                // TODO: First okay?
                let oauthIds = selfLookup.oauthLoginIds

                guard let oauthType = oauthIds.first?.type else {
                    Logger.apollo.error("oauthLoginIds failed to unwrap type.")
                    return
                }
                
                guard let id = oauthIds.first?.id else {
                    Logger.apollo.error("oauthLoginIds failed to unwrap id.")
                    return
                }
                
                var pictureURL: URL? = nil
                if let urlString = selfLookup.profilePictureUrl {
                    pictureURL = URL(string: urlString)
                }
                
                let profileAttributes = ProfileAttributes(
                    id: id,
                    oauthType: oauthType.rawValue,
                    email: selfLookup.email,
                    firstName: selfLookup.firstName,
                    lastName: selfLookup.lastName,
                    profilePictureURL: pictureURL
                )
                
                Logger.apollo.debug("ProfileAttributes being returned:\n \(profileAttributes.debugDescription)")
                completion(.success(profileAttributes))
                
            case .failure(let error):
                Logger.apollo.error("\(error)")
                completion(.failure(error))
            }
        }
    }
    
    static func getOAuthLoginTypes(completion: @escaping (Result<[String], Error>) -> Void) {
        
        apolloClient.fetch(query: ApolloGeneratedGraphQL.GetOAuthLoginsQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                guard let oauthLogins = graphQLResult.data?.selfLookup?.oauthLoginIds else {
                    Logger.apollo.error("OauthLogins failed in getOAuthLogins")
                    return
                }
                
                completion(.success(oauthLogins.map({ $0.type.rawValue })))
                
            case .failure(let error):
                Logger.apollo.error("Failed to get oauth login ids")
                completion(.failure(error))
            }
        }
    }
    
    static func loginOrCreateUser(
        id: String,
        oauthType: String,
        oauthToken: String,
        email: String?,
        firstName: String?,
        lastName: String?,
        profilePictureUrl: URL?,
        completion: @escaping (Result<Bool,
        Error>) -> Void
    ) {
        

        Logger.apollo.debug("Login in with following: type               -> \(oauthType)")
        Logger.apollo.debug("                         id                 -> \(id)")
        Logger.apollo.debug("                         token              -> \(oauthToken)")
        Logger.apollo.debug("                         email              -> \(email ?? "nil")")
        Logger.apollo.debug("                         firstName          -> \(firstName ?? "nil")")
        Logger.apollo.debug("                         lastName           -> \(lastName ?? "nil")")
        Logger.apollo.debug("                         profilePictureUrl  -> \(profilePictureUrl?.absoluteString ?? "nil")")

        
        var userData: [ApolloGeneratedGraphQL.UserDataPair] = []
        var userDataNullable = GraphQLNullable<[ApolloGeneratedGraphQL.UserDataPair]>(nilLiteral: ())
        
        if let firstName = firstName, let lastName = lastName, let profilePictureUrl = profilePictureUrl {
            userData.append(ApolloGeneratedGraphQL.UserDataPair(key: "firstName", value: firstName))
            userData.append(ApolloGeneratedGraphQL.UserDataPair(key: "lastName", value: lastName))
            userData.append(ApolloGeneratedGraphQL.UserDataPair(key: "profilePictureUrl", value: profilePictureUrl.absoluteString))
            userDataNullable = GraphQLNullable<[ApolloGeneratedGraphQL.UserDataPair]>(arrayLiteral: userData[0], userData[1], userData[2])
        }
        
        let type = GraphQLEnum<ApolloGeneratedGraphQL.OAuthType>(rawValue: oauthType)
        let oauthLoginId = ApolloGeneratedGraphQL.OAuthTypeCorrelationInput(type: type, id: id, token: oauthToken)
        
        let emailNullable: GraphQLNullable<String>
        if email == nil {
            emailNullable = GraphQLNullable<String>(nilLiteral: ())
        } else {
            emailNullable = GraphQLNullable<String>(stringLiteral: email!)
        }
        
        apolloClient.perform(mutation: ApolloGeneratedGraphQL.LoginOrCreateUserMutation(
            oauthLoginId: oauthLoginId,
            email: emailNullable,
            userData: userDataNullable)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let data = graphQLResult.data?.createUserOrSignIn else {
                    let error = UserError.noAuthorizationTokenReturned
                    completion(.failure(error))
                    return
                }
                
                let authorizationToken = data.token
                Logger.apollo.debug("OUR TOKEN ->                 \(authorizationToken)")
                guard let expiryInMilliseconds = Double(data.expiryDate) else {
                    Logger.apollo.error("Could not convert expiryDate to Double.")
                    return
                }
                
                UserManager.shared.token = ExpirableAuthorizationToken(
                    authorizationToken: authorizationToken,
                    expirationDate: Date(timeIntervalSince1970: expiryInMilliseconds / 1000)
                )
                
                completion(.success((data.validatedInvite)))
                
            case .failure(let error):
                Logger.apollo.error("LoginOrCreateUser mutation failed with Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    static func createInviteKey(completion: @escaping ((Result<String, Error>) -> Void)) {
        enum CreateInviteKeyError: Error {
            case failedToUnwrapData
        }
        apolloClient.perform(mutation: ApolloGeneratedGraphQL.CreateInviteKeyMutation()) { result in
            switch result {
            case .success(let graphQLResult):
                guard let inviteKey = graphQLResult.data?.createInviteKey else {
                    Logger.apollo.error("Error: Failed to unwrap data for invite key.")
                    completion(.failure(CreateInviteKeyError.failedToUnwrapData))
                    return
                }
                
                completion(.success(inviteKey))
                
            case .failure(let error):
                Logger.apollo.error("Error: Failed to create invite key with error \(error)")
                completion(.failure(error))
            }
        }
    }
    
    static func submitInviteKey(with invitationKey: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        enum InviteKeyError: Error {
            case failedValidateInvite
        }
        apolloClient.perform(mutation: ApolloGeneratedGraphQL.SubmitInviteKeyMutation(inviteKey: invitationKey)) { result in
            switch result {
            case .success(let graphQLResult):
                if let validatedInvite = graphQLResult.data?.resolveInviteKey.validatedInvite, validatedInvite {
                    completion(.success(()))
                } else {
                    completion(.failure(InviteKeyError.failedValidateInvite))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func editUser(profileChanges: [String: Any], completion: @escaping ((Result<String, Error>) -> Void)) {
        
        enum EditUserErrors: Error {
            case editUserNil
            case profilePictureURLMissing
        }
        
        var userData: [ApolloGeneratedGraphQL.UserDataPair] = []
        for (key, value) in profileChanges {
            let stringValue = String(describing: value)
            userData.append(ApolloGeneratedGraphQL.UserDataPair(key: key, value: stringValue))
        }
        
        apolloClient.perform(mutation: ApolloGeneratedGraphQL.EditUserMutation(userData: userData)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let editUser = graphQLResult.data?.editUser else {
                    Logger.apollo.error("editUser unwrapped to nil.")
                    completion(.failure(EditUserErrors.editUserNil))
                    return
                }
                
                guard let newProfilePictureUrl = editUser.profilePictureUrl else {
                    Logger.apollo.error("Not able to find profilePictureUrl in editUser object.")
                    completion(.failure(EditUserErrors.profilePictureURLMissing))
                    return
                }
                
                Logger.apollo.info("Successfully got editUser.profilePictureUrl.")
                print(newProfilePictureUrl)
                completion(.success(newProfilePictureUrl))
                
            case .failure(let error):
                Logger.apollo.error("Failed to Edit User Information. \(error)")
                completion(.failure(error))
            }
        }
    }
    
    static func createUserProfilePictureUploadUrl(completion: @escaping ((Result<String, Error>) -> Void)) {
        
        apolloClient.perform(mutation: ApolloGeneratedGraphQL.CreateUserProfilePictureUploadUrlMutation()) { result in
            switch result {
            case .success(let graphQLResult):
                guard let url = graphQLResult.data?.createUserProfilePictureUploadUrl else {
                    Logger.apollo.error("Unable to unwrap createUserProfilePictureUploadUrl")
                    return
                }
                Logger.apollo.info("Successfully retrieved createUserProfilePictureUrl.")
                Logger.apollo.debug("createUSerProfilePictureUrl: \(url)")
                completion(.success(url))
                
            case .failure(let error):
                Logger.apollo.error("Failed to retrieve createUserProfilePictureUrl.")
                completion(.failure(error))
            }
        }
    }
    
    static func createUserRecordUploadUrl(filesToUpload: [String], completion: @escaping ((Result<[String], Error>) -> Void)) {
        
        enum RunRecordURLErrors: Error {
            case nilURLs
            case mismatchNumberOfURLs
        }
        
        apolloClient.perform(mutation: ApolloGeneratedGraphQL.CreateRunRecordUploadUrlMutation(requestedPaths: filesToUpload)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let urls = graphQLResult.data?.createUserRecordUploadUrl else {
                    Logger.apollo.error("Unable to unwrap createUserRecordUploadUrl.")
                    return
                }
                
                if urls.contains(where: { $0 == nil }) {
                    Logger.apollo.error("One or more of the URL's returned contains nil.")
                    return completion(.failure(RunRecordURLErrors.nilURLs))
                }
                
                if filesToUpload.count != urls.count {
                    Logger.apollo.error("The number of URL's returned does not match the number of files requested for upload.")
                    return completion(.failure(RunRecordURLErrors.mismatchNumberOfURLs))
                }
                Logger.apollo.info("Successfully acquired urls for run record upload.")
                completion(.success(urls.compactMap { $0 })) // Unwrapping all internal url optionals
                
            case .failure(_):
                break
            }
        }
    }
    
    enum QueryLogbookErrors: Error {
        case logbookIsNil
        case queryFailed
    }
    
    static func getUploadedLogs(completion: @escaping ((Result<Set<String>, Error>) -> Void)) {
        
        apolloClient.fetch(query: ApolloGeneratedGraphQL.GetUploadedLogsQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                guard let logbook = graphQLResult.data?.selfLookup?.logbook else {
                    Logger.apollo.error("logbook could not be unwrapped.")
                    completion(.failure(QueryLogbookErrors.logbookIsNil))
                    return
                }
                
                let uploadedSlopeFiles = Set(logbook.map { $0.originalFileName.split(separator: "/").last.map(String.init) ?? "" })
                Logger.apollo.info("Successfully retrieved logs.")
                return completion(.success(uploadedSlopeFiles))
                
            case .failure(_):
                Logger.apollo.error("Error querying users logbook.")
                completion(.failure(QueryLogbookErrors.queryFailed))
            }
        }
    }
    
    static func getLogs(measurementSystem: MeasurementSystem, completion: @escaping ((Result<Logbooks, Error>) -> Void)) {
        
        let system = GraphQLEnum<ApolloGeneratedGraphQL.MeasurementSystem>(rawValue: measurementSystem.rawValue)
        
        apolloClient.fetch(query: ApolloGeneratedGraphQL.GetLogsQuery(system: system)) { result in
            switch result {
            case .success(let graphQLResult):
                guard var logbook = graphQLResult.data?.selfLookup?.logbook else {
                    Logger.apollo.error("logbook could not be unwrapped.")
                    completion(.failure(QueryLogbookErrors.logbookIsNil))
                    return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                
                logbook.sort { (a: Logbook, b: Logbook) in
                    let date1 = dateFormatter.date(from: a.startDate) ?? Date()
                    let date2 = dateFormatter.date(from: b.startDate) ?? Date()
                    
                    return date1 > date2
                }
                
                return completion(.success(logbook))
                
            case .failure(_):
                Logger.apollo.error("Error querying users logbook.")
                completion(.failure(QueryLogbookErrors.queryFailed))
            }
        }
    }
    
    static func deleteAccount(token: String, type: ApolloGeneratedGraphQL.OAuthType, completion: @escaping ((Result<Void, Error>) -> Void)) {
        enum DeleteAccountErrors: Error {
            case UnwrapOfReturnedUserFailed
            case BackendCouldntDelete
        }
        
        let deleteUserOptions = ApolloGeneratedGraphQL.DeleteUserOptions(tokensToInvalidate: GraphQLNullable<[ApolloGeneratedGraphQL.InvalidateTokenOption]>(arrayLiteral: ApolloGeneratedGraphQL.InvalidateTokenOption(token: token, type: GraphQLEnum(type))))
        
        apolloClient.perform(mutation: ApolloGeneratedGraphQL.DeleteAccountMutation(options: deleteUserOptions)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let _ = graphQLResult.data?.deleteUser.id else {
                    Logger.apollo.error("Couldn't unwrap delete user.")
                    completion(.failure(DeleteAccountErrors.UnwrapOfReturnedUserFailed))
                    return
                }
                
                Logger.apollo.info("Successfully deleted user.")
                completion(.success(()))
                
            case .failure(let error):
                Logger.apollo.error("Failed to delete user: \(error)")
                completion(.failure(DeleteAccountErrors.BackendCouldntDelete))
            }
        }
    }
    
    static func mergeAccount(with account: ApolloGeneratedGraphQL.OAuthTypeCorrelationInput, completion: @escaping ((Result<Void, Error>) -> Void)) {
        enum MergeAccountErrors: Error {
            case UnwrapOfReturnedUserFailed
            case BackendCouldntMerge
        }
        apolloClient.perform(mutation: ApolloGeneratedGraphQL.CombineOAuthAccountsMutation(combineWith: account)) { result in
            
            switch result {
            case .success(let graphQLResult):
                guard let _ = graphQLResult.data?.combineOAuthAccounts.id else {
                    Logger.apollo.error("Couldn't unwrap merge account id.")
                    completion(.failure(MergeAccountErrors.UnwrapOfReturnedUserFailed))
                    return
                }
                
                completion(.success(()))
                
            case .failure(let error):
                Logger.apollo.error("Failed to merge accounts: \(error)")
                completion(.failure(MergeAccountErrors.BackendCouldntMerge))
            }
        }
    }

    static func getAllLeaderboards(
        for timeframe: Timeframe,
        limit: Int?,
        inMeasurementSystem system: MeasurementSystem,
        completion: @escaping ((Result<[LeaderboardSort: [LeaderAttributes]], Error>) -> Void)
    ) {
        enum GetAllLeadersErrors: Error {
            case unableToUnwrap
        }
        
        let nullableLimit: GraphQLNullable<Int> = (limit != nil) ? .init(integerLiteral: limit!) : .null
        let enumSystem = GraphQLEnum<MeasurementSystem>(rawValue: system.rawValue)
        apolloClient.fetch(
            query: ApolloGeneratedGraphQL.GetAllLeaderboardsQuery(
                timeframe: .case(timeframe),
                limit: nullableLimit,
                measurementSystem: enumSystem
            )
        ) { result in
            switch result {
            case .success(let graphQLResult):

                guard let data = graphQLResult.data else {
                    Logger.apollo.error("Error unwrapping All Leaders data")
                    completion(.failure(GetAllLeadersErrors.unableToUnwrap))
                    return
                }

                // Create a dispatch group to track ongoing profile picture downloads
                var leaderboardAttributes: [LeaderboardSort: [LeaderAttributes]] = [:]

                for sort in LeaderboardSort.allCases {
                    var leadersAttributes: [LeaderAttributes] = []

                    let leaders: [Leaderboard]

                    switch sort {
                    case .distance:
                        Logger.apollo.debug("Successfully got distance leaders")
                        leaders = data.distanceLeaders
                    case .runCount:
                        Logger.apollo.debug("Successfully got run count leaders")
                        leaders = data.runCountLeaders
                    case .topSpeed:
                        Logger.apollo.debug("Successfully got top speed leaders")
                        leaders = data.topSpeedLeaders
                    case .verticalDistance:
                        Logger.apollo.debug("Successfully got vertical distance leaders")
                        leaders = data.verticalDistanceLeaders
                    }

                    for leader in leaders {
                        leadersAttributes.append(
                            LeaderAttributes(
                                leader: leader,
                                category: sort,
                                profilePictureURL: URL(string: leader.profilePictureUrl!)
                            )
                        )
                    }
                    leaderboardAttributes[sort] = leadersAttributes
                }
                
                Logger.apollo.info("Successfully got all leaders")
                completion(.success(leaderboardAttributes))
                
            case .failure(let error):
                Logger.apollo.error("Error Fetching All Leaders: \(error)")
                completion(.failure(error))
            }
        }
    }

    
    static func getSpecificLeaderboardAllTime(
        for timeframe: Timeframe,
        sortBy sort: LeaderboardSort,
        inMeasurementSystem system: MeasurementSystem,
        completion: @escaping ((Result<[LeaderAttributes], Error>) -> Void)
    ) {
        
        enum SelectedLeaderboardError: Error {
            case unwrapError
        }
        
        let graphqlifiedSystem = GraphQLEnum<MeasurementSystem>(rawValue: system.rawValue)
        let graphqlifiedSort = GraphQLEnum<LeaderboardSort>(rawValue: sort.rawValue)
        apolloClient.fetch(
            query: ApolloGeneratedGraphQL.GetSpecificLeaderboardQuery(
                timeframe: .case(timeframe),
                sortBy: graphqlifiedSort,
                measurementSystem: graphqlifiedSystem
            )
        ) { result in
            
            switch result {
            case .success(let graphQLResult):
                guard let leaders = graphQLResult.data?.leaderboard else {
                    Logger.apollo.error("Failed to unwrap selected leaderboard.")
                    completion(.failure(SelectedLeaderboardError.unwrapError))
                    return
                }
                
                var leaderData = [LeaderAttributes]()
                
                for leader in leaders {
                    leaderData.append(
                        LeaderAttributes(
                            leader: leader,
                            category: sort,
                            profilePictureURL: URL(string: leader.profilePictureUrl!)
                        )
                    )
                }
                
                Logger.apollo.info("Successfully got specific leaders.")
                completion(.success(leaderData))
                
            case .failure(let error):
                Logger.apollo.error("Error Fetching Selected Leaderbords: \(error)")
                completion(.failure(error))
            }
        }
    }
}


// MARK: - ProfileAttributes
struct ProfileAttributes: CustomDebugStringConvertible {
    var id: String
    var oauthType: String
    var email: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var profilePictureURL: URL? = nil
    
    init(
        id: String,
        oauthType: String,
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        profilePictureURL: URL? = nil
    ) {
        self.id = id
        self.oauthType = oauthType
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.profilePictureURL = profilePictureURL
    }
    
    var debugDescription: String {
       """
       id: \(self.id)
       oauthType: \(self.oauthType)
       firstName: \(self.firstName ?? "Johnny")
       lastName: \(self.lastName ?? "Appleseed")
       email: \(self.email ?? "johnny.appleseed@email.com")
       profilePictureURL: \(String(describing: self.profilePictureURL))
       """
    }
}

// MARK: - Extensions of ApolloGraphQL 
extension MeasurementSystem {
    var feetOrMeters: String {
        switch self {
        case .imperial:
            return "FT"
        case .metric:
            return "M"
        }
    }
    
    var milesOrKilometersPerHour: String {
        switch self {
        case .imperial:
            return "MPH"
        case .metric:
            return "KPH"
        }
    }
}

// MARK: - Extension for SwiftData
extension MeasurementSystem: Codable { }
