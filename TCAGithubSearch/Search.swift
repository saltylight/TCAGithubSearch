//
//  Search.swift
//  TCAGithubSearch
//
//  Created by Kang Min Ahn on 2020/05/15.
//  Copyright © 2020 kangmin. All rights reserved.
//

import ComposableArchitecture

struct SearchState: Equatable {
    var searchQuery = ""
    var users: [User] = [.init(name: "User 1"), .init(name: "User 2")]
}

enum SearchAction: Equatable {
    case searchQueryChanged(String)
}

struct SearchEnvironment {

}

let searchReducer = Reducer<SearchState, SearchAction, SearchEnvironment> { state, action, environment in
    switch action {
    case let .searchQueryChanged(query):
        state.searchQuery = query
        return .none
    }
}
