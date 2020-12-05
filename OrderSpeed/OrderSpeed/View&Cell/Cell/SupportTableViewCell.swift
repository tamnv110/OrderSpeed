//
//  SupportTableViewCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/4/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class SupportTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var btnPhone: UIButton!
    @IBOutlet weak var btnMessenger: UIButton!
    
    var phonenumber = ""
    var messenger = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func showInfo(_ item: SupportModel) {
        lblTitle.text = item.name
        lblPhone.text = item.phone
        phonenumber = item.phone
        messenger = item.account
    }
    
    @IBAction func eventChooseMakePhoneCall(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_MAKE_PHONE_CALL"), object: phonenumber, userInfo: nil)
    }
    
    @IBAction func eventChooseMakeMessenger(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_MAKE_MESSENGER"), object: messenger, userInfo: nil)
    }
    
    @IBAction func eventChooseMakeZalo(_ sender: Any) {
        guard let zaloURL = URL(string: "http://zalo.me/\(phonenumber)") else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(zaloURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(zaloURL)
        }
    }
    
}
