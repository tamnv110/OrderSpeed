//
//  CustomAlertViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/4/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

enum AlertShowType: Int {
    case showSuccess
    case showContent
}

class CustomAlertViewController: MainViewController {
    
    var typeShow: AlertShowType = .showContent
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var viewSuccess: UIView!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var lblTitleSuccess: UILabel!
    @IBOutlet weak var lblSubTitleSuccess: UILabel!
    @IBOutlet weak var lblContentSuccess: UILabel!
    
    @IBOutlet weak var lblTitleContent: UILabel!
    @IBOutlet weak var lblContentContent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func eventChooseClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
