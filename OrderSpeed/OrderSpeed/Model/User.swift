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
    var roleID:String
    var email:String
    var userID:String
    var avatar:String
    var phoneNumber: String
    var address: String
    var cityName: String
    var districtName: String
    var tokenAPN:String
    
    private struct NSCoderKeys {
        static let fullNameKey = "fullname"
        static let roleIDKey = "roleID"
        static let emailKey = "email"
        static let userIDKey = "userID"
        static let avatarKey = "avatar"
        static let phoneNumberKey = "phoneNumber"
        static let addressKey = "address"
        static let cityNameKey = "cityName"
        static let districtNameKey = "districtNameKey"
        static let tokenAPNKey = "tokenAPN"
    }
    
    init(id: String, roleid: String, email: String, fullname: String, avatar: String, phoneNumber: String, address: String, cityName: String, districtName: String, tokenAPN: String) {
        self.userID = id
        self.roleID = roleid
        self.email = email
        self.fullname = fullname
        self.avatar = avatar
        self.phoneNumber = phoneNumber
        self.address = address
        self.cityName = cityName
        self.districtName = districtName
        self.tokenAPN = tokenAPN
    }
    
    public convenience required init?(coder aDecoder:NSCoder) {
        guard let fullnameTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.fullNameKey) as String? else {
            return nil
        }
        guard let id = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.userIDKey) as String? else {
            return nil
        }
        guard let roleIDTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.roleIDKey) as String? else {
            return nil
        }
        guard let emailTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.emailKey) as String? else {
            return nil
        }
        guard let avatarTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.avatarKey) as String? else {
            return nil
        }
        guard let phoneNumberTemp = aDecoder.decodeObject(of: NSString.self, forKey: NSCoderKeys.phoneNumberKey) as String? else {
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
        self.init(id: id, roleid: roleIDTemp, email: emailTemp, fullname: fullnameTemp, avatar: avatarTemp, phoneNumber: phoneNumberTemp, address: addressTemp, cityName: cityNameTemp, districtName: districtNameTemp, tokenAPN: tokenAPNTemp)
    }
    
    func encode(with aCoder:NSCoder) -> Void {
        aCoder.encode(userID as NSString, forKey: NSCoderKeys.userIDKey)
        aCoder.encode(roleID as NSString, forKey: NSCoderKeys.roleIDKey)
        aCoder.encode(email as NSString, forKey: NSCoderKeys.emailKey)
        aCoder.encode(fullname as NSString, forKey: NSCoderKeys.fullNameKey)
        aCoder.encode(avatar as NSString, forKey: NSCoderKeys.avatarKey)
        aCoder.encode(phoneNumber as NSString, forKey: NSCoderKeys.phoneNumberKey)
        aCoder.encode(address as NSString, forKey: NSCoderKeys.addressKey)
        aCoder.encode(cityName as NSString, forKey: NSCoderKeys.cityNameKey)
        aCoder.encode(districtName as NSString, forKey: NSCoderKeys.districtNameKey)
        aCoder.encode(tokenAPN as NSString, forKey: NSCoderKeys.tokenAPNKey)
    }
    
    func showInfo() -> Void {
        debugPrint("UserBeer - \(fullname) - \(email) - \(userID) - \(roleID) - \(phoneNumber)")
    }
}
