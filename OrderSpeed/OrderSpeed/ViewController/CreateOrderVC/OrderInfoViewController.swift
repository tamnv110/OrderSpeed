//
//  OrderInfoViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/8/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

enum TypeReceive: Int {
    case taiNha
    case taiKho
}

class OrderInfoViewController: MainViewController {

    @IBOutlet weak var tbInfo: UITableView!
    @IBOutlet weak var btnOrder: UIButton!
    var arrOrder = [ProductModel]()

    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#DC7942").cgColor, Tools.hexStringToUIColor(hex: "#F8AB25").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        return gradientLayer
    }()
    
    var receiverName = ""
    var receiverPhone = ""
    var cityName = ""
    var districtName = ""
    var address = ""
    var note = ""
    
    var paymentName = ""
    var paymentPhone = ""
    
    var warehouseName = ""
    var warehouseAddress = ""
    var warehouseID = ""
    
    var deliveryType = Tools.DELIVERY_HOME {
        didSet {
            if deliveryType.name == "Tại nhà" {
                warehouseName = ""
                warehouseAddress = ""
                warehouseID = ""
            } else {
                warehouseName = deliveryType.name
                warehouseAddress = deliveryType.desc
                warehouseID = deliveryType.id
            }
        }
    }
    
    var orderStatus: OrderStatusModel?
    var orderEdit: OrderProductDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        #if DEBUG
