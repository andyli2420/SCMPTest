//
//  APIController.swift
//  SCMPTest
//
//  Created by Andy Li on 23/10/2023.
//
import Foundation

private let baseUrl = "https://reqres.in/api"

func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
    
    let endpoint = "/login?delay=5"

    let apiUrl = URL(string: baseUrl + endpoint)!
    
    var request = URLRequest(url: apiUrl)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let requestBody: [String: Any] = [
        "email": email,
        "password": password
    ]

    do {
        // Convert the request body to JSON data
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        

        // Set the request body
        request.httpBody = jsonData
        
        print("Json", jsonData)


        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            if let error = error {
                print("error", error)
                completion(.failure(error))
                return
            }

            // Check the response status code
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    // Successful response
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            if let jsonDict = json as? [String: Any], let token = jsonDict["token"] as? String {
                                completion(.success(token))
                            } else {
                                let error = NSError(domain: "InvalidResponse", code: -1, userInfo: nil)
                                completion(.failure(error))
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    }
                } else {
                    // Error response
                    print("HTTP Error: \(httpResponse.statusCode)")
                    let error = NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)
                                    completion(.failure(error))

                }
            }
        }

        
        task.resume()
    } catch {
        print("Error: \(error)")
    }
}


struct UserListResponse: Codable {
    let page: Int
    let perPage: Int
    let total: Int
    let totalPages: Int
    let data: [User]
    let support: Support

}

struct Support: Codable {
    let url: URL
    let text: String
}

struct User: Codable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let avatar: URL
    
}

enum GetUserError: Error {
    case invalidURL
    case decodingError
}


func getUsers(page: Int = 1) async throws -> UserListResponse {
    let urlString = "https://reqres.in/api/users?page=\(String(page))"
    guard let url = URL(string: urlString) else {
        throw GetUserError.invalidURL
    }
    
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(UserListResponse.self, from: data)
        
        
    } catch {
        throw GetUserError.decodingError
    }
}

