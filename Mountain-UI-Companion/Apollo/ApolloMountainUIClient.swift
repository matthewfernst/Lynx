//
//  Apollo.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 4/29/23.
//

import Foundation
import Apollo
import OSLog

class ApolloMountainUIClient
{
    static let graphQLEndpoint = Constants.graphQLEndpoint
    
    static let apolloClient: ApolloClient = {
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
    static let loginApolloClient = ApolloClient(url: URL(string: graphQLEndpoint)!)
    
    static func getProfileInformation(completion: @escaping (Result<ProfileAttributes, Error>) -> Void) {
        
        apolloClient.fetch(query: ApolloGeneratedGraphQL.GetProfileInformationQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                guard let selfLookup = graphQLResult.data?.selfLookup else {
                    Logger.apollo.error("selfLookup did not have any data.")
                    completion(.failure(UserError.noProfileAttributesReturned))
                    return
                }
                
                guard let (type, oauthId): (String, String) = {
                    switch (selfLookup.appleId, selfLookup.googleId) {
                    case (.some, _):
                        return ("APPLE", selfLookup.appleId!)
                    case (_, .some):
                        return ("GOOGLE", selfLookup.googleId!)
                    default:
                        return nil
                    }
                }() else {
                    Logger.apollo.error("AppleId and GoogleId were both null.")
                    return
                }
                
                guard let oauthToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.oauthToken) else {
                    Logger.apollo.error("oauthToken not found in UserDefaults.")
                    return
                }
                
                let profileAttributes = ProfileAttributes(type: type,
                                                          oauthToken: oauthToken,
                                                          id: oauthId,
                                                          email: selfLookup.email,
                                                          firstName: selfLookup.firstName,
                                                          lastName: selfLookup.lastName,
                                                          profilePictureURL: selfLookup.profilePictureUrl)
                Logger.apollo.debug("ProfileAttributes being returned:\n \(profileAttributes.debugDescription)")
                completion(.success(profileAttributes))
            case .failure(let error):
                Logger.apollo.error("\(error)")
                completion(.failure(error))
            }
        }
    }
    
    
    static func loginOrCreateUser(type: String, id: String, token: String, email: String?, firstName: String?, lastName: String?, profilePictureUrl: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        
        Logger.apollo.debug("Login in with following: type               -> \(type)")
        Logger.apollo.debug("                         id                 -> \(id)")
        Logger.apollo.debug("                         token              -> \(token)")
        Logger.apollo.debug("                         email              -> \(email ?? "nil")")
        Logger.apollo.debug("                         firstName          -> \(firstName ?? "nil")")
        Logger.apollo.debug("                         lastName           -> \(lastName ?? "nil")")
        Logger.apollo.debug("                         profilePictureUrl  -> \(profilePictureUrl ?? "nil")")
        
        
        var userData: [ApolloGeneratedGraphQL.KeyValuePair] = []
        var userDataNullable = GraphQLNullable<[ApolloGeneratedGraphQL.KeyValuePair]>(nilLiteral: ())
        
        if let firstName = firstName, let lastName = lastName, let profilePictureUrl = profilePictureUrl {
            userData.append(ApolloGeneratedGraphQL.KeyValuePair(key: "firstName", value: firstName))
            userData.append(ApolloGeneratedGraphQL.KeyValuePair(key: "lastName", value: lastName))
            userData.append(ApolloGeneratedGraphQL.KeyValuePair(key: "profilePictureUrl", value: profilePictureUrl))
            userDataNullable = GraphQLNullable<[ApolloGeneratedGraphQL.KeyValuePair]>(arrayLiteral: userData[0], userData[1], userData[2])
        }
        
        let type = GraphQLEnum<ApolloGeneratedGraphQL.LoginType>(rawValue: type)
        let emailNullable: GraphQLNullable<String>
        if email == nil {
            emailNullable = GraphQLNullable<String>(nilLiteral: ())
        } else {
            emailNullable = GraphQLNullable<String>(stringLiteral: email!)
        }
        
        loginApolloClient.perform(mutation: ApolloGeneratedGraphQL.LoginOrCreateUserMutation(type: type,
                                                                                             id: id,
                                                                                             token: token,
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
                
                guard let expiryInMilliseconds = Double(data.expiryDate) else {
                    Logger.apollo.error("Could not convert expiryDate to Double.")
                    return
                }
                let expiryInSeconds = expiryInMilliseconds / 1000.0
                
                let expirationDate = Date().addingTimeInterval(expiryInSeconds)
                
                UserManager.shared.token = ExpirableAuthorizationToken(authorizationToken: authorizationToken, expirationDate: expirationDate, oauthToken: token)
                
                completion(.success(()))
                
            case .failure(let error):
                Logger.apollo.error("LoginOrCreateUser mutation failed with Error: \(error)")
            }
            
        }
        
    }
    
    static func editUser(profileChanges: [String: Any], completion: @escaping ((Result<String, Error>) -> Void)) {
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
                    return
                }
                
                guard let newProfilePictureUrl = editUser.profilePictureUrl else {
                    Logger.apollo.error("Not able to find profilePictureUrl in editUser object.")
                    return
                }
                
                Logger.apollo.info("Successfully got editUser.profilePictureUrl.")
                print(newProfilePictureUrl)
                return completion(.success(newProfilePictureUrl))
                
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
    
//    static func createUserRecordUploadUrl(completion: @escaping ((Result<String, Error>) -> Void)) {
//        apolloClient.perform(mutation: ApolloGeneratedGraphQL.CreateRunRecordUploadUrlMutation()) { result in
//            switch result {
//            case .success(let graphQLResult):
//
//            }
//        }
//    }
    
}


// MARK: - ProfileAttributes
struct ProfileAttributes: CustomDebugStringConvertible
{
    var type: String
    var oauthToken: String
    var id: String
    var email: String
    var firstName: String
    var lastName: String
    var profilePictureURL: String
    
    init(type: String, oauthToken: String, id: String, email: String, firstName: String, lastName: String, profilePictureURL: String? = "") {
        self.type = type
        self.oauthToken = oauthToken
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.profilePictureURL = profilePictureURL ?? ""
    }
    
    var debugDescription: String {
       """
       id: \(self.id)
       type: \(self.type)
       oauthToken: \(self.oauthToken)
       firstName: \(self.firstName)
       lastName: \(self.lastName)
       email: \(self.email)
       profilePictureURL: \(String(describing: self.profilePictureURL))
       """
    }
}
