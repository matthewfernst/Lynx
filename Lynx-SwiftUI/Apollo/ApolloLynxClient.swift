import Foundation
import Apollo
import OSLog


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

extension ApolloGeneratedGraphQL.GetPartyDetailsQuery.Data.PartyLookupById.Leaderboard: Leaderboard {
    var stat: LeaderStat? {
        .partyLeaderStat(self.stats)
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
    case partyLeaderStat(ApolloGeneratedGraphQL.GetPartyDetailsQuery.Data.PartyLookupById.Leaderboard.Stats?)
}


final class ApolloLynxClient {
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
                
                Logger.apollo.debug("ProfileAttributes being returned:\n\(profileAttributes.debugDescription)")
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
    
    static func oauthSignIn(
        id: String,
        oauthType: String,
        oauthToken: String,
        email: String?,
        firstName: String?,
        lastName: String?,
        profilePictureURL: URL?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        

        Logger.apollo.debug("Login in with following: type               -> \(oauthType)")
        Logger.apollo.debug("                         id                 -> \(id)")
        Logger.apollo.debug("                         token              -> \(oauthToken)")
        Logger.apollo.debug("                         email              -> \(email ?? "nil")")
        Logger.apollo.debug("                         firstName          -> \(firstName ?? "nil")")
        Logger.apollo.debug("                         lastName           -> \(lastName ?? "nil")")
        Logger.apollo.debug("                         profilePictureUrl  -> \(profilePictureURL?.absoluteString ?? "nil")")

        
        var userData: [ApolloGeneratedGraphQL.KeyValuePair] = []
        var userDataNullable = GraphQLNullable<[ApolloGeneratedGraphQL.KeyValuePair]>(nilLiteral: ())
        
        // Dumb code. Would rather use compactMap but Apollo forces you to explicitly say the userData's each element 🤷‍♂️
        if let firstName = firstName, let lastName = lastName {
            userData.append(ApolloGeneratedGraphQL.KeyValuePair(key: "firstName", value: firstName))
            userData.append(ApolloGeneratedGraphQL.KeyValuePair(key: "lastName", value: lastName))
            if let profilePictureURL = profilePictureURL {
                userData.append(ApolloGeneratedGraphQL.KeyValuePair(key: "profilePictureUrl", value: profilePictureURL.absoluteString))
                userDataNullable = GraphQLNullable<[ApolloGeneratedGraphQL.KeyValuePair]>(arrayLiteral: userData[0], userData[1], userData[2])
            } else {
                userDataNullable = GraphQLNullable<[ApolloGeneratedGraphQL.KeyValuePair]>(arrayLiteral: userData[0], userData[1])
            }
        }
        
        let type = GraphQLEnum<ApolloGeneratedGraphQL.OAuthType>(rawValue: oauthType)
        let oauthLoginId = ApolloGeneratedGraphQL.OAuthTypeCorrelationInput(type: type, id: id, token: oauthToken)
        
        let emailNullable: GraphQLNullable<String>
        if email == nil {
            emailNullable = GraphQLNullable<String>(nilLiteral: ())
        } else {
            emailNullable = GraphQLNullable<String>(stringLiteral: email!)
        }
        
        apolloClient.perform(mutation: ApolloGeneratedGraphQL.OauthSignInMutation(
            oauthLoginId: oauthLoginId,
            email: emailNullable,
            userData: userDataNullable)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let data = graphQLResult.data?.oauthSignIn else {
                    let error = UserError.noAuthorizationTokenReturned
                    completion(.failure(error))
                    return
                }
                
                let accessToken = data.accessToken
                let refreshToken = data.refreshToken
                guard let expiryInMilliseconds = Double(data.expiryDate) else {
                    Logger.apollo.error("Could not convert expiryDate to Double.")
                    return
                }
                
                Logger.apollo.debug("LYNX ACCESS TOKEN ->                 \(accessToken)")
                Logger.apollo.debug("REFRESH TOKEN     ->                 \(refreshToken)")
                Logger.apollo.debug("EXPIRY DATE MS    ->                 \(expiryInMilliseconds)")
                
                UserManager.shared.lynxToken = ExpirableLynxToken(
                    accessToken: accessToken,
                    expirationDate: Calendar.current.date(byAdding: .second, value: 5, to: Date())!,
                    refreshToken: refreshToken
                )
                
                Logger.apollo.info("Successfully signed in user.")
                completion(.success(()))
                
            case .failure(let error):
                Logger.apollo.error("OauthSignIn mutation failed with Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    static func refreshAccessToken(refreshToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        apolloClient.perform(
            mutation: ApolloGeneratedGraphQL.RefreshAccessTokenMutation(refreshToken: refreshToken)
        ) { result in
            
            enum RefreshTokenError: Error {
                case failedToUnwrapData
                case convertExpiryDate
            }
            
            switch result {
            case .success(let graphQLResult):
                guard let data = graphQLResult.data?.refreshLynxToken else {
                    Logger.apollo.error("Failed to unwrap data when refreshing access token")
                    completion(.failure(RefreshTokenError.failedToUnwrapData))
                    return
                }
                guard 
                    let expiryInMilliseconds = Double(data.expiryDate) else {
                    Logger.apollo.error("Could not convert expiryDate to Double.")
                    completion(.failure(RefreshTokenError.convertExpiryDate))
                    return
                }
                
                Logger.apollo.debug("Refreshing Token")
                Logger.apollo.debug("ACCESS TOKEN         -> \(data.accessToken)")
                Logger.apollo.debug("REFRESH TOKEN        -> \(data.refreshToken)")
                Logger.apollo.debug("EXPIRY DATE          -> \(data.expiryDate)")
                
                UserManager.shared.lynxToken = ExpirableLynxToken(
                    accessToken: data.accessToken,
                    expirationDate: Date(timeIntervalSince1970: expiryInMilliseconds / 1000),
                    refreshToken: data.refreshToken
                )
                Logger.apollo.info("Successfully refreshed access token.")
                completion(.success(()))
                
            case .failure(let error):
                Logger.apollo.error("Failed to refresh access token: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    static func editUser(profileChanges: [String: Any], completion: @escaping ((Result<String, Error>) -> Void)) {
        
        enum EditUserErrors: Error {
            case editUserNil
            case profilePictureURLMissing
        }
        
        var userData: [ApolloGeneratedGraphQL.KeyValuePair] = []
        for (key, value) in profileChanges {
            let stringValue = String(describing: value)
            userData.append(ApolloGeneratedGraphQL.KeyValuePair(key: key, value: stringValue))
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
                print(uploadedSlopeFiles)
                Logger.apollo.info("Successfully retrieved logs.")
                return completion(.success(uploadedSlopeFiles))
                
            case .failure(_):
                Logger.apollo.error("Error querying users logbook.")
                completion(.failure(QueryLogbookErrors.queryFailed))
            }
        }
    }
    
    static func getLogs(measurementSystem: MeasurementSystem, completion: @escaping ((Result<Logbooks, Error>) -> Void)) {
        apolloClient.fetch(query: ApolloGeneratedGraphQL.GetLogsQuery(system: .init(measurementSystem))) { result in
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
    
    static func deleteAccount(
        token: String,
        type: ApolloGeneratedGraphQL.OAuthType,
        completion: @escaping ((Result<Void, Error>) -> Void)
    ) {
        enum DeleteAccountErrors: Error {
            case UnwrapOfReturnedUserFailed
            case BackendCouldntDelete
        }
        
        apolloClient.perform(mutation: ApolloGeneratedGraphQL.DeleteAccountMutation()) { result in
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

    // MARK: - Party Managementz
    static func getParties(completion: @escaping ((Result<[PartyAttributes], Error>) -> Void)) {
        enum GetPartiesError: Error {
            case unwrapError
        }

        apolloClient.fetch(query: ApolloGeneratedGraphQL.GetPartiesQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                guard let parties = graphQLResult.data?.selfLookup?.parties else {
                    Logger.apollo.error("Failed to unwrap parties.")
                    completion(.failure(GetPartiesError.unwrapError))
                    return
                }

                let partyAttributes = parties.map { party in
                    PartyAttributes(
                        id: party.id,
                        name: party.name,
                        description: party.description,
                        partyManagerId: party.partyManager.id,
                        partyManagerName: "\(party.partyManager.firstName) \(party.partyManager.lastName)",
                        partyManagerProfilePictureURL: URL(string: party.partyManager.profilePictureUrl ?? ""),
                        userCount: party.users.count,
                        invitedUserCount: party.invitedUsers.count
                    )
                }

                Logger.apollo.info("Successfully got parties.")
                completion(.success(partyAttributes))

            case .failure(let error):
                Logger.apollo.error("Error fetching parties: \(error)")
                completion(.failure(error))
            }
        }
    }

    static func getPartyInvites(completion: @escaping ((Result<[PartyAttributes], Error>) -> Void)) {
        enum GetPartyInvitesError: Error {
            case unwrapError
        }

        apolloClient.fetch(query: ApolloGeneratedGraphQL.GetPartyInvitesQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                guard let invites = graphQLResult.data?.selfLookup?.partyInvites else {
                    Logger.apollo.error("Failed to unwrap party invites.")
                    completion(.failure(GetPartyInvitesError.unwrapError))
                    return
                }

                let partyAttributes = invites.map { party in
                    PartyAttributes(
                        id: party.id,
                        name: party.name,
                        description: party.description,
                        partyManagerId: party.partyManager.id,
                        partyManagerName: "\(party.partyManager.firstName) \(party.partyManager.lastName)",
                        partyManagerProfilePictureURL: URL(string: party.partyManager.profilePictureUrl ?? ""),
                        userCount: party.users.count,
                        invitedUserCount: 0
                    )
                }

                Logger.apollo.info("Successfully got party invites.")
                completion(.success(partyAttributes))

            case .failure(let error):
                Logger.apollo.error("Error fetching party invites: \(error)")
                completion(.failure(error))
            }
        }
    }

    static func getPartyDetails(
        partyId: String,
        sortBy: LeaderboardSort = .verticalDistance,
        timeframe: Timeframe = .season,
        limit: Int = 5,
        completion: @escaping ((Result<PartyDetails, Error>) -> Void)
    ) {
        enum GetPartyDetailsError: Error {
            case unwrapError
        }

        apolloClient.fetch(
            query: ApolloGeneratedGraphQL.GetPartyDetailsQuery(
                partyId: partyId,
                sortBy: .some(.init(sortBy)),
                timeframe: .some(.init(timeframe)),
                limit: .some(limit)
            )
        ) { result in
            switch result {
            case .success(let graphQLResult):
                guard let party = graphQLResult.data?.partyLookupById else {
                    Logger.apollo.error("Failed to unwrap party details.")
                    completion(.failure(GetPartyDetailsError.unwrapError))
                    return
                }

                let users = party.users.map { user in
                    PartyUser(
                        id: user.id,
                        firstName: user.firstName,
                        lastName: user.lastName,
                        profilePictureURL: URL(string: user.profilePictureUrl ?? "")
                    )
                }

                let invitedUsers = party.invitedUsers.map { user in
                    PartyUser(
                        id: user.id,
                        firstName: user.firstName,
                        lastName: user.lastName,
                        profilePictureURL: URL(string: user.profilePictureUrl ?? "")
                    )
                }

                let leaderboard = party.leaderboard.map { leader in
                    PartyLeaderboardEntry(
                        id: leader.id,
                        firstName: leader.firstName,
                        lastName: leader.lastName,
                        profilePictureURL: URL(string: leader.profilePictureUrl ?? ""),
                        stats: leader.stats.map { stats in
                            UserStatsAttributes(
                                runCount: stats.runCount,
                                distance: stats.distance,
                                topSpeed: stats.topSpeed,
                                verticalDistance: stats.verticalDistance
                            )
                        }
                    )
                }

                let partyDetails = PartyDetails(
                    id: party.id,
                    name: party.name,
                    description: party.description,
                    partyManager: PartyUser(
                        id: party.partyManager.id,
                        firstName: party.partyManager.firstName,
                        lastName: party.partyManager.lastName,
                        profilePictureURL: URL(string: party.partyManager.profilePictureUrl ?? "")
                    ),
                    users: users,
                    invitedUsers: invitedUsers,
                    leaderboard: leaderboard
                )

                Logger.apollo.info("Successfully got party details.")
                completion(.success(partyDetails))

            case .failure(let error):
                Logger.apollo.error("Error fetching party details: \(error)")
                completion(.failure(error))
            }
        }
    }

    static func getAllPartyLeaderboards(
        partyId: String,
        for timeframe: Timeframe,
        limit: Int?,
        inMeasurementSystem system: MeasurementSystem,
        completion: @escaping ((Result<[LeaderboardSort: [LeaderAttributes]], Error>) -> Void)
    ) {
        let nullableLimit: GraphQLNullable<Int> = (limit != nil) ? .init(integerLiteral: limit!) : .null
        var leaderboardAttributes: [LeaderboardSort: [LeaderAttributes]] = [:]
        let dispatchGroup = DispatchGroup()
        var fetchError: Error?

        for sort in LeaderboardSort.allCases {
            dispatchGroup.enter()

            apolloClient.fetch(
                query: ApolloGeneratedGraphQL.GetPartyDetailsQuery(
                    partyId: partyId,
                    sortBy: .some(.init(sort)),
                    timeframe: .some(.init(timeframe)),
                    limit: nullableLimit
                )
            ) { result in
                defer { dispatchGroup.leave() }

                switch result {
                case .success(let graphQLResult):
                    guard let leaders = graphQLResult.data?.partyLookupById?.leaderboard else {
                        return
                    }

                    var leadersAttributes: [LeaderAttributes] = []
                    for leader in leaders {
                        leadersAttributes.append(
                            LeaderAttributes(
                                leader: leader,
                                category: sort,
                                profilePictureURL: URL(string: leader.profilePictureUrl ?? "")
                            )
                        )
                    }

                    leaderboardAttributes[sort] = leadersAttributes
                case .failure(let error):
                    if fetchError == nil {
                        fetchError = error
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            if let error = fetchError {
                Logger.apollo.error("Error getting all party leaderboards: \(error)")
                completion(.failure(error))
            } else {
                Logger.apollo.info("Successfully got all party leaderboards")
                completion(.success(leaderboardAttributes))
            }
        }
    }

    static func getSpecificPartyLeaderboard(
        partyId: String,
        for timeframe: Timeframe,
        sortBy sort: LeaderboardSort,
        limit: Int = 100,
        inMeasurementSystem system: MeasurementSystem,
        completion: @escaping ((Result<[LeaderAttributes], Error>) -> Void)
    ) {
        enum GetSpecificPartyLeaderboardError: Error {
            case unwrapError
        }

        apolloClient.fetch(
            query: ApolloGeneratedGraphQL.GetPartyDetailsQuery(
                partyId: partyId,
                sortBy: .some(.init(sort)),
                timeframe: .some(.init(timeframe)),
                limit: .some(limit)
            )
        ) { result in
            switch result {
            case .success(let graphQLResult):
                guard let leaders = graphQLResult.data?.partyLookupById?.leaderboard else {
                    Logger.apollo.error("Failed to unwrap specific party leaderboard.")
                    completion(.failure(GetSpecificPartyLeaderboardError.unwrapError))
                    return
                }

                var leaderData = [LeaderAttributes]()
                for leader in leaders {
                    leaderData.append(
                        LeaderAttributes(
                            leader: leader,
                            category: sort,
                            profilePictureURL: URL(string: leader.profilePictureUrl ?? "")
                        )
                    )
                }

                Logger.apollo.info("Successfully got specific party leaderboard.")
                completion(.success(leaderData))

            case .failure(let error):
                Logger.apollo.error("Error fetching specific party leaderboard: \(error)")
                completion(.failure(error))
            }
        }
    }

    static func createParty(name: String, description: String? = nil, completion: @escaping ((Result<PartyAttributes, Error>) -> Void)) {
        enum CreatePartyError: Error {
            case unwrapError
        }
        let descriptionGQL: GraphQLNullable<String> = (description == nil) ? .null : .some(description!)
        apolloClient.perform(mutation: ApolloGeneratedGraphQL.CreatePartyMutation(name: name, description: descriptionGQL)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let party = graphQLResult.data?.createParty else {
                    Logger.apollo.error("Failed to unwrap created party.")
                    completion(.failure(CreatePartyError.unwrapError))
                    return
                }

                let partyAttributes = PartyAttributes(
                    id: party.id,
                    name: party.name,
                    description: party.description,
                    partyManagerId: party.partyManager.id,
                    partyManagerName: "\(party.partyManager.firstName) \(party.partyManager.lastName)",
                    partyManagerProfilePictureURL: URL(string: party.partyManager.profilePictureUrl ?? ""),
                    userCount: party.users.count,
                    invitedUserCount: party.invitedUsers.count
                )

                Logger.apollo.info("Successfully created party.")
                completion(.success(partyAttributes))

            case .failure(let error):
                Logger.apollo.error("Error creating party: \(error)")
                completion(.failure(error))
            }
        }
    }

    static func editParty(partyId: String, partyChanges: [String: String], completion: @escaping ((Result<Void, Error>) -> Void)) {
        enum EditPartyError: Error {
            case unwrapError
        }

        let partyData = partyChanges.map { ApolloGeneratedGraphQL.KeyValuePair(key: $0.key, value: $0.value) }

        apolloClient.perform(mutation: ApolloGeneratedGraphQL.EditPartyMutation(partyId: partyId, partyData: partyData)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let _ = graphQLResult.data?.editParty else {
                    Logger.apollo.error("Failed to edit party.")
                    completion(.failure(EditPartyError.unwrapError))
                    return
                }

                Logger.apollo.info("Successfully edited party.")
                completion(.success(()))

            case .failure(let error):
                Logger.apollo.error("Error editing party: \(error)")
                completion(.failure(error))
            }
        }
    }

    static func deleteParty(partyId: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        enum DeletePartyError: Error {
            case unwrapError
        }

        apolloClient.perform(mutation: ApolloGeneratedGraphQL.DeletePartyMutation(partyId: partyId)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let _ = graphQLResult.data?.deleteParty else {
                    Logger.apollo.error("Failed to delete party.")
                    completion(.failure(DeletePartyError.unwrapError))
                    return
                }

                Logger.apollo.info("Successfully deleted party.")
                completion(.success(()))

            case .failure(let error):
                Logger.apollo.error("Error deleting party: \(error)")
                completion(.failure(error))
            }
        }
    }

    static func joinParty(partyId: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        enum JoinPartyError: Error {
            case unwrapError
        }

        apolloClient.perform(mutation: ApolloGeneratedGraphQL.JoinPartyMutation(partyId: partyId)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let _ = graphQLResult.data?.joinParty else {
                    Logger.apollo.error("Failed to join party.")
                    completion(.failure(JoinPartyError.unwrapError))
                    return
                }

                Logger.apollo.info("Successfully joined party.")
                completion(.success(()))

            case .failure(let error):
                Logger.apollo.error("Error joining party: \(error)")
                completion(.failure(error))
            }
        }
    }

    static func leaveParty(partyId: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        enum LeavePartyError: Error {
            case unwrapError
        }

        apolloClient.perform(mutation: ApolloGeneratedGraphQL.LeavePartyMutation(partyId: partyId)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let _ = graphQLResult.data?.leaveParty else {
                    Logger.apollo.error("Failed to leave party.")
                    completion(.failure(LeavePartyError.unwrapError))
                    return
                }

                Logger.apollo.info("Successfully left party.")
                completion(.success(()))

            case .failure(let error):
                Logger.apollo.error("Error leaving party: \(error)")
                completion(.failure(error))
            }
        }
    }

    static func inviteUserToParty(partyId: String, userId: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        enum InviteUserError: Error {
            case unwrapError
        }

        apolloClient.perform(mutation: ApolloGeneratedGraphQL.CreatePartyInviteMutation(partyId: partyId, userId: userId)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let _ = graphQLResult.data?.createPartyInvite else {
                    Logger.apollo.error("Failed to invite user to party.")
                    completion(.failure(InviteUserError.unwrapError))
                    return
                }

                Logger.apollo.info("Successfully invited user to party.")
                completion(.success(()))

            case .failure(let error):
                Logger.apollo.error("Error inviting user to party: \(error)")
                completion(.failure(error))
            }
        }
    }

    static func removeInviteFromParty(partyId: String, userId: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        enum RemoveInviteError: Error {
            case unwrapError
        }

        apolloClient.perform(mutation: ApolloGeneratedGraphQL.DeletePartyInviteMutation(partyId: partyId, userId: userId)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let _ = graphQLResult.data?.deletePartyInvite else {
                    Logger.apollo.error("Failed to remove invite from party.")
                    completion(.failure(RemoveInviteError.unwrapError))
                    return
                }

                Logger.apollo.info("Successfully removed invite from party.")
                completion(.success(()))

            case .failure(let error):
                Logger.apollo.error("Error removing invite from party: \(error)")
                completion(.failure(error))
            }
        }
    }

    static func removeUserFromParty(partyId: String, userId: String, completion: @escaping ((Result<Void, Error>) -> Void)) {
        enum RemoveUserError: Error {
            case unwrapError
        }

        apolloClient.perform(mutation: ApolloGeneratedGraphQL.RemoveUserFromPartyMutation(partyId: partyId, userId: userId)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let _ = graphQLResult.data?.removeUserFromParty else {
                    Logger.apollo.error("Failed to remove user from party.")
                    completion(.failure(RemoveUserError.unwrapError))
                    return
                }

                Logger.apollo.info("Successfully removed user from party.")
                completion(.success(()))

            case .failure(let error):
                Logger.apollo.error("Error removing user from party: \(error)")
                completion(.failure(error))
            }
        }
    }

