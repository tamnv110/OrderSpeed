//
//  RequestSupportModel.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/17/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import Foundation

struct RequestSupportModel: Codable {
    var idRequest: String?
    var userID: String
    var orderID: String
    var title: String
    var content: String
    var status: String
    var feedback: String
    var userFeedback: String
    var createAt: String
    var feedbackAt: String
    var userName: String
    var userPhone: String
    var isRequest: Bool
    
    enum CodingKeys: String, CodingKey {
        case idRequest
        case userID = "user_id"
        case orderID = "order_id"
        case title
        case content
        case status
        case feedback
        case userFeedback = "user_feedback"
        case createAt = "create_at"
        case feedbackAt = "feedback_at"
        case userName = "user_name"
        case userPhone = "user_phone"
        case isRequest = "isRequest"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userID = try values.decodeIfPresent(String.self, forKey: .userID) ?? ""
        orderID = try values.decodeIfPresent(String.self, forKey: .orderID) ?? ""
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
        content = try values.decodeIfPresent(String.self, forKey: .content) ?? ""
        status = try values.decodeIfPresent(String.self, forKey: .status) ?? ""
        feedback = try values.decodeIfPresent(String.self, forKey: .feedback) ?? ""
        userFeedback = try values.decodeIfPresent(String.self, forKey: .userFeedback) ?? ""
        createAt = try values.decodeIfPresent(String.self, forKey: .createAt) ?? ""
        feedbackAt = try values.decodeIfPresent(String.self, forKey: .feedbackAt) ?? ""
        userName = try values.decodeIfPresent(String.self, forKey: .userName) ?? ""
        userPhone = try values.decodeIfPresent(String.self, forKey: .userPhone) ?? ""
        isRequest = try values.decodeIfPresent(Bool.self, forKey: .isRequest) ?? true
    }
    
    init(_ userID: String, userName: String, userPhone: String, title: String, content: String, orderID: String) {
        self.userID = userID
        self.userName = userName
        self.userPhone = userPhone
        self.orderID = orderID
        self.title = title
        self.content = content
        self.status = "Đang chờ hỗ trợ"
        self.feedback = ""
        self.userFeedback = ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.createAt = formatter.string(from: Date())
        self.feedbackAt = ""
        self.isRequest = true
    }
    
    var dictionary: [String: Any] {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        return (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) ?? [:]
    }
}
