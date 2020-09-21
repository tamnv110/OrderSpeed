//
//  BankInfoModel.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/21/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import Foundation

struct BankInfoModel: Codable {
    var ownerName: String
    var bankName: String
    var accountNumber: String
    var bankBranch: String
    
    enum CodingKeys: String, CodingKey {
        case ownerName = "owner_name"
        case bankName = "name"
        case accountNumber = "account_number"
        case bankBranch = "branch"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        ownerName = try values.decodeIfPresent(String.self, forKey: .ownerName) ?? ""
        bankName = try values.decodeIfPresent(String.self, forKey: .bankName) ?? ""
        accountNumber = try values.decodeIfPresent(String.self, forKey: .accountNumber) ?? ""
        bankBranch = try values.decodeIfPresent(String.self, forKey: .bankBranch) ?? ""
    }
    
    init(_ ownerName: String, bankName: String, accountNumber: String, bankBranch: String) {
        self.ownerName = ownerName
        self.bankName = bankName
        self.accountNumber = accountNumber
        self.bankBranch = bankBranch
    }
    
    var dictionary: [String: Any] {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        return (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) ?? [:]
    }
}
