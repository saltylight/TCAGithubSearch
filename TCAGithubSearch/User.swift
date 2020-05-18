//
//  User.swift
//  TCAGithubSearch
//
//  Created by Kang Min Ahn on 2020/05/18.
//  Copyright © 2020 kangmin. All rights reserved.
//

import Foundation

struct User: Equatable, Identifiable {
    let id = UUID()
    let name: String
}
