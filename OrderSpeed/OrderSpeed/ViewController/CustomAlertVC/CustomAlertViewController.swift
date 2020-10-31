//
//  CustomAlertViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/4/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

enum AlertShowType: Int {
    case showSuccess = 1
    case showContent = 2
}

class CustomAlertViewController: MainViewController {
    
    var typeShow: AlertShowType = .showContent {
        didSet {
            updateTypeShow()
        }
    }
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var viewSuccess: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var lblTitleSuccess: UILabel!
    @IBOutlet weak var lblSubTitleSuccess: UILabel!
    @IBOutlet weak var lblContentSuccess: UILabel!
    
    @IBOutlet weak var lblTitleContent: UILabel!
    @IBOutlet weak var lblContentContent: UILabel!
    
    var sOrderCode = ""
    var titleContent = ""
    var msgContent = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewSuccess.isHidden = true
        viewContent.isHidden = true
    }
    
    func updateTypeShow() {
        print("\(TAG) - \(#function) - \(#line) - typeShow : \(typeShow.rawValue)")
        if typeShow == .showContent {
            viewContent.isHidden = false
            lblTitleContent.text = titleContent
            lblContentContent.text = msgContent
        } else {
            viewSuccess.isHidden = false
            lblContentContent.text = "Chúng tôi sẽ liên hệ với bạn sớm nhất."
            lblSubTitleSuccess.text = sOrderCode
        }
    }
    
    @IBAction func eventChooseClose(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_DISMISS_ALERT_CUSTOM"), object: nil)
            }
        }
    }
    
}
