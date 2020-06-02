//
//  User.swift
//  TCAGithubSearch
//
//  Created by Kang Min Ahn on 2020/05/18.
//  Copyright © 2020 kangmin. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct SearchUserResponse: Decodable {
    let items: [User]
}

struct User: Equatable, Decodable {
    let id: Int
    let name: String
    let avatarUrlString: String?
    let repoCount: Int?

    var avatarUrl: URL? {
        guard let avatarUrlString = avatarUrlString else { return nil }
        return URL(string: avatarUrlString)
    }
}

struct GithubClient {
    var searchUsers: (String) -> Effect<([User], URL?), Failure>
    var getNextUsers: (URL) -> Effect<([User], URL?), Failure>
    var getUser: (String) -> Effect<User, Failure>

    struct Failure: Error, Equatable {}
}

extension GithubClient {
    static var live = GithubClient(
        searchUsers: { query in
            guard var components = URLComponents(string: "https://api.github.com/search/users") else  {
                return Effect.init(error: Failure())
            }
            components.queryItems = [URLQueryItem(name: "q", value: query)]

            let publisher = URLSession.shared.dataTaskPublisher(for: components.url!)
                .share()

            let getNextURL = publisher
                .map { _, response in
                    fetchNextURL(from: response)
                }
                .mapError { _ in Failure() }

            let getUsers = publisher
                .map { data, _ in data }
                .decode(type: SearchUserResponse.self, decoder: JSONDecoder())
                .map(\.items)
                .mapError { _ in Failure() }

            return getUsers.zip(getNextURL)
                .eraseToEffect()
        },
        getNextUsers: { url in
            let publisher = URLSession.shared.dataTaskPublisher(for: url)
                            .share()

            let getNextURL = publisher
                .map { _, response in
                    fetchNextURL(from: response)
                }
                .mapError { _ in Failure() }

            let getUsers = publisher
                .map { data, _ in data }
                .decode(type: SearchUserResponse.self, decoder: JSONDecoder())
                .map(\.items)
                .mapError { _ in Failure() }

            return getUsers.zip(getNextURL)
                .eraseToEffect()
        },
        getUser: { userName in
            guard let components = URLComponents(string: "https://api.github.com/users/\(userName)"), let url = components.url else {
                return Effect.init(error: Failure())
            }

            return URLSession.shared.dataTaskPublisher(for: url)
                .map { data, _ in data }
                .decode(type: User.self, decoder: JSONDecoder())
                .mapError { _ in Failure() }
                .eraseToEffect()
        }
    )

    static func fetchNextURL(from response: URLResponse) -> URL? {
        guard let response = response as? HTTPURLResponse,
            let value = response.value(forHTTPHeaderField: "Link") else { return nil }
        let links = value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        if let nextURLString = links.filter({ $0.contains("rel=\"next") }).first?.slice(from: "<", to: ">") {
            return URL(string: nextURLString)
        }
        return nil
    }
}

extension User {
    private enum CodingKeys: String, CodingKey {
        case id
        case name = "login"
        case avatarUrlString = "avatar_url"
        case repoCount = "public_repos"
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

