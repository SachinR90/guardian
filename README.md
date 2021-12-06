# guardian
The Guardian News App for educational pupose
***
This app is built using the following techinical implementations:
 - MVVM-C architectural pattern
     - Built using [XCoordinator](https://github.com/quickbirdstudios/XCoordinator) as base
 - Dependency Injection using Protocol Composition
 - Offline first feature using [GRDB](https://github.com/groue/GRDB.swift) as local database
 - follows this successful [Git Branching Strategy](https://nvie.com/posts/a-successful-git-branching-model/) closely

The App has following features:
 - Display News list by fetching from The Guardian Api
 - handle internet connectivity
 - persist news data for offline use
 - display news details for selected news item from the news list
 - allow user to open the news url in safari
 
The following features are work in progress:
 - Secure GRDB using SQLCipher
 - Periodic Background app Refresh
