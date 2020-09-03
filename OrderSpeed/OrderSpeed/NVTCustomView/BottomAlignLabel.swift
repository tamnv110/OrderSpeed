//
//  BottomAlignLabel.swift
//  KhoNhaDat
//
//  Created by Nguyen Van Tam on 8/4/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

@IBDesignable class BottomAlignLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard text != nil else { return super.drawText(in: rect) }
        let height = self.sizeThatFits(rect.size).height
        let y = rect.origin.y + rect.height - height
        super.drawText(in: CGRect(x: 0, y: y, width: rect.width, height: height))
    }

}
