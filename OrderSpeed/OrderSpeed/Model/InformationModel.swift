//
//  InformationModel.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/22/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import Foundation

struct InformationModel: Codable {
    var type: Int
    var title: String
    var content: String
    var desc: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case title
        case content
        case desc = "description"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decodeIfPresent(Int.self, forKey: .type) ?? 1
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        content = try values.decodeIfPresent(String.self, forKey: .content) ?? ""
        desc = try values.decodeIfPresent(String.self, forKey: .desc)
    }
}
