import Foundation
import Combine
import Security

final class KeychainClient {
    enum KeychainError: Error {
        case itemNotFound
        case duplicateItem
        case unexpectedStatus(OSStatus)
    }

    private let service: String

    init(service: String) {
        self.service = service
    }

    func saveToken(_ token: String) throws -> AnyPublisher<(), KeychainError> {
        Deferred { [service] in
            Future { promise in
                let data = token.data(using: .utf8)
                let query: [String: AnyObject] = [
                    kSecAttrService as String: service as AnyObject,
                    kSecClass as String: kSecClassGenericPassword as AnyObject,
                    kSecValueData as String: data as AnyObject
                ]

                let status = SecItemAdd(query as CFDictionary, nil)

                guard status == errSecSuccess else {
                    if status == errSecDuplicateItem {
                        return promise(.failure(.duplicateItem))
                    }

                    return promise(.failure(.unexpectedStatus(status)))
                }

                return promise(.success(()))
            }}
            .eraseToAnyPublisher()
    }

    func fetchToken() -> AnyPublisher<String, KeychainError> {
        Deferred { [service] in
            Future { promise in
                let query: [String: AnyObject] = [
                    kSecAttrService as String: service as AnyObject,
                    kSecClass as String: kSecClassGenericPassword,
                    kSecMatchLimit as String: kSecMatchLimitOne,
                    kSecReturnData as String: kCFBooleanTrue
                ]

                var itemCopy: AnyObject?
                let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)

                guard status == errSecSuccess else {
                    if status == errSecItemNotFound {
                        return promise(.failure(.itemNotFound))
                    }

                    return promise(.failure(.unexpectedStatus(status)))
                }

                let token = String(data: itemCopy as! Data, encoding: .utf8)!

                return promise(.success(token))
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteToken() -> AnyPublisher<(), KeychainError> {
        Deferred { [service] in
            Future { promise in
                let query: [String: AnyObject] = [
                    kSecAttrService as String: service as AnyObject,
                    kSecClass as String: kSecClassGenericPassword
                ]

                let status = SecItemDelete(query as CFDictionary)

                guard status == errSecSuccess else {
                    return promise(.failure(KeychainError.unexpectedStatus(status)))
                }

                return promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}
