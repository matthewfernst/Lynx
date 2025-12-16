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
    defer {
      chain.proceedAsync(
        request: request,
        response: response,
        completion: completion
      )
    }

    guard response != nil else {
      Logger.apollo.info("← GraphQL Error: \(Operation.operationName)")
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
