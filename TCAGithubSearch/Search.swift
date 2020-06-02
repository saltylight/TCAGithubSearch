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
    var nextUrl: URL?
}

enum SearchAction {
    case searchQueryChanged(String)
    case getNextUsers
    case usersResponse(Result<([User], URL?), GithubClient.Failure>)
    case updateUser(Result<User, GithubClient.Failure>, _ index: Int)
    case appendUsers(Result<([User], URL?), GithubClient.Failure>)
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

    case .getNextUsers:
        guard let nextUrl = state.nextUrl else {
            return .none
        }

        return environment.githubClient
            .getNextUsers(nextUrl)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .debounce(id: SearchUserId(), for: 0.3, scheduler: environment.mainQueue)
            .map(SearchAction.appendUsers)
            .cancellable(id: SearchUserId(), cancelInFlight: true)


    case let .usersResponse(.success((users, nextUrl))):
        struct UsersRepoCountId: Hashable {}

        state.users = users
        state.nextUrl = nextUrl

        return Effect.merge(users.enumerated().map { index, user in
            environment.githubClient
                .getUser(user.name)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { SearchAction.updateUser($0, index) }
            })
//            .cancellable(id: UsersRepoCountId(), cancelInFlight: true)

    case let .usersResponse(.failure(error)):
        return .none

    case let .updateUser(.success(user), index):
        state.users[index] = user

        return .none

    case let .updateUser(.failure(error), _):
        return .none

    case let .appendUsers(.success((users, nextUrl))):
        state.users.append(contentsOf: users)
        state.nextUrl = nextUrl

        return Effect.merge(users.enumerated().map { index, user in
            environment.githubClient
                .getUser(user.name)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { SearchAction.updateUser($0, index) }
            })
//            .cancellable(id: UsersRepoCountId(), cancelInFlight: true)
    case let .appendUsers(.failure(error)):
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