//        receiverName = "Nguyễn Văn Tâm"
//        receiverPhone = "094391033"
//        cityName = "Hà Nội"
//        districtName = "Quận Hà Đông"
//        address = "CT1-Nam Xa La, P.Phúc La"
//        note = "Gọi trước 30'"
//        paymentName = "Nguyễn Văn Tâm"
//        paymentPhone = "094391033"
//        #endif
        
        btnOrder.clipsToBounds = true
        btnOrder.layer.insertSublayer(gradientLayer, below: btnOrder.titleLabel?.layer)
        
        tbInfo.tableFooterView = UIView(frame: .zero)
        tbInfo.register(UINib(nibName: "ReceiverInfoTableCell", bundle: nil), forCellReuseIdentifier: "ReceiverInfoTableCell")
        tbInfo.register(UINib(nibName: "PaymenterTableCell", bundle: nil), forCellReuseIdentifier: "PaymenterTableCell")
        tbInfo.register(UINib(nibName: "CheckOrderTableCell", bundle: nil), forCellReuseIdentifier: "CheckOrderTableCell")
        tbInfo.register(UINib(nibName: "ShowTitleTableCell", bundle: nil), forCellReuseIdentifier: "ShowTitleTableCell")
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_EDIT_ORDER"), object: nil, queue: .main) { (notification) in
            if let order = notification.object as? ProductModel {
                if let index = self.arrOrder.firstIndex(where: { (item) -> Bool in
                    return item.code == order.code
                }) {
                    self.arrOrder[index] = order
                    DispatchQueue.main.async {
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        self.tbInfo.reloadSections(IndexSet(integer: 2), with: .automatic)
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_CHANGE_DELIVERY"), object: nil, queue: .main) { (notification) in
            if let delivery = notification.object as? DeliveryModel {
                self.deliveryType = delivery
                DispatchQueue.main.async {
                    self.tbInfo.reloadData()
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NOTIFICATION_DISMISS_ALERT_CUSTOM"), object: nil, queue: .main) { (notification) in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        if let order = orderEdit {
            self.btnOrder.setTitle("Sửa", for: .normal)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sửa", style: .done, target: self, action: #selector(eventChooseDoneEditOrder(_:)))
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            paymentName = order.paymentName
            paymentPhone = order.paymentPhone
            if order.shippingMethod == "Tại nhà" {
                receiverName = order.receiverName
                receiverPhone = order.receiverPhone
                cityName = order.cityName
                districtName = order.districtName
                address = order.receiverAddress
                note = order.note
            } else {
                deliveryType = DeliveryModel(["name": order.warehouseName, "description": order.warehouseAddress, "price": "\(order.shippingCost)"], id: warehouseID)
            }
            connectGetProductEdit(order.idOrder)
        }
        connectGetStatus()
    }
    
    @objc func eventChooseDoneEditOrder(_ sender: Any) {
        editOrderExists()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = "Sửa thông tin"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnOrder.layer.cornerRadius = btnOrder.frame.height / 2
        gradientLayer.frame = btnOrder.bounds
    }
    
    func connectGetStatus() {
        self.showProgressHUD("Xử lý đơn...")
        self.dbFireStore.collection("OrderStatus").whereField("sort", isEqualTo: 1).limit(to: 1).getDocuments { [weak self](snapshot, error) in
            self?.hideProgressHUD()
            if let document = snapshot?.documents.first {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data(), options: [])
                    self?.orderStatus = try JSONDecoder().decode(OrderStatusModel.self, from: jsonData)
                } catch {
                    
                }
            }
        }
    }
    
    func showAlertError() {
        self.showErrorAlertView("Có lỗi xảy ra, vui lòng thử lại sau.") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func connectGetProductEdit(_ orderID: String?) {
        guard let orderID = orderID else {
            self.showAlertError()
            return
        }
        self.showProgressHUD("Lấy sản phẩm...")
        connectGetProduct(orderID) { [weak self](result, error) in
            if let error = error {
                self?.showAlertError()
                
            } else {
                self?.arrOrder.append(contentsOf: result)
                DispatchQueue.main.async {
                    self?.tbInfo.reloadData()
                }
            }
        }
    }

    @objc func eventChooseEditOrder(_ sender: UIButton) {
        if let cell = sender.superview?.superview?.superview as? CheckOrderTableCell, let indexPath = tbInfo.indexPath(for: cell) {
            let order = arrOrder[indexPath.row]
            DispatchQueue.main.async {
                let vc = EditOrderViewController(nibName: "EditOrderViewController", bundle: nil)
                vc.orderInfo = order
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func evenntChooseOrder(_ sender: Any) {
        if orderEdit != nil {
            editOrderExists()
        } else {
            let codeOrder = Tools.randomOrderCode()
            checkOrderCodeExists(codeOrder)
        }
    }
    
    func editOrderExists() {
        guard let order = orderEdit, let orderID = order.idOrder else { return }
        editOrder(orderID)
    }
    
    func checkOrderCodeExists(_ code: String) {
        self.showProgressHUD("Tạo đơn hàng...")
        self.dbFireStore.collection("OrderProduct").whereField("code", isEqualTo: code).getDocuments { [weak self](querySnapshot, error) in
            if let documents = querySnapshot?.documents.count, documents > 0 {
                let codeOrder = Tools.randomOrderCode()
                self?.checkOrderCodeExists(codeOrder)
            } else {
                self?.uploadOrder(code)
            }
        }
    }
    
    func uploadOrder(_ codeOrder: String) {
        let userID = self.appDelegate.user?.userID ?? ""
        
        if deliveryType.name != "Tại nhà" {
            receiverName = ""
            receiverPhone = ""
            cityName = ""
            districtName = ""
            address = ""
            note = ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let sDate = formatter.string(from: Date())
        let serviceCost = Tools.FEE_SERVICE * Double(arrOrder.count)
        
        var order = OrderProductDataModel(code: codeOrder, status: self.orderStatus?.name ?? "Chờ báo giá", productCount: 1, shippingMethod: deliveryType.name, userID: userID, cityName: cityName, districtName: districtName, receiverAddress: address, note: note, receiverName: receiverName, receiverPhone: receiverPhone, paymentName: paymentName, paymentPhone: paymentPhone, warehouseName: warehouseName, warehouseAddress: warehouseAddress, warehouseID: warehouseID, subTotalMoney: 0, depositMoney: 0, currentcyRate: Tools.TI_GIA_NDT, serviceCost: serviceCost, shippingCost: 0, createAt: sDate, updateAt: sDate, currencyLabel: "VND")
        
        let refCol = self.dbFireStore.collection(OrderFolderName.rootOrderProduct.rawValue)
        let refOrder = refCol.document()
        print("\(TAG) - \(#function) - \(#line) - documentID : \(refOrder.documentID)")
        let refDoc = refCol.document(refOrder.documentID)
        let batch = self.dbFireStore.batch()

        var totalMoney: Double = 0
        for (index, item) in arrOrder.enumerated() {
            let itemDoc = refDoc.collection(OrderFolderName.product.rawValue).document()
            let docID = itemDoc.documentID
            totalMoney += (Double(item.amount) * item.price)
            var arrImagesName = [String]()
            if let arrImages = item.arrProductImages {
                var countImage = arrImages.count
                for (index, image) in arrImages.enumerated() {
                    if let uploadData = image.image?.jpegData(compressionQuality: 0.5) {
                        let imageName = "\(docID)_\(index + 1).jpg"
                        print("\(self.TAG) - \(#function) - \(#line) - imageName : \(imageName)")
                        arrImagesName.append(imageName)
                        let imageRef = storageRef.child("Images/\(imageName)")
                        imageRef.putData(uploadData, metadata: nil) { (metaData, error) in
                            countImage -= 1
                            if countImage == 0 {
                                
                            }
                        }
                    }
                }
            }
            let productID = codeOrder + "-\(index + 1)"
            var dict = ProductModel(code: productID, link: item.link, name: item.name, option: item.option, amount: item.amount, price: item.price, fee: Tools.FEE_SERVICE, status: "", note: item.note)
            dict.images = arrImagesName
            batch.setData(dict.dictionary, forDocument: itemDoc)
        }
        if var status = self.orderStatus {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            status.createAt = formatter.string(from: Date())
            let statusDoc = refDoc.collection(OrderFolderName.status.rawValue).document()
            batch.setData(status.dictionary, forDocument: statusDoc)
        }
        order.subTotalMoney = ceil(totalMoney * Tools.TI_GIA_NDT)
        batch.setData(order.dictionary, forDocument: refDoc)

        batch.commit { [weak self](error) in
            self?.hideProgressHUD()
            if let error = error {
                self?.showErrorAlertView("Có lỗi xảy ra, vui lòng thử lại sau."){}
                print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - error : \(error.localizedDescription)")
            } else {
                self?.showAlertController(.showSuccess, message: codeOrder)
                print("\(String(describing: self?.TAG)) - \(#function) - \(#line) - thành công")
            }
        }
    }
    
    func editOrder(_ orderID: String) {
        let batch = self.dbFireStore.batch()
        let refDocOrder = self.dbFireStore.collection(OrderFolderName.rootOrderProduct.rawValue).document(orderID)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let sDate = formatter.string(from: Date())
        let serviceCost = orderEdit!.serviceCost * Double(arrOrder.count)
        
        let userID = self.appDelegate.user?.userID ?? ""
        
        var order = OrderProductDataModel(code: orderEdit!.code, status: self.orderStatus?.name ?? "Chờ báo giá", productCount: 1, shippingMethod: deliveryType.name, userID: userID, cityName: cityName, districtName: districtName, receiverAddress: address, note: note, receiverName: receiverName, receiverPhone: receiverPhone, paymentName: paymentName, paymentPhone: paymentPhone, warehouseName: warehouseName, warehouseAddress: warehouseAddress, warehouseID: warehouseID, subTotalMoney: 0, depositMoney: 0, currentcyRate: Tools.TI_GIA_NDT, serviceCost: serviceCost, shippingCost: 0, createAt: orderEdit!.createAt, updateAt: sDate, currencyLabel: "VND")
        
        formatter.dateFormat = "yyyy-MM-dd-HH:mm:sss"
        
        var totalMoney: Double = 0
        
        var arrUploadData = [(String, String, Data)]()
        for (index, item) in arrOrder.enumerated() {
            totalMoney += (Double(item.amount) * item.price)
            if let docID = item.productID {
                if let arrImages = item.arrProductImages, arrImages.count > 0 {
                    for (indexImage, image) in arrImages.enumerated() {
                        if let uploadData = image.image?.jpegData(compressionQuality: 0.5) {
                            let imageName = "\(docID)_\(indexImage + 1)_\(formatter.string(from: Date())).jpg"
                            let itemUpload = (docID, imageName, uploadData)
                            arrUploadData.append(itemUpload)
                        }
                    }
                }
            }
        }
        
        /*đang xảy ra vấn đề:
         1. arrUploadData 1 product id đang trải dàn trên mảng
         => phải tổng hợp lại trong for
         => update lại array images của ProductModel
        */
        uploadImages(arrUploadData) { kq in
            if kq == 1 {
                for item in arrUploadData {
                    if let dict = self.arrOrder.first(where: { (product) -> Bool in
                        return product.productID == item.0
                    }) {
                        let productDocRef = refDocOrder.collection(OrderFolderName.product.rawValue).document(item.0)
                        batch.updateData(dict.dictionary, forDocument: productDocRef)
                    }
                }
                
            }
            print("\(self.TAG) - \(#function) - \(#line) - chuan bị comit")
            if var status = self.orderStatus {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                status.createAt = formatter.string(from: Date())
                let statusDoc = refDocOrder.collection(OrderFolderName.status.rawValue).document()
                batch.setData(status.dictionary, forDocument: statusDoc)
            }
            order.subTotalMoney = ceil(totalMoney * order.currencyRate)
            batch.updateData(order.dictionary, forDocument: refDocOrder)
            batch.commit { (error) in
                print("\(self.TAG) - \(#function) - \(#line) - edit thanh cong")
            }
        }
    }
    
    func uploadImages(_ uploadDict: [(String, String, Data)], completion: @escaping (Int)->()) {
        if uploadDict.count == 0 {
            completion(0)
        }
        var countImage = uploadDict.count
        for item in uploadDict {
            let imageRef = storageRef.child("Images/\(item.1)")
            imageRef.putData(item.2, metadata: nil) { (metaData, error) in
                countImage -= 1
                print("\(self.TAG) - \(#function) - \(#line) - countImage : \(countImage)")
                if countImage == 0 {
                    completion(1)
                }
            }
        }
    }
    
    @objc func eventChooseCity(_ sender: UIControl) {
        openChooseCity()
    }

    func openChooseCity() {
        DispatchQueue.main.async {
            let vc = ChooseCityViewController(nibName: "ChooseCityViewController", bundle: nil)
            vc.delegate = self
            vc.itemSelected = (self.cityName, self.districtName)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func eventChooseDeliveryOption(_ sender: UIButton) {
        DispatchQueue.main.async {
            DispatchQueue.main.async {
                let vc = ChooseDeliveryViewController(nibName: "ChooseDeliveryViewController", bundle: nil)
                vc.itemSelected = self.deliveryType
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension OrderInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return arrOrder.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = Tools.hexStringToUIColor(hex: "#f9f9f9")
        let lblTitle = UILabel()
        if section == 0 {
            lblTitle.text = "NHẬN HÀNG"
        } else if section == 1 {
            lblTitle.text = "NGƯỜI THANH TOÁN"
        } else if section == 2 {
            lblTitle.text = "ĐƠN HÀNG"
        }
        
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(lblTitle)
        lblTitle.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16).isActive = true
        lblTitle.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        
        if section == 0 {
            let btnOption = UIButton(type: .custom)
            btnOption.contentHorizontalAlignment = .left
            btnOption.setImage(UIImage(named: "icon_accessory_cell"), for: .normal)
            btnOption.setTitleColor(.black, for: .normal)
            btnOption.setTitle(deliveryType.name, for: .normal)
            btnOption.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            btnOption.translatesAutoresizingMaskIntoConstraints = false
            header.addSubview(btnOption)
            
            btnOption.setContentHuggingPriority(.defaultLow, for: .horizontal)
            lblTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            let leading = btnOption.leadingAnchor.constraint(equalTo: lblTitle.trailingAnchor, constant: 8)
            leading.priority = UILayoutPriority(999)
            leading.isActive = true
            btnOption.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -8).isActive = true
            btnOption.heightAnchor.constraint(equalToConstant: 44).isActive = true
            btnOption.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
            
            
            btnOption.imageToRight()
            btnOption.addTarget(self, action: #selector(eventChooseDeliveryOption(_:)), for: .touchUpInside)
        }

        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if deliveryType.name == "Tại nhà" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverInfoTableCell", for: indexPath) as! ReceiverInfoTableCell
                cell.delegate = self
                cell.showInfo(receiverName, phone: receiverPhone, cityName: cityName, districtName: districtName, address: address, note: note)
                cell.controlCity.addTarget(self, action: #selector(eventChooseCity(_:)), for: .touchUpInside)
                cell.controlDistrict.addTarget(self, action: #selector(eventChooseCity(_:)), for: .touchUpInside)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTitleTableCell", for: indexPath) as! ShowTitleTableCell
                cell.lblTitle.text = deliveryType.desc
                cell.setupLeadingTitle(16)
                return cell
            }
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymenterTableCell", for: indexPath) as! PaymenterTableCell
            cell.delegate = self
            cell.showInfo(paymentName, phone: paymentPhone)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckOrderTableCell", for: indexPath) as! CheckOrderTableCell
            cell.lblTitle.text = "SẢN PHẨM \(indexPath.row + 1)"
            let item = arrOrder[indexPath.row]
            cell.product = item
            if (item.arrProductImages?.count ?? 0 == 0) && (item.images?.count ?? 0 == 0) {
                cell.heightCollectionImages.constant = 0
            } else {
                cell.heightCollectionImages.constant = cell.heightCollectionOld
            }
            cell.btnEdit.addTarget(self, action: #selector(eventChooseEditOrder(_:)), for: .touchUpInside)
            return cell
        }
    }
}

extension OrderInfoViewController: ChooseCityDelegate {
    func eventChooseCity(_ cityName: String, districtName: String) {
        self.cityName = cityName
        self.districtName = districtName
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.tbInfo.reloadData()
        }
    }
}

extension OrderInfoViewController: ReceiverInfoCellDelegate {
    func inputInfo(_ info: (String, String, String, String, String, String)) {
        receiverName = info.0
        receiverPhone = info.1
        address = info.4
        note = info.5
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

extension OrderInfoViewController: PaymenterTableCellDelegate {
    func inputInfoPayment(_ info: (String, String)) {
        paymentName = info.0
        paymentPhone = info.1
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
