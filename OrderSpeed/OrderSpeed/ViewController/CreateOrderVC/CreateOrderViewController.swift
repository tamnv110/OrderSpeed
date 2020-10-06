//
//  CreateOrderViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/5/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class CreateOrderViewController: MainViewController {

    @IBOutlet weak var tbOrder: UITableView!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnAddProduct: UIButton!
    @IBOutlet weak var btnContinute: UIButton!
    
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#DC7942").cgColor, Tools.hexStringToUIColor(hex: "#F8AB25").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        return gradientLayer
    }()
    
    var countSection = 1
    var cellChooseImage: CreateOrderTableViewCell?
//    var arrProductOrder = [OrderProductModel(id: 1, link: "http://youtube.com", name: "Giày", size: "7.5", note: "Âm Thầm Bên Em | OFFICIAL MUSIC VIDEO | Sơn Tùng M-TP", number: 1, price: 10.0, arrProductImages: nil)]
    var arrProductOrder = [ProductModel(code: "1", link: "", name: "", option: "", amount: 0, price: 0, fee: 0, status: "", note: "")]
    
    var tiGiaNgoaiTe: Double = 0.0
    var isKeyboardAppear = false
    var urlInput = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnContinute.clipsToBounds = true
        btnContinute.layer.insertSublayer(gradientLayer, below: btnContinute.titleLabel?.layer)
        if #available(iOS 11.0, *) {
            tbOrder.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        tbOrder.tableFooterView = UIView(frame: .zero)
        tbOrder.register(UINib(nibName: "CreateOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateOrderTableViewCell")
        NotificationCenter.default.addObserver(self, selector: #selector(eventShowKeyboard(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventHideKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editingCustomTextField(_:)), name: NSNotification.Name("NOTIFICATION_BEGIN_EDITING_TEXTVIEW"), object: nil)
        
        arrProductOrder[0].link = urlInput
    }
    
    deinit {
//        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func editingCustomTextField(_ notification: Notification) {
        if let tf = notification.object as? CustomTextViewPlaceHolder {
            print("\(self.TAG) - \(#function) - \(#line) - result : \(tf.frame.height)")
            var contentOffset = tbOrder.contentOffset
            contentOffset.y += (tf.frame.height + 50)
            tbOrder.contentOffset = contentOffset
        }
    }
    
    @objc func eventShowKeyboard(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            tbOrder.setBottomInset(to: keyboardHeight)
        }
    }
    
    @objc func eventHideKeyboard(_ notification: Notification) {
        isKeyboardAppear = false
        tbOrder.contentInset = .zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.title = "Thông tin đơn hàng"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnReset.layer.cornerRadius = btnReset.frame.height / 2
        btnAddProduct.layer.cornerRadius = btnAddProduct.frame.height / 2
        btnContinute.layer.cornerRadius = btnContinute.frame.height / 2
        gradientLayer.frame = btnContinute.bounds
    }

    func addNewItemToList() {
//        let item = OrderProductModel(id: countSection, link: "", name: "", size: "", note: "", number: 0, price: 0.0, arrProductImages: nil)
//        arrProductOrder.append(item)
        let item = ProductModel(code: "\(countSection)", link: "", name: "", option: "", amount: 0, price: 0, fee: 0, status: "", note: "")
        arrProductOrder.append(item)
    }

    @objc func eventChooseDeleteOrder(_ sender: UIButton) {
        arrProductOrder.remove(at: sender.tag)
        if arrProductOrder.count == 0 {
            addNewItemToList()
            countSection = 1
        }
        DispatchQueue.main.async {
            self.tbOrder.reloadData()
        }
    }
    
    @IBAction func eventChooseReset(_ sender: Any) {
        countSection = 1
        arrProductOrder.removeAll()
        addNewItemToList()
        DispatchQueue.main.async {
            self.tbOrder.reloadData()
        }
    }
    
    @IBAction func eventChooseAddProduct(_ sender: Any) {
        btnAddProduct.isEnabled = false
        countSection += 1
        addNewItemToList()
        DispatchQueue.main.async {
            self.tbOrder.reloadData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.btnAddProduct.isEnabled = true
        }
    }
    
    func checkInput() -> Bool {
        var flag = true
        for (index, item) in arrProductOrder.enumerated() {
            let indexPath = IndexPath(row: 0, section: index)
            if let cell = tbOrder.cellForRow(at: indexPath) as? CreateOrderTableViewCell {
                let result = cell.checkInput()
                if flag {
                    flag = result
                }
            }
        }
        return flag
    }
    
    @IBAction func eventChooseContinute(_ sender: Any) {
        if checkInput() {
            DispatchQueue.main.async {
                let vc = OrderInfoViewController(nibName: "OrderInfoViewController", bundle: nil)
                vc.arrOrder = self.arrProductOrder
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

extension CreateOrderViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrProductOrder.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = Tools.hexStringToUIColor(hex: "#E5E5E5")
        let lblTitle = UILabel()
        lblTitle.text = "SẢN PHẨM \(section + 1)"
        lblTitle.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(lblTitle)
        lblTitle.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16).isActive = true
        lblTitle.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        
        let btnDelete = UIButton()
        btnDelete.setTitle(nil, for: .normal)
        btnDelete.tag = section
        btnDelete.setImage(UIImage(named: "icon_trash"), for: .normal)
        btnDelete.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(btnDelete)
        btnDelete.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: 0).isActive = true
        btnDelete.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        btnDelete.widthAnchor.constraint(equalToConstant: 44).isActive = true
        btnDelete.heightAnchor.constraint(equalToConstant: 44).isActive = true
        btnDelete.addTarget(self, action: #selector(eventChooseDeleteOrder(_:)), for: .touchUpInside)
        return header
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? CreateOrderTableViewCell {
            let item = arrProductOrder[indexPath.section]
            cell.showInfo(item)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateOrderTableViewCell", for: indexPath) as! CreateOrderTableViewCell
        cell.delegate = self
        return cell
    }
    
    func choosePhoto() {
        DispatchQueue.main.async {
            let vc = ListPhotosViewController(nibName: "ListPhotosViewController", bundle: nil)
            vc.delegate = self
            vc.typeUpload = 1
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension CreateOrderViewController: CreateOrderCellDelegate {
    func deleteImageFromServer(_ imageName: String) {
        
    }
    
    func imageCountGreateThanMax(_ count: Int) {
        
    }
    
    func eventChooseProductImages(_ cell: CreateOrderTableViewCell) {
        cellChooseImage = cell
        choosePhoto()
    }
    
    func updateInfoOrderProduct(_ item: ProductModel?) {
        guard let order = item else { return }
        if let index = arrProductOrder.firstIndex(where: { (item2) -> Bool in
            return order.code == item2.code
        }) {
            print("\(TAG) - \(#function) - \(#line) - order : \(order.code) - index: \(index)")
            arrProductOrder[index] = order
        }
    }
}

extension CreateOrderViewController: ListPhotoDelegate {
    func eventChooseImages(_ arrImages: [ItemImageSelect]) {
        if let cell = cellChooseImage, let indexPath = tbOrder.indexPath(for: cell) {
            print("\(TAG) - \(#function) - \(#line) - indexPath : \(indexPath.section)")
            arrProductOrder[indexPath.section].arrProductImages = arrImages
            DispatchQueue.main.async {
                self.tbOrder.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
            }
        }
    }
}
