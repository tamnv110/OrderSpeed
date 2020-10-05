//
//  NotificationModel.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 10/1/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import Foundation

struct NotificationModel: Codable {
    var title: String
    var message: String
    var orderID: String
    var createAt: String
    var watched: Int
    
    enum CodingKeys: String, CodingKey {
        case title
        case message
        case orderID = "order_id"
        case createAt = "create_at"
        case watched
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        message = try values.decodeIfPresent(String.self, forKey: .message) ?? ""
        orderID = try values.decodeIfPresent(String.self, forKey: .orderID) ?? ""
        createAt = try values.decodeIfPresent(String.self, forKey: .createAt) ?? ""
        watched = try values.decodeIfPresent(Int.self, forKey: .watched) ?? 0
    }
}
