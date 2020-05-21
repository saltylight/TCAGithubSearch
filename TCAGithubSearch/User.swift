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
    let repoCount: Int? = nil

    var avatarUrl: URL? {
        guard let avatarUrlString = avatarUrlString else { return nil }
        return URL(string: avatarUrlString)
    }
}

struct GithubClient {
    var searchUsers: (String) -> Effect<[User], Failure>

    struct Failure: Error, Equatable {}
}

extension GithubClient {
    static var live = GithubClient(
        searchUsers: { query in
            var components = URLComponents(string: "https://api.github.com/search/users")!
            components.queryItems = [URLQueryItem(name: "q", value: query)]

            return URLSession.shared.dataTaskPublisher(for: components.url!)
                .map { data, _ in data }
                .decode(type: SearchUserResponse.self, decoder: JSONDecoder())
                .map(\.items)
                .mapError { error in
                    print(error)
                    return Failure()
            }
            .eraseToEffect()
    }
    )
}

extension User {
    private enum CodingKeys: String, CodingKey {
        case id
        case name = "login"
        case avatarUrlString = "avatar_url"
    }
}
