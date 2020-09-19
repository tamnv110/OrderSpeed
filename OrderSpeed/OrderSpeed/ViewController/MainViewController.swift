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
    }
    
    deinit {
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

    func showAlertController(_ typeShow: AlertShowType, message: String) {
        DispatchQueue.main.async {
            let vc = CustomAlertViewController(nibName: "CustomAlertViewController", bundle: nil)
            vc.modalPresentationStyle = .overFullScreen
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            if typeShow == .showSuccess {
                vc.sOrderCode = message
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
}
