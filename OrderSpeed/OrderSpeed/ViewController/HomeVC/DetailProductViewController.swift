//
//  DetailProductViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 10/27/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import WebKit

class DetailProductViewController: MainViewController {

    @IBOutlet weak var viewWeb: UIView!
    @IBOutlet weak var btnMua: UIButton!
    var webContent: WKWebView!
    var itemProduct: ProductModel?
    
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#DC7942").cgColor, Tools.hexStringToUIColor(hex: "#F8AB25").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        return gradientLayer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Thông tin sản phẩm"
        
        btnMua.setTitleColor(.white, for: .normal)
        btnMua.clipsToBounds = true
        btnMua.layer.insertSublayer(gradientLayer, below: btnMua.titleLabel?.layer)
        
        webContent = WKWebView()
        webContent.translatesAutoresizingMaskIntoConstraints = false
        viewWeb.addSubview(webContent)
        
        webContent.topAnchor.constraint(equalTo: viewWeb.topAnchor, constant: 0).isActive = true
        webContent.bottomAnchor.constraint(equalTo: viewWeb.bottomAnchor, constant: 0).isActive = true
        webContent.leadingAnchor.constraint(equalTo: viewWeb.leadingAnchor, constant: 0).isActive = true
        webContent.trailingAnchor.constraint(equalTo: viewWeb.trailingAnchor, constant: 0).isActive = true
        showInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnMua.layer.cornerRadius = btnMua.frame.height / 2
        gradientLayer.frame = btnMua.bounds
    }

    
    func showInfo() {
        guard let item = itemProduct else { return }
        let html = "<html><head><meta charset=\"utf-8\"><style>.price {font-size: 34px; color: red; font-weight: bold} img {max-width: 100%; height: auto} ul {list-style: none} .container {width: 100%; float: left; overflow: hidden} body {font-size: 34px;}</style></head><body>\(item.option)</body></html>"
        webContent.loadHTMLString(html, baseURL: nil)
    }
    
    @IBAction func eventChooseMuaSanPham(_ sender: Any) {
        guard let item = itemProduct else { return }
        let vc = OrderProductViewController(nibName: "OrderProductViewController", bundle: nil)
        vc.itemProduct = item
        self.navigationController?.pushViewController(vc, animated: true)
//        let vc = CreateOrderViewController(nibName: "CreateOrderViewController", bundle: nil)
//        vc.productTrans = item
//        self.navigationController?.pushViewController(vc, animated: true)
    }
}
