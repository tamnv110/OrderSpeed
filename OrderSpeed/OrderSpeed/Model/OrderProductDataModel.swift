//
//  OrderProductDataModel.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/15/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import Foundation
import Firebase

struct ProductModel: Codable {
    var productID: String?
    var code: String
    var link: String
    var name: String
    var option: String
    var amount: Int
    var price: Double
    var fee: Double
    var images: [String]?
    var status: String?
    var note: String
    var arrProductImages: [ItemImageSelect]?
//    var id: Int
//    var link: String
//    var name: String
//    var size: String
//    var note: String
//    var number: Int
//    var price: Double
//    var arrProductImages: [ItemImageSelect]?
    
    enum CodingKeys: String, CodingKey {
        case code
        case link
        case name
        case option
        case amount
        case price
        case fee
        case images
        case status
        case note
        case arrProductImages
    }
    
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decode(String.self, forKey: .code)
        link = try values.decode(String.self, forKey: .link)
        name = try values.decode(String.self, forKey: .name)
        option = try values.decode(String.self, forKey: .option)
        amount = try values.decode(Int.self, forKey: .amount)
        price = try values.decode(Double.self, forKey: .price)
        fee = try values.decode(Double.self, forKey: .fee)
        images = try values.decodeIfPresent([String].self, forKey: .images)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        note = try values.decodeIfPresent(String.self, forKey: .note) ?? ""
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(link, forKey: .link)
        try container.encode(name, forKey: .name)
        try container.encode(option, forKey: .option)
        try container.encode(amount, forKey: .amount)
        try container.encode(price, forKey: .price)
        try container.encode(fee, forKey: .fee)
        try container.encode(images, forKey: .images)
        try container.encode(status, forKey: .status)
        try container.encode(note, forKey: .note)
    }
    
    init(code: String, link: String, name: String, option: String, amount: Int, price: Double, fee: Double, status: String, note: String) {
        self.code = code
        self.link = link
        self.name = name
        self.option = option
        self.amount = amount
        self.price = price
        self.fee = fee
        self.status = status
        self.note = note
    }
    
    var dictionary: [String: Any] {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        return (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) ?? [:]
    }
}

struct OrderProductDataModel: Codable {
    var idOrder: String?
    var code: String
    var status: String
    var productCount: Int
    var shippingMethod: String
    var userID: String
    var cityName: String
    var districtName: String
    
    var receiverAddress: String
    var note: String
    var receiverName: String
    var receiverPhone: String
    var paymentName: String
    var paymentPhone: String
    
    var warehouseName: String
    var warehouseAddress: String
    var warehouseID: String
    
    var currencyLabel: String
    
    var subTotalMoney: Double
    var depositMoney: Double
    var currencyRate: Double
    var serviceCost: Double
    var shippingCost: Double
    
    var createAt: String
    var updateAt: String

    enum CodingKeys: String, CodingKey {
        case idOrder
        case code
        case status
        case productCount = "product_count"
        case shippingMethod = "shipping_method"
        case userID = "user_id"
        case cityName = "city_name"
        case districtName = "district_name"
        case receiverAddress = "receiver_address"
        case note
        case receiverName = "receiver_name"
        case receiverPhone = "receiver_phone"
        case paymentName = "payment_name"
        case paymentPhone = "payment_phone"
        case warehouseName = "warehouse_name"
        case warehouseAddress = "warehouse_address"
        case warehouseID = "warehouse_id"
        case depositMoney = "deposit_money"
        case currencyRate = "currency_rate"
        case serviceCost = "service_cost"
        case shippingCost = "shipping_cost"
        case subTotalMoney = "sub_total"
        case createdAt = "created_at"
        case updateAt = "update_at"
        case currencyLabel = "currency_label"

    }
    
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try (values.decodeIfPresent(String.self, forKey: .code) ?? "")
        status = try (values.decodeIfPresent(String.self, forKey: .status) ?? "")
        productCount = try (values.decodeIfPresent(Int.self, forKey: .productCount) ?? 0)
        shippingMethod = try (values.decodeIfPresent(String.self, forKey: .shippingMethod) ?? "")
        userID = try (values.decodeIfPresent(String.self, forKey: .userID) ?? "")
        cityName = try (values.decodeIfPresent(String.self, forKey: .cityName) ?? "")
        districtName = try (values.decodeIfPresent(String.self, forKey: .districtName) ?? "")
        receiverAddress = try (values.decodeIfPresent(String.self, forKey: .receiverAddress) ?? "")
        note = try (values.decodeIfPresent(String.self, forKey: .note) ?? "")
        receiverName = try (values.decodeIfPresent(String.self, forKey: .receiverName) ?? "")
        receiverPhone = try (values.decodeIfPresent(String.self, forKey: .receiverPhone) ?? "")
        paymentName = try (values.decodeIfPresent(String.self, forKey: .paymentName) ?? "")
        paymentPhone = try (values.decodeIfPresent(String.self, forKey: .paymentPhone) ?? "")
        warehouseName = try (values.decodeIfPresent(String.self, forKey: .warehouseName) ?? "")
        warehouseAddress = try (values.decodeIfPresent(String.self, forKey: .warehouseAddress) ?? "")
        warehouseID = try (values.decodeIfPresent(String.self, forKey: .warehouseID) ?? "")
        
