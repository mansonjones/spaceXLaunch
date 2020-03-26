//
//  ViewController.swift
//  spaceXLaunches
//
//  Created by Manson Jones on 3/20/20.
//  Copyright © 2020 Manson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var pastLaunches = [LaunchListQuery.Data.LaunchesPast]()
    var upcomingLaunches = [LaunchListQuery.Data.LaunchesUpcoming]()
        
    @IBOutlet weak var missionPicker: UIPickerView!
    @IBOutlet weak var rocketPicker: UIPickerView!
    @IBOutlet weak var launchYearPicker: UIPickerView!
    
    var missionPickerList = [String]()
    var rocketPickerList = [String]()
    var launchYearPickerList = [String]()
    
    let missionPickerDefault = 0
    let rocketPickerDefault = 0
    let selectedYearDefault = 0

    override func viewDidLoad() {
        super.viewDidLoad()
                
       self.loadPickerLists()

        
    
        self.loadLaunches(missionName: "Starlink 5", rocketName: "Falcon 9", launchYear: "2020")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.missionPicker.delegate = self
        self.missionPicker.dataSource = self
        
        self.rocketPicker.delegate = self
        self.rocketPicker.dataSource = self
        
        self.launchYearPicker.delegate = self
        self.launchYearPicker.dataSource = self
        
        missionPicker.selectRow(missionPickerDefault, inComponent: 0, animated: true)
        rocketPicker.selectRow(rocketPickerDefault, inComponent: 0, animated: true)
        launchYearPicker.selectRow(selectedYearDefault, inComponent: 0, animated: true)
    }
    
    private func loadPickerLists() {
        Network.shared.apollo
            .fetch(query: LaunchListQuery()) { [weak self] result in
                
                guard let self = self else {
                    return
                }
                
                defer {
                    self.missionPickerList.sort()
                    self.rocketPickerList.sort()
                    self.launchYearPickerList.sort()
                    
                    self.missionPicker.reloadAllComponents()
                    self.rocketPicker.reloadAllComponents()
                    self.launchYearPicker.reloadAllComponents()
                }
                
                switch result {
                case .success(let graphQLResult):
                    
                    if let launchConnection = graphQLResult.data {
                        if let launchesPast = launchConnection.launchesPast {
                            for launch in launchesPast {
                                if let missionName = launch?.missionName {
                                    if self.missionPickerList.contains(missionName) == false {
                                        self.missionPickerList.append(missionName)
                                    }
                                }
                                if let rocketName = launch?.rocket?.rocketName {
                                    if self.rocketPickerList.contains(rocketName) == false {
                                        self.rocketPickerList.append(rocketName)
                                    }
                                }
                                if let launchDateUtc = launch?.launchDateUtc {
                                    let launchYear = self.getYearFrom(utc: launchDateUtc)
                                    if self.launchYearPickerList.contains(launchYear) == false {
                                        self.launchYearPickerList.append(launchYear)
                                    }
                                }
                            }
                        }
                            
                        if let launchesUpcoming = launchConnection.launchesUpcoming {
                            for launch in launchesUpcoming {
                                if let missionName = launch?.missionName {
                                    if self.missionPickerList.contains(missionName) == false {
                                        self.missionPickerList.append(missionName)
                                    }
                                }
                                if let rocketName = launch?.rocket?.rocketName {
                                    if self.rocketPickerList.contains(rocketName) {
                                        self.rocketPickerList.append(rocketName)
                                    }
                                }
                                if let launchDateUtc = launch?.launchDateUtc {
                                    let launchYear = self.getYearFrom(utc: launchDateUtc)
                                    if self.launchYearPickerList.contains(launchYear) == false {
                                        self.launchYearPickerList.append(launchYear)
                                    }
                                }
                            }
                            
                        }
                    }
                    self.tableView.reloadData()
                    if let errors = graphQLResult.errors {
                        let message = errors
                            .map { $0.localizedDescription }
                            .joined(separator: "\n")
                        print("GraphQL Error(s) \(message)")
                    }
                case .failure(let error):
                    print("network error \(error) ")
                }
        }
    }

    private func loadLaunches(missionName: String, rocketName: String, launchYear: String) {
        
        Network.shared.apollo
            .fetch(query: LaunchListQuery()) { [weak self] result in
                
                guard let self = self else {
                    return
                }
                
                defer {
                    self.tableView.reloadData()
                }
                
                switch result {
                case .success(let graphQLResult):
                    
                    if let launchConnection = graphQLResult.data {
                        if let launchesPast = launchConnection.launchesPast {

                            self.pastLaunches
                                .append(contentsOf: launchesPast.compactMap { $0 }
                                    .filter {
                                        self.filterPastLaunches(launchData: $0,
                                                                missionName: missionName,
                                                                rocketName: rocketName,
                                                                launchYear: launchYear)
                                })
                            
                        }
                        if let launchesUpcoming = launchConnection.launchesUpcoming {
                            self.upcomingLaunches
                                .append(contentsOf: launchesUpcoming.compactMap { $0 }
                                    .filter {
                                        
                                        self.filterUpcomingLaunches(launchData: $0,
                                                                    missionName: missionName,
                                                                    rocketName: rocketName,
                                                                    launchYear: launchYear)
                                })
                        }
                    }
                    
                    if let errors = graphQLResult.errors {
                        let message = errors
                            .map { $0.localizedDescription }
                            .joined(separator: "\n")
                        print("GraphQL Error(s) \(message)")
                    }
                case .failure(let error):
                    print("network error \(error) ")
                }
        }
    }
    
    private func filterPastLaunches( launchData : LaunchListQuery.Data.LaunchesPast?,
                                     missionName: String,
                                     rocketName: String,
                                     launchYear: String) -> Bool {
        if let launchData = launchData, let launchDateUtc = launchData.launchDateUtc {
            if launchData.missionName == missionName &&
                launchData.rocket?.rocketName == rocketName &&
                compareUtc(utc: launchDateUtc, year: launchYear) {
                return true
            }
        }
        return false
    }
    
    private func filterUpcomingLaunches( launchData: LaunchListQuery.Data.LaunchesUpcoming?,
                                         missionName: String,
                                         rocketName: String,
                                         launchYear: String) -> Bool {
        if let launchData = launchData, let launchDateUtc = launchData.launchDateUtc {
            if launchData.missionName == missionName &&
                launchData.rocket?.rocketName == rocketName &&
                compareUtc(utc: launchDateUtc, year: launchYear) {
                return true
            }
        }
        return false
    }
    
    private func compareUtc(utc date: String, year: String) -> Bool {
        return String(date.prefix(4)) == year
    }

    private func getYearFrom(utc date: String) -> String {
        return String(date.prefix(4))
    }
}


