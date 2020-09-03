//
//  Tools.swift
//  KhoNhaDat
//
//  Created by Nguyen Van Tam on 8/4/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

extension UITextField {
    func shakeAnimationTextField() {
        let midX = self.center.x
        let midY = self.center.y
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: midX - 5, y: midY)
        animation.toValue = CGPoint(x: midX + 5, y: midY)
        self.layer.add(animation, forKey: "position")
        
        self.layer.borderColor = UIColor.red.cgColor
    }
}

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}

class Tools {
    static let GOOGLE_SIGN_IN_KEY = "1030282007437-r5ju99j9bjseia8l94as7el140jstn6p.apps.googleusercontent.com"
    static let KEY_INFO_USER = "KEY_INFO_USER"
    
    static let css = ".contentnews { width: 96%; padding: 2%; text-align: justify; overflow: hidden} h1 { font-size: 52px; } h2 { font-size: 48px; } .date-count {color: #333; font-style: italic} .contentnews img { max-width: 100% !important;height: auto !important} p { font-size: 44px; }"
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    static func saveUserInfo(_ user: UserBeer) {
        if #available(iOS 12.0, *) {
            do {
                let encodeData = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: true)
                saveObjectToUserDefault(key: KEY_INFO_USER, value: encodeData)
            } catch{}
        } else {
            let encodeData = NSKeyedArchiver.archivedData(withRootObject: user)
            saveObjectToUserDefault(key: KEY_INFO_USER, value: encodeData)
        }
    }
    
    static func saveObjectToUserDefault(key:String, value:Any?) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
//    static func saveUserInfo(_ user: UserInfo) {
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(user) {
//            let defaults = UserDefaults.standard
//            defaults.set(encoded, forKey: "USER_INFO")
//            defaults.synchronize()
//        } else {
//            debugPrint("Tools - \(#function) - \(#line) - khong encode duoc")
//        }
//    }
//    
//    static func getUserInfo() -> UserInfo? {
//        let defaults = UserDefaults.standard
//        if let savedUser = defaults.object(forKey: "USER_INFO") as? Data {
//            let decoder = JSONDecoder()
//            let user = try? decoder.decode(UserInfo.self, from: savedUser)
//            return user
//        }
//        return nil
//    }
    
    static func removeUserInfo() {
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: "USER_INFO")
        defaults.synchronize()
    }
    
    static func saveObjectToDefault(_ object: Any, key: String) {
        let defaults = UserDefaults.standard
        defaults.set(object, forKey: key)
        defaults.synchronize()
    }
    
    static func getObjectFromDefault(_ key: String) -> Any? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: key)
    }
    
    static func convertDateToString(_ date: Date, dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    static func convertCurrencyFromString(input: String) -> String {
        let sResult = input.replacingOccurrences(of: ",", with: "")
        var arrResult = Array(sResult)
        let nCount = arrResult.count
        var index = 0
        for i in (0..<nCount).reversed() {
            index += 1
            if index%3 == 0 && i - 1 >= 0{
                arrResult.insert(",", at: i)
            }
        }
        return String(arrResult)
    }
}
