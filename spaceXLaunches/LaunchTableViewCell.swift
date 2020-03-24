//
//  LaunchTableViewCell.swift
//  spaceXLaunches
//
//  Created by Manson Jones on 3/23/20.
//  Copyright © 2020 Manson. All rights reserved.
//

import UIKit

class LaunchTableViewCell: UITableViewCell {

    @IBOutlet weak var missionName: UILabel!
    @IBOutlet weak var rocketName: UILabel!
    @IBOutlet weak var launchYear: UILabel!
    @IBOutlet weak var videoLink: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
