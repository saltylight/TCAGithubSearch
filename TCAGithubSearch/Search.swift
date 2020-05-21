//
//  Search.swift
//  TCAGithubSearch
//
//  Created by Kang Min Ahn on 2020/05/15.
//  Copyright © 2020 kangmin. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct SearchState: Equatable {
    var searchQuery = ""
    var users: [User] = []
}

enum SearchAction: Equatable {
    case searchQueryChanged(String)
    case usersResponse(Result<[User], GithubClient.Failure>)
}

struct SearchEnvironment {
    var githubClient: GithubClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let searchReducer = Reducer<SearchState, SearchAction, SearchEnvironment> { state, action, environment in
    switch action {
    case let .searchQueryChanged(query):
        struct SearchUserId: Hashable {}
        state.searchQuery = query

        guard !query.isEmpty else {
          state.users = []
          return .cancel(id: SearchUserId())
        }

        return environment.githubClient
            .searchUsers(query)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .debounce(id: SearchUserId(), for: 0.3, scheduler: environment.mainQueue)
            .map(SearchAction.usersResponse)

    case let .usersResponse(.success(users)):
        state.users = users
        return .none
    case let .usersResponse(.failure(error)):
        return .none
    }
}

extension User {
    var repoCountTitle: String {
        guard let repoCount = repoCount else {
            return "Repo Count Loading..."
        }
        return "Repo Count: \(repoCount)"
    }
}
