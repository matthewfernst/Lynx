//
//  RequestLoggingInterceptor.swift
//  Lynx
//
//  Created by Matthew Ernst on 4/30/23.
//

import Apollo
import OSLog

class RequestLoggingInterceptor: ApolloInterceptor {
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        
        Logger.apollo.log("Outgoing request: \(request.debugDescription)")
        chain.proceedAsync(
            request: request,
            response: response,
            completion: completion
        )
    }
}
