//
//  CustomBrowserViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 10/2/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import WebKit

class CustomBrowserViewController: MainViewController {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var progressLoading: UIProgressView!
    
    lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [Tools.hexStringToUIColor(hex: "#DC7942").cgColor, Tools.hexStringToUIColor(hex: "#F8AB25").cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        return gradientLayer
    }()
    
    var webView: WKWebView!
    var arrURL = [String]()
    var toast: ToastView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView()
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        viewMain.addSubview(webView)
        
        webView.topAnchor.constraint(equalTo: viewMain.topAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: viewMain.bottomAnchor, constant: 0).isActive = true
        webView.leadingAnchor.constraint(equalTo: viewMain.leadingAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: viewMain.trailingAnchor, constant: 0).isActive = true
        
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        btnCreate.clipsToBounds = true
        btnCreate.layer.insertSublayer(gradientLayer, below: btnCreate.titleLabel?.layer)
        
        progressLoading.progress = 0.0
        progressLoading.isHidden = true
        
        if let sURL = arrURL.first, let url = URL(string: sURL) {
            print("\(self.TAG) - \(#function) - \(#line) - sURL : \(sURL)")
            webView.load(URLRequest(url: url))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        btnCreate.layer.cornerRadius = btnCreate.frame.height / 2
        gradientLayer.frame = btnCreate.bounds
    }

    @IBAction func eventChooseDone(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "loading" {
            progressLoading.isHidden = (webView.estimatedProgress == 1) ? true : false
            if webView.estimatedProgress == 1 {
                progressLoading.progress = 0
            }
            btnBack.isEnabled = webView.canGoBack
            btnForward.isEnabled = webView.canGoForward
        }
        else if keyPath == "estimatedProgress" {
            progressLoading.progress = Float(webView.estimatedProgress)
        }
    }
    
    @IBAction func eventChooseCopyLink(_ sender: Any) {
        if let url = webView.url?.absoluteString {
            UIPasteboard.general.string = url
            if toast == nil {
                toast = ToastView()
            }
            toast?.showMessage("Đã sao chép", inView: self.view)
            if #available(iOS 10.0, *) {
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
                    self.toast?.removeFromSuperview()
                }
            } else {
                Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.eventTimerSchedule(_:)), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func eventTimerSchedule(_ timer: Timer) {
        self.toast?.removeFromSuperview()
        timer.invalidate()
    }
    
    @IBAction func eventCreateOrderProduct(_ sender: Any) {
        if let url = webView.url?.absoluteString {
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: NSNotification.Name("NOTIFICATION_CREATE_WITH_LINK"), object: url, userInfo: nil)
            }
        }
    }
    
    @IBAction func eventChooseBack(_ sender: Any) {
        webView.goBack()
    }
    
    @IBAction func eventChooseForward(_ sender: Any) {
        webView.goForward()
    }
    
}

extension CustomBrowserViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { (result, error) in
//            print("\(self.TAG) - \(#function) - \(#line) - result : \(String(describing: result as? String))")
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let sURL = navigationAction.request.url?.absoluteString {
            
        }
        decisionHandler(.allow)
    }
}