        subTotalMoney = try (values.decodeIfPresent(Double.self, forKey: .subTotalMoney) ?? 0)
        depositMoney = try (values.decodeIfPresent(Double.self, forKey: .depositMoney) ?? 0)
        currencyRate = try (values.decodeIfPresent(Double.self, forKey: .currencyRate) ?? 0)
        serviceCost = try (values.decodeIfPresent(Double.self, forKey: .serviceCost) ?? 0)
        shippingCost = try (values.decodeIfPresent(Double.self, forKey: .shippingCost) ?? 0)
        
        createAt = try (values.decodeIfPresent(String.self, forKey: .createdAt) ?? "")
        updateAt = try (values.decodeIfPresent(String.self, forKey: .updateAt) ?? "")
        currencyLabel = try (values.decodeIfPresent(String.self, forKey: .currencyLabel) ?? "")
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(code, forKey: .code)
        try container.encode(status, forKey: .status)
        try container.encode(productCount, forKey: .productCount)
        try container.encode(shippingMethod, forKey: .shippingMethod)
        try container.encode(userID, forKey: .userID)
        try container.encode(cityName, forKey: .cityName)
        try container.encode(districtName, forKey: .districtName)
        try container.encode(receiverAddress, forKey: .receiverAddress)
        try container.encode(note, forKey: .note)
        try container.encode(receiverName, forKey: .receiverName)
        try container.encode(receiverPhone, forKey: .receiverPhone)
        try container.encode(paymentName, forKey: .paymentName)
        try container.encode(paymentPhone, forKey: .paymentPhone)
        try container.encode(warehouseName, forKey: .warehouseName)
        try container.encode(warehouseAddress, forKey: .warehouseAddress)
        try container.encode(warehouseID, forKey: .warehouseID)
        try container.encode(subTotalMoney, forKey: .subTotalMoney)
        try container.encode(depositMoney, forKey: .depositMoney)
        try container.encode(currencyRate, forKey: .currencyRate)
        try container.encode(serviceCost, forKey: .serviceCost)
        try container.encode(shippingCost, forKey: .shippingCost)
        try container.encode(createAt, forKey: .createdAt)
        try container.encode(updateAt, forKey: .updateAt)
        try container.encode(currencyLabel, forKey: .currencyLabel)
    }
    
    init(code: String, status: String, productCount: Int, shippingMethod: String, userID: String, cityName: String, districtName: String, receiverAddress: String, note: String, receiverName: String, receiverPhone: String, paymentName: String, paymentPhone: String, warehouseName: String, warehouseAddress: String, warehouseID: String, subTotalMoney: Double, depositMoney: Double, currentcyRate: Double, serviceCost: Double, shippingCost: Double, createAt: String, updateAt: String, currencyLabel: String) {
        self.code = code
        self.status = status
        self.productCount = productCount
        self.shippingMethod = shippingMethod
        self.userID = userID
        self.cityName = cityName
        self.districtName = districtName
        self.receiverAddress = receiverAddress
        self.note = note
        self.receiverName = receiverName
        self.receiverPhone = receiverPhone
        self.paymentName = paymentName
        self.paymentPhone = paymentPhone
        self.warehouseName = warehouseName
        self.warehouseAddress = warehouseAddress
        self.warehouseID = warehouseID
        self.subTotalMoney = subTotalMoney
        self.depositMoney = depositMoney
        self.currencyRate = currentcyRate
        self.serviceCost = serviceCost
        self.shippingCost = shippingCost
        self.createAt = createAt
        self.updateAt = updateAt
        self.currencyLabel = currencyLabel
    }
    
    var dictionary: [String: Any] {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        return (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) ?? [:]
    }
}
