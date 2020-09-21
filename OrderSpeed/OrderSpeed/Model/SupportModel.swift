//
//  SupportModel.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/17/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import Foundation

struct SupportModel: Codable {
    var account: String
    var name: String
    var phone: String
    
    enum CodingKeys: String, CodingKey {
        case account
        case name
        case phone
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        account = try values.decodeIfPresent(String.self, forKey: .account) ?? ""
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        phone = try values.decodeIfPresent(String.self, forKey: .phone) ?? ""
    }
    
    init(_ account: String, name: String, phone: String) {
        self.account = account
        self.name = name
        self.phone = phone
    }
    
    var dictionary: [String: Any] {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        return (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) ?? [:]
    }
}
