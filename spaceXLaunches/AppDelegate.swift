//
//  AppDelegate.swift
//  spaceXLaunches
//
//  Created by Manson Jones on 3/20/20.
//  Copyright © 2020 Manson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // This is use for testing.  Please delete once the app is working
        Network.shared.apollo.fetch(query: LaunchListQuery()) { result in
            switch result {
            case .success(let graphQLResult):
                
                // var launches = [LaunchListQuery.Data]()
                print("Success! Result: \(graphQLResult)")
                 /*
                if let launches = graphQLResult.data.flatMap( { $0 }) {
                    let launch1 = launches.launchesUpcoming
                    print("FlatMap Start ")
                print("\(debug)")
                    print("FlatMap End")
                }
                */
                if let launchesPast = graphQLResult.data?.launchesPast {
                    for launchPast in launchesPast {
                        if let missionName = launchPast?.missionName,
                            let rocketName = launchPast?.rocket?.rocketName,
                            let launchDate = launchPast?.launchDateUtc,
                            let videoLink = launchPast?.links?.videoLink
                        {
                            print("Past Launch")
                            print(missionName)
                            print(rocketName)
                            print(launchDate)
                            print(videoLink)
                            print("\n")
                        }
                    }
                }
                // Note that there's no video link for the upcoming launches
                if let launchesUpcoming = graphQLResult.data?.launchesUpcoming {
                    for launchUpcoming in launchesUpcoming {
                        if let missionName = launchUpcoming?.missionName,
                            let rocketName = launchUpcoming?.rocket?.rocketName,
                            let launchDate = launchUpcoming?.launchDateUtc
                        {
                            print("Upcoming Launch")
                            print(missionName)
                            print(rocketName)
                            print(launchDate)
                            print("\n")
                        }
                    }
                }
               // print("Success! Result: \(graphQLResult)")
            
          case .failure(let error):
            print("Failure! Error: \(error)")
          }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

