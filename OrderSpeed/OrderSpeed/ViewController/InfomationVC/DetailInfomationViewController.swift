//
//  DetailInfomationViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/24/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import WebKit

class DetailInfomationViewController: MainViewController {
    
    @IBOutlet weak var contentView: UIView!
    var webDetail: WKWebView!
    var infomation: InformationModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        webDetail = WKWebView(frame: contentView.bounds, configuration: webConfiguration)
        webDetail.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(webDetail)
        webDetail.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        webDetail.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        webDetail.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        webDetail.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        webDetail.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        webDetail.scrollView.showsVerticalScrollIndicator = false
        webDetail.scrollView.showsHorizontalScrollIndicator = false
        showDetailInformation()
    }

    func showDetailInformation() {
        guard let item = infomation else { return }
        let html = "<html><head><style>h1 { font-size: 56px; padding: 5px;} h2 { font-size: 48px;  padding: 5px;} p { font-size: 44px;  padding: 5px;} div {font-size: 44px; padding: 5px;} body {overflow: hidden;} </style></head><body><h1>\(item.title)</h1><div>\(item.content)</div></body></html>"
        webDetail.loadHTMLString(html, baseURL: nil)
    }

}
