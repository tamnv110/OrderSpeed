//
//  MainViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/3/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class MainViewController: UIViewController {
    
    var TAG = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var progessHUD: NVTProgressHUD = {
        return NVTProgressHUD()
    }()
    
    var dbFireStore:Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TAG = className
        dbFireStore = Firestore.firestore()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func hideProgressHUD() {
        DispatchQueue.main.async {
            self.progessHUD.hide()
        }
    }
    
    func showErrorAlertView(_ sThongBao:String) {
        let alert = UIAlertController(title: "Lỗi", message: sThongBao, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Đóng", style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }

}
