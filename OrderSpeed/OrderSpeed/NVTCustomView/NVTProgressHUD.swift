//
//  NVTProgressHUD.swift
//  CookBook101
//
//  Created by Tam Nguyen on 2/26/18.
//  Copyright © 2018 Tam Nguyen. All rights reserved.
//

import UIKit

class NVTProgressHUD {
    static public let shared = NVTProgressHUD()
    internal var viewHud:UIView!
    var viewSubHud:UIView!
    var imgvHud:UIActivityIndicatorView!
    var lblMessage:UILabel!
    var fontMessage = UIFont.systemFont(ofSize: 15.0)
    var message : String = "Loading..."
    var wSubHud:CGFloat = 150.0
    var hSubHud:CGFloat = 100.0
    
    public init() {
        viewHud = UIView()
        viewHud.backgroundColor = UIColor(white: 0, alpha: 0.6)
        
        viewSubHud = UIView()
        viewSubHud.backgroundColor = UIColor(white: 0, alpha:0.8)
        viewSubHud.layer.cornerRadius = 8
//       , UIImage(named: "loading3")!, UIImage(named: "loading4")!, UIImage(named: "loading5")!, UIImage(named: "loading6")!, UIImage(named: "loading7")!
        imgvHud = UIActivityIndicatorView()
        imgvHud.style = .whiteLarge
        
        lblMessage = UILabel()
        lblMessage.textColor = UIColor.white
        lblMessage.textAlignment = .center
        lblMessage.font = self.fontMessage
    }
    
    public convenience init(_ view:UIView) {
        self.init()
        
        imgvHud.startAnimating()
        viewHud.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.viewHud)
        
