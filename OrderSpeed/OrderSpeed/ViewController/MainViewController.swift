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
import FirebaseStorage

class MainViewController: UIViewController {
    
    var TAG = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var progessHUD: NVTProgressHUD = {
        return NVTProgressHUD()
    }()
    
    var dbFireStore:Firestore!
    lazy var storageRef: StorageReference = {
        return Storage.storage().reference()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TAG = className
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        dbFireStore = Firestore.firestore()
        if self.appDelegate.user == nil {
            self.appDelegate.user = Tools.getUserInfo()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(eventClickNotification(_:)), name: NSNotification.Name("NOTIFICATION_POST_ORDER_ID"), object: nil)
    }
    
    @objc func eventClickNotification(_ notification: Notification) {
        if let orderID = notification.object as? String {
            DispatchQueue.main.async {
                let vc = StatusOrderViewController(nibName: "StatusOrderViewController", bundle: nil)
                vc.orderID = orderID
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    deinit {
        print("\(TAG) - \(#function) - \(#line) - START")
        NotificationCenter.default.removeObserver(self)
    }
    
    func showProgressHUD(_ message: String) {
        DispatchQueue.main.async {
            self.progessHUD.showInViewWithMessage(self.view, message: message)
        }
    }
    
    func hideProgressHUD() {
        DispatchQueue.main.async {
            self.progessHUD.hide()
        }
    }
    
    func showAlertView(_ sThongBao:String, completion: @escaping () -> ()) {
        let alert = UIAlertController(title: "Thông báo", message: sThongBao, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Đóng", style: .cancel) { (action) in
            completion()
        }
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlertView(_ sThongBao:String, completion: @escaping () -> ()) {
        let alert = UIAlertController(title: "Lỗi", message: sThongBao, preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "Đóng", style: .cancel) { (action) in
            completion()
        }
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }

    func showAlertController(_ typeShow: AlertShowType, message: String, title: String) {
        DispatchQueue.main.async {
            let vc = CustomAlertViewController(nibName: "CustomAlertViewController", bundle: nil)
            vc.modalPresentationStyle = .overFullScreen
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            if typeShow == .showSuccess {
                vc.sOrderCode = message
                vc.btnClose.setTitle("Tôi sẽ đặt cọc sau", for: .normal)
                vc.btnClose.setTitleColor(Tools.hexStringToUIColor(hex: "#787878"), for: .normal)
            } else {
                vc.titleContent = title
                vc.msgContent = message
            }
            self.present(vc, animated: true) {
                vc.typeShow = typeShow
            }
        }
    }
    
    //MARK: - Connect Products
    func connectGetProduct(_ orderID: String, completion: @escaping ([ProductModel], Error?) -> Void) {
        self.dbFireStore.collection(OrderFolderName.rootOrderProduct.rawValue).document(orderID).collection(OrderFolderName.product.rawValue).getDocuments { [weak self](snapshot, error) in
            if let documents = snapshot?.documents {
                var arrProducts = [ProductModel]()
                documents.forEach { (document) in
                    do {
                        let data = try JSONSerialization.data(withJSONObject: document.data(), options: .prettyPrinted)
                        var result = try JSONDecoder().decode(ProductModel.self, from: data)
                        result.productID = document.documentID
                        arrProducts.append(result)
                    } catch  {
                        print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
                    }
                }
                completion(arrProducts, error)
            }
        }
    }
    
    //MARK: - Connect Check OTP
    func connectCheckOTP(_ sOTP: String, completion: @escaping (_ result: Bool) -> ()) {
        guard let user = self.appDelegate.user else {
            self.hideProgressHUD()
            return
        }
        let otpRef = self.dbFireStore.collection(OrderFolderName.userOTP.rawValue).document(user.userID)
        otpRef.getDocument { [weak self](snapshot, error) in
            if let _ = error {
                completion(false)
                self?.showAlertView("Có lỗi xảy ra, vui lòng thử lại sau.", completion: {
                    
                })
            } else if let dict = snapshot?.data() {
                if let token = dict["token"] as? String, let sCreateDate = dict["created_at"] as? String, let dateCreate = Tools.convertDateFromString(sCreateDate, dateFormat: "yyyy-MM-dd HH:mm:ss") {
                    print("\(self?.TAG ?? "") - \(#function) - \(#line) - dateCreate : \(dateCreate) - date : \(Date())")
                    let miliCreate = dateCreate.timeIntervalSince1970
                    let currentTime = Date().timeIntervalSince1970
                    let result = CGFloat(currentTime - miliCreate)
                    print("\(self?.TAG ?? "") - \(#function) - \(#line) - resultTime : \(result)")
                    if result <= 120 && sOTP == token {
                        otpRef.delete { (error) in
                            if let error = error {
                                print("\(self?.TAG ?? "") - \(#function) - \(#line) - error : \(error.localizedDescription)")
                            }
                        }
                        completion(true)
                    } else {
                        self?.showAlertView("Mã OTP không đúng hoặc đã hết hạn. Mỗi mã OTP có hạn trong 2 phút.", completion: {
                            
                        })
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
                self?.showAlertView("Có lỗi xảy ra hoặc mã OTP không đúng, vui lòng thử lại sau.", completion: {
                    
                })
            }
        }
    }
}
