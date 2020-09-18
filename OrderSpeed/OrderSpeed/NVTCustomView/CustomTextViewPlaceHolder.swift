//
//  CustomTextViewPlaceHolder.swift
//  BookFun
//
//  Created by Tâm Nguyễn on 12/16/19.
//  Copyright © 2019 SeeWide. All rights reserved.
//

import UIKit

protocol CustomTextViewDelegate {
    func customTextViewEndEditting(_ textView: UITextView)
}

@IBDesignable class CustomTextViewPlaceHolder: UITextView {
    var customDelegate: CustomTextViewDelegate?
    @IBInspectable public var placeholder: String? {
        get {
            var placeholderText: String?

            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }

            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height

            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        placeholderLabel.numberOfLines = 3
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()

        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100

        placeholderLabel.isHidden = self.text.count > 0

        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        self.delegate = self
    }
    
    override var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    func addBottomLine() {
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(red: 208.0/255.0, green: 208.0/255.0, blue: 208.0/255.0, alpha: 1)
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bottomLine)

        bottomLine.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        bottomLine.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bottomLine.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        bottomLine.heightAnchor.constraint(equalToConstant: 10).isActive = true
    }
}

extension CustomTextViewPlaceHolder : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        customDelegate?.customTextViewEndEditting(textView)
    }
}
