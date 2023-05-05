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
    static let graphQLEndpoint = "https://7dabklh4i4.execute-api.us-west-1.amazonaws.com/production/graphql"
    
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
                
                let profileAttributes = ProfileAttributes(id: selfLookup.id,
                                                          email: selfLookup.email,
                                                          firstName: selfLookup.firstName,
                                                          lastName: selfLookup.lastName,
                                                          profilePictureURL: selfLookup.profilePictureUrl ?? "nil")
                Logger.apollo.debug("ProfileAttributes retrieved: \(profileAttributes.debugDescription)")
                completion(.success(profileAttributes))
            case .failure(let error):
                Logger.apollo.error("\(error)")
                completion(.failure(error))
            }
        }
    }
    
    
    
    static func loginOrCreateUser(type: String, id: String, token: String, email: String?, firstName: String?, lastName: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        
        Logger.apollo.debug("Login in with following: type      -> \(type)")
        Logger.apollo.debug("                         id        -> \(id)")
        Logger.apollo.debug("                         token     -> \(token)")
        Logger.apollo.debug("                         email     -> \(email ?? "nil")")
        Logger.apollo.debug("                         firstName -> \(firstName ?? "nil")")
        Logger.apollo.debug("                         lastName  -> \(lastName ?? "nil")")
        
        
        var userData: [ApolloGeneratedGraphQL.KeyValuePair] = []
        var userDataNullable = GraphQLNullable<[ApolloGeneratedGraphQL.KeyValuePair]>(nilLiteral: ())
        // TODO: ProfilePicture
        if let firstName = firstName, let lastName = lastName {
            userData.append(ApolloGeneratedGraphQL.KeyValuePair(key: "firstName", value: firstName))
            userData.append(ApolloGeneratedGraphQL.KeyValuePair(key: "lastName", value: lastName))
            userDataNullable = GraphQLNullable<[ApolloGeneratedGraphQL.KeyValuePair]>(arrayLiteral: userData[0], userData[1])
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
                
                UserManager.shared.token = ExpirableAuthorizationToken(token: authorizationToken, expirationDate: expirationDate)
                
                completion(.success(()))
                
            case .failure(let error):
                Logger.apollo.error("LoginOrCreateUser mutation failed with Error: \(error)")
            }
        }
    }
}

// MARK: - ProfileAttributes
struct ProfileAttributes: CustomDebugStringConvertible
{
    
    var id: String
    var email: String
    var firstName: String
    var lastName: String
    var profilePictureURL: String
    
    init(id: String, email: String, firstName: String, lastName: String, profilePictureURL: String = "") {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.profilePictureURL = profilePictureURL
    }
    
    init() {
        self.id = ""
        self.email = ""
        self.firstName = ""
        self.lastName = ""
        self.profilePictureURL = ""
    }
    
    var debugDescription: String {
       """
       id: \(self.id)
       firstName: \(self.firstName)
       lastName: \(self.lastName)
       email: \(self.email)
       profilePictureURL: \(String(describing: self.profilePictureURL))
       """
    }
}
