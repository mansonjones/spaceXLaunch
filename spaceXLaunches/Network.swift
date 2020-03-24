//
//  Network.swift
//  spaceXLaunches
//
//  Created by Manson Jones on 3/20/20.
//  Copyright © 2020 Manson. All rights reserved.
//

import Foundation
import Apollo

class Network {
  static let shared = Network()
    
  private(set) lazy var apollo =
    ApolloClient(url: URL(string: "https://api.spacex.land/graphql/")!)
}
