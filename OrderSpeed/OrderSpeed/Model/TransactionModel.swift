//
//  TransactionModel.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 23/12/2020.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import Foundation

struct TransactionModel: Codable {
    var idTransaction: String?
    var userCode: String
    var userID: String
    var updateAt: String
    var createAt: String
    var content: String
    var code: String
    var money: Double
    var balance: Double?
    var status: Int
    var type: Int
    
    enum CodingKeys: String, CodingKey {
        case userCode = "user_code"
        case userID = "user_id"
        case updateAt = "updated_at"
        case createAt = "created_at"
        case content
        case code
        case money
        case balance
        case status
        case type
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userCode = try values.decodeIfPresent(String.self, forKey: .userCode) ?? ""
        userID = try values.decodeIfPresent(String.self, forKey: .userID) ?? ""
        updateAt = try values.decodeIfPresent(String.self, forKey: .updateAt) ?? ""
        createAt = try values.decodeIfPresent(String.self, forKey: .createAt) ?? ""
        content = try values.decodeIfPresent(String.self, forKey: .content) ?? ""
        code = try values.decodeIfPresent(String.self, forKey: .code) ?? ""
        money = try values.decodeIfPresent(Double.self, forKey: .money) ?? 0
        balance = try values.decodeIfPresent(Double.self, forKey: .balance) ?? 0
        status = try values.decodeIfPresent(Int.self, forKey: .status) ?? 0
        type = try values.decodeIfPresent(Int.self, forKey: .type) ?? 0
    }
}
