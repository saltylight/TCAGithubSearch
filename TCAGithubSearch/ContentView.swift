//
//  ContentView.swift
//  TCAGithubSearch
//
//  Created by Kang Min Ahn on 2020/05/15.
//  Copyright © 2020 kangmin. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct SearchView: View {
    let store: Store<SearchState, SearchAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField(
                            "github user",
                            text: viewStore.binding(
                                get: \.searchQuery,
                                send: SearchAction.searchQueryChanged
                            )
                        )
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    }
                    .padding([.leading, .trailing], 16)

                    List {
                        ForEach(viewStore.users) { user in
                            HStack {
                                Text(user.name)
                            }
                        }
                    }
                }
                .navigationBarTitle("GithubSearch")
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(
          initialState: SearchState(),
          reducer: searchReducer,
          environment: SearchEnvironment()
        )

        return Group {
          SearchView(store: store)

          SearchView(store: store)
            .environment(\.colorScheme, .dark)
        }
    }
}
