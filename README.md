
# GithubSearch

This application demonstrates how to build a moderately complex search feature in The Composable Architecture(TCA):

* Typing into the search field executes an API request to search for users.
* Since github v3 `Search` api doesn't provide user's repoCount, additional API request is necessary for each of the searched users. This has been developed by using `Effect.merge`.

In addition to those basic features, the following extra things are implemented:

* Search API requests are debounced so that one is run only after the user stops typing for 300ms.
* If you search another user while `Search` or `User` API request is already in-flight, it will cancel these requests and start a new one. 
* Dependencies and side effects are fully controlled. The reducer that runs this application needs a [github API client](TCAGithubSearch/User.swift) and a scheduler to run effects.
