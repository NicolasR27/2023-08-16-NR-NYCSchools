
import Foundation

protocol NetworkingManagerImpl {
    func request<T: Decodable>(session: URLSession, _ absoluteURL: String) async throws -> T
}

final class NetworkingManager: NetworkingManagerImpl {
    static let shared = NetworkingManager()

    private init() {}

    func request<T: Decodable>(session: URLSession = .shared, _ absoluteURL: String) async throws -> T {
        guard let url = URL(string: absoluteURL) else { throw NetworkingError.invalidURL }

        let request = URLRequest(url: url)
        let response: (Data, URLResponse)
        do {
            response = try await session.data(for: request)
        } catch {
            throw NetworkingError.custom(error: error)
        }

        let httpResponse = response.1 as! HTTPURLResponse
        guard (200...300) ~= httpResponse.statusCode else {
            throw NetworkingError.invalidStatusCode(statusCode: httpResponse.statusCode)
        }

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            let data = try jsonDecoder.decode(T.self, from: response.0)
            return data
        } catch {
            throw NetworkingError.failedToDecode
        }
    }
}

extension NetworkingManager {
    enum NetworkingError: Error {
        case invalidURL
        case custom(error: Error)
        case invalidStatusCode(statusCode: Int)
        case failedToDecode
    }
}

extension NetworkingManager.NetworkingError: Equatable {
    static func == (lhs: NetworkingManager.NetworkingError, rhs: NetworkingManager.NetworkingError) -> Bool {
        switch (lhs, rhs) {
            case (.invalidURL, .invalidURL):
                return true
            case let (.custom(lhsError), .custom(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case let (.invalidStatusCode(lhsCode), .invalidStatusCode(rhsCode)):
                return lhsCode == rhsCode
            case (.failedToDecode, .failedToDecode):
                return true
            default:
                return false
        }
    }
}