    static func userLookupByEmail(email: String, completion: @escaping ((Result<PartyUser?, Error>) -> Void)) {
        apolloClient.fetch(query: ApolloGeneratedGraphQL.UserLookupByEmailQuery(email: email)) { result in
            switch result {
            case .success(let graphQLResult):
                guard let user = graphQLResult.data?.userLookupByEmail else {
                    Logger.apollo.info("No user found with email: \(email)")
                    completion(.success(nil))
                    return
                }

                let partyUser = PartyUser(
                    id: user.id,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    profilePictureURL: URL(string: user.profilePictureUrl ?? "")
                )

                Logger.apollo.info("Successfully found user by email.")
                completion(.success(partyUser))

            case .failure(let error):
                Logger.apollo.error("Error looking up user by email: \(error)")
                completion(.failure(error))
            }
        }
    }
}

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

struct PartyAttributes {
    let id: String
    let name: String
    let description: String?
    let partyManagerId: String
    let partyManagerName: String
    let partyManagerProfilePictureURL: URL?
    let userCount: Int
    let invitedUserCount: Int
}

struct PartyUser : Equatable {
    let id: String
    let firstName: String
    let lastName: String
    let profilePictureURL: URL?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

struct UserStatsAttributes {
    let runCount: Int
    let distance: Double
    let topSpeed: Double
    let verticalDistance: Double
}

struct PartyLeaderboardEntry {
    let id: String
    let firstName: String
    let lastName: String
    let profilePictureURL: URL?
    let stats: UserStatsAttributes?
}

struct PartyDetails {
    let id: String
    let name: String
    let description: String?
    let partyManager: PartyUser
    let users: [PartyUser]
    let invitedUsers: [PartyUser]
    let leaderboard: [PartyLeaderboardEntry]
}

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

extension MeasurementSystem: Codable { }
