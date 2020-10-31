//
//  EditOrderViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/16/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

//protocol EditOrderVCDelegate {
//    func eventEditProduct(_ item: ProductModel?)
//}

class EditOrderViewController: MainViewController {

    @IBOutlet weak var tbOrder: UITableView!
    var arrImageServerDeleted: [String]?
    var orderInfo: ProductModel?
    var typeEdit = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let btnDone = UIBarButtonItem(title: "Hoàn thành", style: .done, target: self, action: #selector(eventChooseEditProduct(_:)))
        self.navigationItem.rightBarButtonItem = btnDone
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        tbOrder.tableFooterView = UIView(frame: .zero)
        tbOrder.separatorStyle = .none
        tbOrder.register(UINib(nibName: "CreateOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateOrderTableViewCell")
        
        print("\(TAG) - \(#function) - \(#line) - orderInfo : \(String(describing: orderInfo?.code)) - typeEdit : \(typeEdit)")
    }
    
    @objc func eventChooseEditProduct(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_EDIT_ORDER"), object: self.orderInfo)
            if let arrImageDel = self.arrImageServerDeleted, arrImageDel.count > 0 {
                NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_EDIT_ORDER_DELETE_IMAGES"), object: arrImageDel)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func choosePhoto() {
        DispatchQueue.main.async {
            let vc = ListPhotosViewController(nibName: "ListPhotosViewController", bundle: nil)
            vc.delegate = self
            vc.typeUpload = 1
            if let arrImages = self.orderInfo?.arrProductImages {
                vc.arrSelectedImage = arrImages
            }
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension EditOrderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderInfo != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateOrderTableViewCell", for: indexPath) as! CreateOrderTableViewCell
        cell.refStorage = self.storageRef
        cell.showInfo(orderInfo)
        cell.delegate = self
        return cell
    }
}

extension EditOrderViewController: CreateOrderCellDelegate {
    func deleteImageFromServer(_ imageName: String) {
        if arrImageServerDeleted == nil {
            arrImageServerDeleted = [String]()
        }
        arrImageServerDeleted?.append(imageName)
    }
    
    func imageCountGreateThanMax(_ count: Int) {
        self.showAlertView("Số lượng ảnh tối đa là \(Tools.MAX_IMAGES). \r\nĐể thay ảnh mới bạn phải xoá ảnh trước khi thêm.") {
            
        }
    }
    
    func eventChooseProductImages(_ cell: CreateOrderTableViewCell) {
        choosePhoto()
    }
    
    func updateInfoOrderProduct(_ item: ProductModel?) {
        guard let order = item else { return }
        orderInfo = order
        if let btnRight = self.navigationItem.rightBarButtonItem, !btnRight.isEnabled {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
}

extension EditOrderViewController: ListPhotoDelegate {
    func eventChooseImages(_ arrImages: [ItemImageSelect]) {
        if orderInfo?.arrProductImages == nil {
            orderInfo?.arrProductImages = [ItemImageSelect]()
        }
        orderInfo?.arrProductImages = arrImages
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.tbOrder.reloadData()
        }
    }
}
