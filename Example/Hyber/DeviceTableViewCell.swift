//
//  DeviceTableViewCell.swift
//  Hyber
//
//  Created by Taras on 12/12/16.
//  Copyright © 2016 Incuube. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {
    @IBOutlet weak var DeviceName: UILabel!
    @IBOutlet weak var deviceTypeImage: UIImageView!
    @IBOutlet weak var osTypeImage: UIImageView!
    @IBOutlet weak var deviceId: UILabel!
    @IBOutlet weak var osVersion: UILabel!
    @IBOutlet weak var currentDevice: UILabel!
    @IBOutlet weak var updateDevice: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
