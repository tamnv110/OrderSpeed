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
    var arrProductOrder = [OrderProductModel(id: 1, link: "", name: "", size: "", note: "", number: 0, price: 0.0, arrProductImages: nil)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        btnContinute.clipsToBounds = true
        btnContinute.layer.insertSublayer(gradientLayer, below: btnContinute.titleLabel?.layer)
        tbOrder.tableFooterView = UIView(frame: .zero)
        tbOrder.register(UINib(nibName: "CreateOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateOrderTableViewCell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnReset.layer.cornerRadius = btnReset.frame.height / 2
        btnAddProduct.layer.cornerRadius = btnAddProduct.frame.height / 2
        btnContinute.layer.cornerRadius = btnContinute.frame.height / 2
        gradientLayer.frame = btnContinute.bounds
    }
    
    func addNewItemToList() {
        let item = OrderProductModel(id: countSection, link: "", name: "", size: "", note: "", number: 0, price: 0.0, arrProductImages: nil)
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
            cell.orderProduct = item
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateOrderTableViewCell", for: indexPath) as! CreateOrderTableViewCell
        cell.delegate = self
        return cell
    }
    
    func choosePhoto() {
//        var arrImageSelected = UIImage()
//        if let cell = cellChooseImage, let indexPath = tbOrder.indexPath(for: cell) {
//            arrImageSelected = arrProductOrder[indexPath.section].arrProductImages
//        }
        DispatchQueue.main.async {
            let vc = ListPhotosViewController(nibName: "ListPhotosViewController", bundle: nil)
            vc.delegate = self
            vc.typeUpload = 1
//            vc.arr
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension CreateOrderViewController: CreateOrderCellDelegate {
    func eventChooseProductImages(_ cell: CreateOrderTableViewCell) {
        cellChooseImage = cell
        choosePhoto()
    }
    
    func updateInfoOrderProduct(_ item: OrderProductModel?) {
        guard let order = item else { return }
        if let index = arrProductOrder.firstIndex(where: { (item2) -> Bool in
            return order.id == item2.id
        }) {
            print("\(TAG) - \(#function) - \(#line) - order : \(order.id) - index: \(index)")
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
