//
//  Search.swift
//  TCAGithubSearch
//
//  Created by Kang Min Ahn on 2020/05/15.
//  Copyright © 2020 kangmin. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import Combine

struct SearchState: Equatable {
    var searchQuery = ""
    var users: [User] = []
}

enum SearchAction: Equatable {
    case searchQueryChanged(String)
    case usersResponse(Result<[User], GithubClient.Failure>)
    case updateUser(Result<User, GithubClient.Failure>, _ index: Int)
}

struct SearchEnvironment {
    var githubClient: GithubClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let searchReducer = Reducer<SearchState, SearchAction, SearchEnvironment> { state, action, environment in
    struct SearchUserId: Hashable {}

    switch action {
    case let .searchQueryChanged(query):
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
            .cancellable(id: SearchUserId(), cancelInFlight: true)

    case let .usersResponse(.success(users)):

        state.users = users

        return Effect.merge(users.enumerated().map { index, user in
            environment.githubClient
                .getUser(user.name)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { SearchAction.updateUser($0, index) }
            })
            .cancellable(id: SearchUserId(), cancelInFlight: true)

    case let .usersResponse(.failure(error)):
        return .none

    case let .updateUser(.success(user), index):
        state.users[index] = user

        return .none

    case let .updateUser(.failure(error), _):
        return .none
    }
}

extension User {
    var repoCountTitle: String {
        guard let repoCount = repoCount else {
            return "Repo Count: ..."
        }
        return "Repo Count: \(repoCount)"
    }
}
