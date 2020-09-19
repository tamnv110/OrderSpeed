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
    let colorLine = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1)
    var customDelegate: CustomTextViewDelegate?
    var bottomLine = UIView()
    
    var isChecked = true {
        didSet {
            let color = isChecked ? colorLine : UIColor.red
            bottomLine.backgroundColor = color
            if !isChecked {
                shakeAnimationTextField()
            }
        }
    }
    
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
            self.addBottomLine()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addBottomLine()
    }
    
    override func prepareForInterfaceBuilder() {
        addBottomLine()
    }
    
    func addBottomLine() {
        bottomLine.frame = CGRect(x: 0, y: self.bounds.height - 1, width: self.bounds.width, height: 1)
        bottomLine.tag = 101
        bottomLine.backgroundColor = colorLine
        if self.viewWithTag(101) == nil {
            self.addSubview(bottomLine)
        }
    }
}

extension CustomTextViewPlaceHolder : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = self.text.count > 0
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        isChecked = true
        return isChecked
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        customDelegate?.customTextViewEndEditting(textView)
    }
}
