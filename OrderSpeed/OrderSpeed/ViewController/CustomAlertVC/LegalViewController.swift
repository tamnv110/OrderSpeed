//
//  LegalViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 10/15/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class LegalViewController: MainViewController {

    @IBOutlet weak var viewContent: UIView!
    var webContent: WKWebView!
    @IBOutlet weak var lblLegal: UILabel!
    @IBOutlet weak var viewMain: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webContent = WKWebView()
        webContent.translatesAutoresizingMaskIntoConstraints = false
        viewContent.addSubview(webContent)
        
        webContent.topAnchor.constraint(equalTo: viewContent.topAnchor, constant: 0).isActive = true
        webContent.bottomAnchor.constraint(equalTo: viewContent.bottomAnchor, constant: 0).isActive = true
        webContent.leadingAnchor.constraint(equalTo: viewContent.leadingAnchor, constant: 0).isActive = true
        webContent.trailingAnchor.constraint(equalTo: viewContent.trailingAnchor, constant: 0).isActive = true
        
        let htmlContent = "<p style=\"font-size: 48px;\">Chào mừng bạn đến với ứng dụng OrderSpeed. Bạn có thể dùng ứng dụng này để xem thông tin, nhờ đặt mua các sản phẩm.</p><p style=\"font-size: 48px;\">Chúng tôi sẽ nghiêm chỉnh tuân theo pháp luật, quy định có liên quan và chính sách quyền riêng tư để bảo vệ thông tin cá nhân của bạn.</p><p style=\"font-size: 48px;\">Để sử dụng bình thường, ứng dụng cần quyền truy cập Internet.</p><p style=\"font-size: 48px;\">Bạn có thể gỡ cài đặt hoặc thoát ứng dụng nếu không đồng ý với các điều kiện trên.</p>"
        webContent.loadHTMLString(htmlContent, baseURL: nil)
        
        let attributed = NSMutableAttributedString(string: "Vui lòng đọc và đồng ý với ", attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        attributed.append(NSAttributedString(string: "Chính sách và bảo mật.", attributes: [NSAttributedString.Key.foregroundColor : Tools.hexStringToUIColor(hex: "#F8AD25")]))
        lblLegal.attributedText = attributed
        lblLegal.isUserInteractionEnabled = true
        lblLegal.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(eventChooseLegal(_:))))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewMain.roundCorners(corners: [.topLeft, .topRight], radius: 20)
    }

    @objc func eventChooseLegal(_ gesture: UITapGestureRecognizer) {
        let vc = SFSafariViewController(url: URL(string: "http://orderspeed.vn/chinh-sach")!)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func eventChooseYes(_ sender: Any) {
        Tools.saveObjectToDefault(true, key: "KEY_LEGAL")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func eventChooseNo(_ sender: Any) {
        Tools.saveObjectToDefault(false, key: "KEY_LEGAL")
        self.dismiss(animated: true, completion: nil)
    }
    

}
