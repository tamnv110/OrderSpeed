//
//  RequestSupportViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/17/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import Firebase

class RequestSupportViewController: MainViewController {

    @IBOutlet weak var tfTieuDe: BottomLineTextField!
    @IBOutlet weak var tfNoiDung: CustomTextViewPlaceHolder!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var tbInfo: UITableView!
    
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#DC7942").cgColor, Tools.hexStringToUIColor(hex: "#F8AB25").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        return gradientLayer
    }()
    var arrSupport = [SupportModel]()
    var order: OrderProductDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSend.layer.insertSublayer(gradientLayer, below: btnSend.titleLabel?.layer)
        tbInfo.tableFooterView = UIView(frame: .zero)
        tbInfo.register(UINib(nibName: "ManagerOrderTableCell", bundle: nil), forCellReuseIdentifier: "ManagerOrderTableCell")
        tbInfo.register(UINib(nibName: "SupportTableViewCell", bundle: nil), forCellReuseIdentifier: "SupportTableViewCell")
        connectGetListSupport()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = btnSend.bounds
    }

    func connectGetListSupport() {
        self.dbFireStore.collection("Support").getDocuments { [weak self](snapshot, error) in
            if let documents = snapshot?.documents {
                self?.arrSupport = documents.map { (document) -> SupportModel in
                    let dict = document.data()
                    return SupportModel(account: (dict["account"] as? String) ?? "", name: (dict["name"] as? String) ?? "", phone: (dict["phone"] as? String) ?? "")
                }
                DispatchQueue.main.async {
                    self?.tbInfo.reloadData()
                }
            }
        }
    }
    
    @objc func eventChooseCall(_ sender: UIButton) {
        if let cell = sender.superview?.superview?.superview as? SupportTableViewCell, let indexPath = tbInfo.indexPath(for: cell) {
            let item = arrSupport[indexPath.row]
            Tools.makePhoneCall(item.phone)
        }
    }
    
    @IBAction func eventChooseDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func eventChooseSend(_ sender: Any) {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        guard let user = self.appDelegate.user, let orderID = order?.idOrder else { return }
        self.showProgressHUD("Gửi hỗ trợ...")
        let item = RequestSupportModel(user.userID, userName: user.fullname, userPhone: user.phoneNumber, title: tfTieuDe.text!, content: tfNoiDung.text!, orderID: orderID)
        self.dbFireStore.collection("RequestSupport").addDocument(data: item.dictionary) { [weak self](error) in
            self?.hideProgressHUD()
            if let _ = error {
                self?.showErrorAlertView("Có lỗi xảy ra, vui lòng thử lại sau."){}
            } else {
                self?.showErrorAlertView("Gửi yêu cầu hỗ trợ thành công. Chúng tôi sẽ phản hồi bạn sớm nhất."){}
            }
        }
    }
    
}

extension RequestSupportViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (self.arrSupport.count > 0 ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.arrSupport.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ManagerOrderTableCell", for: indexPath) as! ManagerOrderTableCell
            cell.showInfo(order!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupportTableViewCell", for: indexPath) as! SupportTableViewCell
            let item = arrSupport[indexPath.row]
            cell.showInfo(item)
            cell.btnPhone.addTarget(self, action: #selector(eventChooseCall(_:)), for: .touchUpInside)
            return cell
        }
    }
}