        self.viewHud.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.viewHud.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.viewHud.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.viewHud.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:0).isActive = true
        
        self.viewSubHud.translatesAutoresizingMaskIntoConstraints = false
        self.viewHud.addSubview(self.viewSubHud)
        
        self.viewSubHud.centerXAnchor.constraint(equalTo: viewHud.centerXAnchor, constant: 0).isActive = true
        self.viewSubHud.centerYAnchor.constraint(equalTo: viewHud.centerYAnchor, constant: 0).isActive = true
        self.viewSubHud.heightAnchor.constraint(equalToConstant: hSubHud).isActive = true
        self.viewSubHud.widthAnchor.constraint(equalToConstant: wSubHud).isActive = true
        
        self.imgvHud.translatesAutoresizingMaskIntoConstraints = false
        self.viewSubHud.addSubview(self.imgvHud)
        
        imgvHud.topAnchor.constraint(equalTo: viewSubHud.topAnchor, constant: 12).isActive = true
        imgvHud.centerXAnchor.constraint(equalTo: viewSubHud.centerXAnchor, constant: 0).isActive = true
        
        self.lblMessage.translatesAutoresizingMaskIntoConstraints = false
        self.viewSubHud.addSubview(self.lblMessage)
        self.lblMessage.text = self.message
        self.lblMessage.bottomAnchor.constraint(equalTo: self.viewSubHud.bottomAnchor, constant: -3).isActive = true
        self.lblMessage.leadingAnchor.constraint(equalTo: self.viewSubHud.leadingAnchor).isActive = true
        self.lblMessage.trailingAnchor.constraint(equalTo: self.viewSubHud.trailingAnchor).isActive = true
        self.lblMessage.topAnchor.constraint(equalTo: self.imgvHud.bottomAnchor, constant: -3).isActive = true
    }
    
    public func showInView(_ view:UIView, khoangTru:CGFloat = 0) -> Void {
        imgvHud.startAnimating()
        viewHud.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.viewHud)

        self.viewHud.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.viewHud.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.viewHud.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.viewHud.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:khoangTru).isActive = true

        self.viewSubHud.translatesAutoresizingMaskIntoConstraints = false
        self.viewHud.addSubview(self.viewSubHud)
        
        self.viewSubHud.centerXAnchor.constraint(equalTo: viewHud.centerXAnchor, constant: 0).isActive = true
        self.viewSubHud.centerYAnchor.constraint(equalTo: viewHud.centerYAnchor, constant: 0).isActive = true
        self.viewSubHud.heightAnchor.constraint(equalToConstant: hSubHud).isActive = true
        self.viewSubHud.widthAnchor.constraint(equalToConstant: wSubHud).isActive = true
        
        self.imgvHud.translatesAutoresizingMaskIntoConstraints = false
        self.viewSubHud.addSubview(self.imgvHud)
        
        if self.message.isEmpty {
            imgvHud.centerYAnchor.constraint(equalTo: viewSubHud.centerYAnchor).isActive = true
        } else {
            imgvHud.topAnchor.constraint(equalTo: viewSubHud.topAnchor, constant: 12).isActive = true
        }
        imgvHud.centerXAnchor.constraint(equalTo: viewSubHud.centerXAnchor, constant: 0).isActive = true
        
        self.lblMessage.translatesAutoresizingMaskIntoConstraints = false
        self.viewSubHud.addSubview(self.lblMessage)
        self.lblMessage.text = self.message
        self.lblMessage.bottomAnchor.constraint(equalTo: self.viewSubHud.bottomAnchor, constant: -3).isActive = true
        self.lblMessage.leadingAnchor.constraint(equalTo: self.viewSubHud.leadingAnchor).isActive = true
        self.lblMessage.trailingAnchor.constraint(equalTo: self.viewSubHud.trailingAnchor).isActive = true
        self.lblMessage.topAnchor.constraint(equalTo: self.imgvHud.bottomAnchor, constant: -3).isActive = true
    }
    
    public func showInViewWithMessage(_ view:UIView, message:String) {
        self.message = message
        self.showInView(view)
    }
    
    public func showInViewWithNavigationBar(_ nav:UINavigationController, message:String) {
        guard let view = nav.view else { return }
        self.message = message
        imgvHud.startAnimating()
        viewHud.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.viewHud)

        self.viewHud.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.viewHud.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.viewHud.topAnchor.constraint(equalTo: view.topAnchor, constant: -64).isActive = true
        self.viewHud.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:0).isActive = true

        self.viewSubHud.translatesAutoresizingMaskIntoConstraints = false
        self.viewHud.addSubview(self.viewSubHud)
        
        self.viewSubHud.centerXAnchor.constraint(equalTo: viewHud.centerXAnchor, constant: 0).isActive = true
        self.viewSubHud.centerYAnchor.constraint(equalTo: viewHud.centerYAnchor, constant: 0).isActive = true
        self.viewSubHud.heightAnchor.constraint(equalToConstant: hSubHud).isActive = true
        self.viewSubHud.widthAnchor.constraint(equalToConstant: wSubHud).isActive = true
        
        self.imgvHud.translatesAutoresizingMaskIntoConstraints = false
        self.viewSubHud.addSubview(self.imgvHud)
        
        if self.message.isEmpty {
            imgvHud.centerYAnchor.constraint(equalTo: viewSubHud.centerYAnchor).isActive = true
        } else {
            imgvHud.topAnchor.constraint(equalTo: viewSubHud.topAnchor, constant: 12).isActive = true
        }
        imgvHud.centerXAnchor.constraint(equalTo: viewSubHud.centerXAnchor, constant: 0).isActive = true
        
        self.lblMessage.translatesAutoresizingMaskIntoConstraints = false
        self.viewSubHud.addSubview(self.lblMessage)
        self.lblMessage.text = self.message
        self.lblMessage.bottomAnchor.constraint(equalTo: self.viewSubHud.bottomAnchor, constant: -3).isActive = true
        self.lblMessage.leadingAnchor.constraint(equalTo: self.viewSubHud.leadingAnchor).isActive = true
        self.lblMessage.trailingAnchor.constraint(equalTo: self.viewSubHud.trailingAnchor).isActive = true
        self.lblMessage.topAnchor.constraint(equalTo: self.imgvHud.bottomAnchor, constant: -3).isActive = true
    }
    
    public func hide() -> Void {
        self.imgvHud.stopAnimating()
        self.viewHud.removeFromSuperview()
    }
}
