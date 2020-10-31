//
//  OrderProductViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 10/28/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class OrderProductViewController: MainViewController {

    @IBOutlet weak var imgvProduct: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#DC7942").cgColor, Tools.hexStringToUIColor(hex: "#F8AB25").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        return gradientLayer
    }()
    
    var countProduct = 1 {
        didSet {
            lblCount.text = "\(countProduct)"
        }
    }
    
    var itemProduct: ProductModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnContinue.clipsToBounds = true
        btnContinue.layer.insertSublayer(gradientLayer, below: btnContinue.titleLabel?.layer)
        
        showInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnContinue.layer.cornerRadius = btnContinue.frame.height / 2
        gradientLayer.frame = btnContinue.bounds
    }
    
    func showInfo() {
        guard let item = itemProduct else {
            lblName.text = ""
            lblPrice.text = "Giá:"
            return
        }
        lblName.text = item.name
        var sPrice = Tools.convertCurrencyFromString(input: "\(item.price)")
        if sPrice.hasSuffix(".0") {
            sPrice = sPrice.replacingOccurrences(of: ".0", with: "")
        }
        lblPrice.text = "Giá: \(sPrice)"
        if let linkImage = item.images?.first {
            imgvProduct.sd_setImage(with: URL(string: linkImage))
        }
    }

    @IBAction func eventChooseMinus(_ sender: Any) {
        if countProduct > 1 {
            countProduct -= 1
        }
    }
    
    @IBAction func eventChoosePlus(_ sender: Any) {
        countProduct += 1
    }
    
    @IBAction func eventChooseContinue(_ sender: Any) {
        guard let item = itemProduct else { return }
        let model = ProductModel(code: "1", link: item.link, name: item.name, option: "", amount: countProduct, price: item.price, fee: 0, status: "", note: "")
        let vc = OrderInfoViewController(nibName: "OrderInfoViewController", bundle: nil)
        vc.arrOrder = [model]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
