//
//  BottomLineTextFiled.swift
//  KhoNhaDat
//
//  Created by Nguyen Van Tam on 8/7/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

@IBDesignable class BottomLineTextField: UITextField {

    let bottomLine = UIView()
    
    var isChecked = true {
        didSet {
            let color = isChecked ? UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1) : UIColor.red
            bottomLine.backgroundColor = color
            if !isChecked {
                shakeAnimationTextField()
            }
        }
    }
    
    var isAddRightView = false {
        didSet {
            if isAddRightView {
                let imgvIcon = UIImageView(frame: CGRect(x: self.bounds.width - 40, y: 0, width: 40, height: 40))
                imgvIcon.image = UIImage(named: "icon_eye")
                imgvIcon.isUserInteractionEnabled = true
                imgvIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(eventChooseTapRightView(_:))))
                self.rightView = imgvIcon
                self.rightViewMode = .always
            } else {
                self.rightView = nil
                self.rightViewMode = .never
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addBottomLine()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addBottomLine()
    }
    
    override func prepareForInterfaceBuilder() {
        addBottomLine()
    }
    
    func addBottomLine() {
        borderStyle = .none
        bottomLine.tag = 100
        bottomLine.backgroundColor = UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1)
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bottomLine)
        bottomLine.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomLine.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomLine.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    @objc func eventChooseTapRightView(_ gesture: UITapGestureRecognizer) {
        isSecureTextEntry = !isSecureTextEntry
    }
}
