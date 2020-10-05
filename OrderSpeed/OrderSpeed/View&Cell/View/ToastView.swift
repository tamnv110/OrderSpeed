//
//  ToastView.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/30/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class ToastView: UIView {
    var lblContent: UILabel!
        
    public convenience init(_ view:UIView) {
        self.init()
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        lblContent = UILabel()
        lblContent.textColor = .white
        lblContent.font = UIFont.systemFont(ofSize: 15)
        clipsToBounds = true
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        lblContent.textColor = .white
        lblContent.font = UIFont.systemFont(ofSize: 15)
        lblContent.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lblContent)
        lblContent.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
        lblContent.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32).isActive = true
        lblContent.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        lblContent.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    func showMessage(_ message: String, inView: UIView) {
        lblContent.text = message
        self.translatesAutoresizingMaskIntoConstraints = false
        inView.addSubview(self)
        inView.bringSubviewToFront(self)
        self.bottomAnchor.constraint(equalTo: inView.layoutMarginsGuide.bottomAnchor, constant: -8).isActive = true
        self.centerXAnchor.constraint(equalTo: inView.centerXAnchor).isActive = true
    }
}
