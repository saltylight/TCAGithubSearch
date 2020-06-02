//
//  ContentView.swift
//  TCAGithubSearch
//
//  Created by Kang Min Ahn on 2020/05/15.
//  Copyright © 2020 kangmin. All rights reserved.
//

import ComposableArchitecture
import SwiftUI
import KingfisherSwiftUI

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
                        ForEach(viewStore.users, id: \.id) { user in
                            HStack {
                                KFImage(user.avatarUrl)
                                    .placeholder {
                                        Image(systemName: "arrow.2.circlepath.circle")
                                            .font(.largeTitle)
                                            .opacity(0.3)
                                    }
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                VStack(alignment: .leading) {
                                    Text(user.name)
                                    Text(user.repoCountTitle)
                                }
                            }
                            .onAppear {
                                if user == viewStore.users.last {
                                    viewStore.send(SearchAction.getNextUsers)
                                }
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
            environment: SearchEnvironment(
                githubClient: GithubClient.live,
                mainQueue: DispatchQueue.main.eraseToAnyScheduler()
            )
        )

        return Group {
            SearchView(store: store)

            SearchView(store: store)
                .environment(\.colorScheme, .dark)
        }
    }
}
