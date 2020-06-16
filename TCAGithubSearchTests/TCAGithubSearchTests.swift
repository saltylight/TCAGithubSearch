//
//  TCAGithubSearchTests.swift
//  TCAGithubSearchTests
//
//  Created by Kang Min Ahn on 2020/05/15.
//  Copyright © 2020 kangmin. All rights reserved.
//

import XCTest
import ComposableArchitecture
@testable import TCAGithubSearch

class TCAGithubSearchTests: XCTestCase {
//    let scheduler = DispatchQueue.testScheduler
//
//    lazy var environment = SearchEnvironment(
//        githubClient: .unimplemented,
//        mainQueue: AnyScheduler(self.scheduler)
//    )
//
//    func testSearchAndClearQuery() {
//        let store = TestStore(
//            initialState: .init(),
//            reducer: searchReducer,
//            environment: self.environment
//        )
//    }
}

private let mockUsers = [
    User(id: 1, name: "ABC", avatarUrlString: nil, repoCount: 1),
    User(id: 2, name: "BCD", avatarUrlString: nil, repoCount: 22),
    User(id: 3, name: "CDE", avatarUrlString: nil, repoCount: 333)
]
