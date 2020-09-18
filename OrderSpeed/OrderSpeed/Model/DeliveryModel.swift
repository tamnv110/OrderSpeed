//
//  DeliveryModel.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/16/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import Foundation

struct DeliveryModel {
    var id: String
    var name: String
    var desc: String
    var price: String
    
    init(_ dict: [String: Any], id: String) {
        self.id = id
        name = (dict["name"] as? String) ?? ""
        desc = (dict["description"] as? String) ?? ""
        price = (dict["price"] as? String) ?? ""
    }
}
