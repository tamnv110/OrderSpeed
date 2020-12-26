//
//  User.swift
//  MakeTaskSimple
//
//  Created by Tâm Nguyễn on 4/12/20.
//  Copyright © 2020 Tâm Nguyễn. All rights reserved.
//

import Foundation

class UserBeer: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool {
        return true
    }
    
    var fullname:String
    var email:String
    var userID:String
    var avatar:String
    var phoneNumber: String
    var receiverPhone: String
    var address: String
    var cityName: String
    var districtName: String
    var tokenAPN:String
    var receiverName: String
    var typeAcc: Int
    var totalMoney: Double
    
    private struct NSCoderKeys {
        static let fullNameKey = "fullname"
        static let roleIDKey = "roleID"
        static let emailKey = "email"
        static let userIDKey = "userID"
        static let avatarKey = "avatar"
        static let phoneNumberKey = "phoneNumber"
        static let receiverPhoneKey = "receiverPhone"
        static let addressKey = "address"
        static let cityNameKey = "cityName"
        static let districtNameKey = "districtNameKey"
        static let tokenAPNKey = "tokenAPN"
        static let receiverNameKey = "receiverName"
        static let typeAccKey = "typeAcc"
        static let totalMoneyKey = "totalMoney"
    }
    
    init(id: String, email: String, fullname: String, avatar: String, phoneNumber: String, receiverPhone: String, receiverName: String, address: String, cityName: String, districtName: String, tokenAPN: String, typeAcc: Int, totalMoney: Double) {
        self.userID = id
        self.email = email
        self.fullname = fullname
        self.avatar = avatar
        self.phoneNumber = phoneNumber
        self.receiverPhone = receiverPhone
        self.receiverName = receiverName
        self.address = address
        self.cityName = cityName
        self.districtName = districtName
        self.tokenAPN = tokenAPN
        self.typeAcc = typeAcc
        self.totalMoney = totalMoney
    }
    
    public convenience required init?(coder aDecoder:NSCoder) {
        guard let fullnameTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.fullNameKey) as String? else {
            return nil
        }
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.userIDKey) as String? else {
            return nil
        }
        guard let emailTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.emailKey) as String? else {
            return nil
        }
        guard let avatarTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.avatarKey) as String? else {
            return nil
        }
        guard let receiverNameTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.receiverNameKey) as String? else {
            return nil
        }
        guard let phoneNumberTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.phoneNumberKey) as String? else {
            return nil
        }
        guard let phoneReceiverTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.receiverPhoneKey) as String? else {
            return nil
        }
        guard let addressTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.addressKey) as String? else {
            return nil
        }
        guard let cityNameTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.cityNameKey) as String? else {
            return nil
        }
        guard let districtNameTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.districtNameKey) as String? else {
            return nil
        }
        guard let tokenAPNTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.tokenAPNKey) as String? else {
            return nil
        }
        let typeAccTemp = aDecoder.decodeInteger(forKey: NSCoderKeys.typeAccKey)
        let dMoney = aDecoder.decodeDouble(forKey: NSCoderKeys.totalMoneyKey)
        
        self.init(id: id, email: emailTemp, fullname: fullnameTemp, avatar: avatarTemp, phoneNumber: phoneNumberTemp, receiverPhone: phoneReceiverTemp, receiverName: receiverNameTemp, address: addressTemp, cityName: cityNameTemp, districtName: districtNameTemp, tokenAPN: tokenAPNTemp, typeAcc: typeAccTemp, totalMoney: dMoney)
    }
    
    func encode(with aCoder:NSCoder) -> Void {
        aCoder.encode(userID as NSString, forKey: NSCoderKeys.userIDKey)
        aCoder.encode(email as NSString, forKey: NSCoderKeys.emailKey)
        aCoder.encode(fullname as NSString, forKey: NSCoderKeys.fullNameKey)
        aCoder.encode(avatar as NSString, forKey: NSCoderKeys.avatarKey)
        aCoder.encode(receiverName as NSString, forKey: NSCoderKeys.receiverNameKey)
        aCoder.encode(phoneNumber as NSString, forKey: NSCoderKeys.phoneNumberKey)
        aCoder.encode(receiverPhone as NSString, forKey: NSCoderKeys.receiverPhoneKey  )
        aCoder.encode(address as NSString, forKey: NSCoderKeys.addressKey)
        aCoder.encode(cityName as NSString, forKey: NSCoderKeys.cityNameKey)
        aCoder.encode(districtName as NSString, forKey: NSCoderKeys.districtNameKey)
        aCoder.encode(tokenAPN as NSString, forKey: NSCoderKeys.tokenAPNKey)
        aCoder.encode(typeAcc, forKey: NSCoderKeys.typeAccKey)
        aCoder.encode(totalMoney, forKey: NSCoderKeys.totalMoneyKey)
    }
    
    func showInfo() -> Void {
        debugPrint("UserBeer - \(fullname) - \(email) - \(userID) - \(phoneNumber) - \(receiverName) - \(address) - \(districtName) - \(cityName) - \(typeAcc)")
    }
}
