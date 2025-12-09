import Apollo
import OSLog

final class ResponseLoggingInterceptor: ApolloInterceptor {
    
    enum ResponseLoggingError: Error {
        case notYetReceived
    }
    
    func interceptAsync<Operation: GraphQLOperation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
        Logger.apollo.info("→ GraphQL Request: \(Operation.operationName)")

        defer {
            chain.proceedAsync(
                request: request,
                response: response,
                completion: completion
            )
        }

        guard let _ = response else {
            chain.handleErrorAsync(
                ResponseLoggingError.notYetReceived,
                request: request,
                response: response,
                completion: completion
            )
            return
        }
    }
}