// MARK: TableView Delegate and DataSource functions
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return pastLaunches.count
        case 1:
            return upcomingLaunches.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "LaunchTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? LaunchTableViewCell else {
            fatalError("The dequeued cell is not an instance of LaunchTableViewCell")
        }
        
        if pastLaunches.isEmpty {
            return cell 
        }
        
        switch indexPath.section {
        case 0:
            if let missionName = self.pastLaunches[indexPath.row].missionName
            {
                cell.missionName.text = missionName
            }
            if let rocketName = self.pastLaunches[indexPath.row].rocket?.rocketName {
                cell.rocketName.text = rocketName
            }
            if let launchYear = self.pastLaunches[indexPath.row].launchDateUtc {
                cell.launchYear.text = launchYear
            }
            if let videoLink = self.pastLaunches[indexPath.row].links?.videoLink {
                cell.videoLink.text = videoLink
            }
            return cell
        case 1:
            if let missionName = self.upcomingLaunches[indexPath.row].missionName {
                cell.missionName.text = missionName
            }
            if let rocketName = self.upcomingLaunches[indexPath.row].rocket?.rocketName {
                cell.rocketName.text = rocketName
            }
            if let launchYear = self.upcomingLaunches[indexPath.row].launchDateUtc {
                cell.launchYear.text = launchYear
            }
            if let videoLink = self.upcomingLaunches[indexPath.row].links?.videoLink {
                cell.videoLink.text = videoLink
            } else {
                cell.videoLink.text = "video not available"
            }
            return cell
        default:
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Past Launches"
        case 1:
            return "Upcoming Launches"
        default:
            return "Unknown"
        }
    }

}

// MARK: PickerView Functions
extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        switch pickerView {
        case missionPicker:
            return 1
        case rocketPicker:
            return 1
        case launchYearPicker:
            return 1
        default:
            return 1
        }
    }
       
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
        case missionPicker:
            return self.missionPickerList.count
        case rocketPicker:
            return rocketPickerList.count
        case launchYearPicker:
            return launchYearPickerList.count
        default:
            return 1
        }
      }
       
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case missionPicker:
            return missionPickerList[row]
        case rocketPicker:
            return rocketPickerList[row]
        case launchYearPicker:
            return launchYearPickerList[row]
        default:
            return "Error"
        }
    }
       
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        let selectedMission = missionPickerList[missionPicker.selectedRow(inComponent: 0)]
        let selectedRocket = rocketPickerList[rocketPicker.selectedRow(inComponent: 0)]
        let selectedYear = launchYearPickerList[launchYearPicker.selectedRow(inComponent: 0)]
        
        loadLaunches(missionName: selectedMission, rocketName: selectedRocket, launchYear: selectedYear)

    }

    
}


