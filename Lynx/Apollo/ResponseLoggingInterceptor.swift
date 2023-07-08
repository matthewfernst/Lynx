//
//  ResponseLoggingInterceptor.swift
//  Lynx
//
//  Created by Matthew Ernst on 4/30/23.
//

import Apollo
import OSLog

class ResponseLoggingInterceptor: ApolloInterceptor {
    
    enum ResponseLoggingError: Error {
        case notYetReceived
    }
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        defer {
            // Even if we can't log, we still want to keep going.
            chain.proceedAsync(
                request: request,
                response: response,
                completion: completion
            )
        }
        
        guard let receivedResponse = response else {
            chain.handleErrorAsync(
                ResponseLoggingError.notYetReceived,
                request: request,
                response: response,
                completion: completion
            )
            return
        }
        
        Logger.apollo.log("HTTP Response: \(receivedResponse.httpResponse.debugDescription)")
        if let stringData = String(bytes: receivedResponse.rawData, encoding: .utf8) {
            Logger.apollo.log("Data: \(stringData)")
        } else {
            Logger.apollo.error("Could not convert data to string!")
        }
    }
}
