//
//  OrderStatusModel.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/18/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import Foundation

struct OrderStatusModel: Codable {
    var statusID: String?
    var message: String
    var name: String
    var slug: String
    var sort: Int
    var createAt: String
    
    enum CodingKeys: String, CodingKey {
        case message
        case name
        case slug
        case sort
        case createAt = "create_at"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decodeIfPresent(String.self, forKey: .message) ?? ""
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        slug = try values.decodeIfPresent(String.self, forKey: .slug) ?? ""
        sort = try values.decodeIfPresent(Int.self, forKey: .sort) ?? 0
        createAt = try values.decodeIfPresent(String.self, forKey: .createAt) ?? ""
    }
    
    init(_ message: String, name: String, slug: String, sort: Int) {
        self.message = message
        self.name = name
        self.slug = slug
        self.sort = sort
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.createAt = formatter.string(from: Date())
    }
    
    var dictionary: [String: Any] {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        return (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) ?? [:]
    }
}
