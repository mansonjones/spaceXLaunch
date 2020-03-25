#  spaceXLaunches
This app performs searches against the spaceX graphQL server
https://api.spacex.land/graphql/

The only external dependency is to the Apollo library, which is the standard 
swift library for graphql.

The dependency on graphQL is created using the Swift Package Manager.

The Apollo code is based on the introductory iOS tutorial:

https://www.apollographql.com/docs/ios/tutorial/tutorial-introduction/
The process of downloading the schema and the query is described in
the tutorial.  Note that if the spaceX graphQL schema changes that you
will need to download a new schema.

This app was created in Xcode 11.3.1 with Swift 5.

In it's current state, the default selection is for the past launch
(mission name = Starlink 5, rocket name = Falcon 9, launch date = 2020)

By changing the mission picker to SXM-7, the launch data for an upcoming launch
is added:
(mission name = SXM-7, rocket name = Falcon 9, launch date = 2020)

Future Work & improvements.
1) Use RxSwift to create a search interface where partial match textfields could be used to filter the table.
2) Move the network code out of the ViewController by adding a function to LaunchModel.swift.  This is pretty basic, the network code is part of the model in MVC.
3) Add unit tests.
4) Add a detail view for each launch.
5) Add a video player for the youtube videos.
6) Research to see if graphQL offers any useful options for filtering results.

