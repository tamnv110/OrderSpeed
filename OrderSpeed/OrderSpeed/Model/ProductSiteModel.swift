//
//  ProductSiteModel.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/25/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import Foundation

struct ProductSiteModel: Codable {
    var image: String
    var link: String
    var name: String
    var sort: Int
    var typeShow: Int?
    
    enum CodingKeys: String, CodingKey {
        case image
        case link
        case name
        case sort
        case typeShow = "type_show"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        image = try values.decode(String.self, forKey: .image)
        link = try values.decode(String.self, forKey: .link)
        name = try values.decode(String.self, forKey: .name)
        sort = try values.decode(Int.self, forKey: .sort)
        typeShow = try values.decodeIfPresent(Int.self, forKey: .typeShow) ?? 0
    }
    
    init(_ name: String, image: String, link: String, sort: Int) {
        self.name = name
        self.image = image
        self.link = link
        self.sort = sort
        self.typeShow = 1
    }
}
