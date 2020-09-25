//
//  Tools.swift
//  KhoNhaDat
//
//  Created by Nguyen Van Tam on 8/4/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

enum OrderFolderName: String {
    case rootOrderProduct = "OrderProduct"
    case rootRequestSupport = "RequestSupport"
    case product = "Product"
    case status = "Status"
    case settings = "Settings"
    case rootBank = "Bank"
    case rootUser = "User"
    case rootSupport = "Support"
    case rootNews = "News"
    case rootProductSite = "ProductSite"
}

extension UIButton {
  func imageToRight() {
      transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
      titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
      imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
  }
}

extension UIView {

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
    
    func addShadow(shadowColor: UIColor, offSet: CGSize, opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat, corners: UIRectCorner, fillColor: UIColor = .white) {
        
        let shadowLayer = CAShapeLayer()
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size).cgPath //1
        shadowLayer.path = cgPath //2
        shadowLayer.fillColor = fillColor.cgColor //3
        shadowLayer.shadowColor = shadowColor.cgColor //4
        shadowLayer.shadowPath = cgPath
        shadowLayer.shadowOffset = offSet //5
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = shadowRadius
        self.layer.addSublayer(shadowLayer)
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
    static let MAX_IMAGES = 3
    static let GOOGLE_SIGN_IN_KEY = "1030282007437-r5ju99j9bjseia8l94as7el140jstn6p.apps.googleusercontent.com"
    static let KEY_INFO_USER = "KEY_INFO_USER"
    
    static let KEY_LOGIN_TYPE = "KEY_LOGIN_TYPE"
    
    static let css = ".contentnews { width: 96%; padding: 2%; text-align: justify; overflow: hidden} h1 { font-size: 52px; } h2 { font-size: 48px; } .date-count {color: #333; font-style: italic} .contentnews img { max-width: 100% !important;height: auto !important} p { font-size: 44px; }"
    
    static let DELIVERY_HOME = DeliveryModel(["name": "Tại nhà", "description": "Giao hàng tại địa chỉ khách hàng nhập", "price": "Tính theo đơn vị giao hàng"], id: "-1")
    
    static let NDT_LABEL = "¥"
    static var TI_GIA_NDT: Double = 0
    static var FEE_SERVICE: Double = 0
    
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

    static func getUserInfo() -> UserBeer? {
        if let user = Tools.getObjectFromDefault(KEY_INFO_USER) as? Data {
            if #available(iOS 12.0, *) {
                do {
                    return try NSKeyedUnarchiver.unarchivedObject(ofClass: UserBeer.self, from: user)
                } catch {
                    
                }
            } else {
                return NSKeyedUnarchiver.unarchiveObject(with: user) as? UserBeer
            }
        }
        return nil
    }
    
    static func removeUserInfo() {
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: KEY_INFO_USER)
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
        var head = ""
        var tail = ""
        if input.contains(".") {
            let split = input.components(separatedBy: ".")
            head = split.first ?? ""
            tail = split.last ?? ""
        } else {
            head = input
        }
        let sResult = head.replacingOccurrences(of: ",", with: "")
        var arrResult = Array(sResult)
        let nCount = arrResult.count
        var index = 0
        for i in (0..<nCount).reversed() {
            index += 1
            if index%3 == 0 && i - 1 >= 0{
                arrResult.insert(",", at: i)
            }
        }
        let result = String(arrResult) + (tail.isEmpty ? "" : ".\(tail)")
        return result
    }
    
    static func randomOrderCode() -> String {
        let random = Int.random(in: 100000..<1000000)
        return "DH\(random)"
    }
    
    static func openMessengerApp(_ userID: String) {
        if let url = URL(string: "fb-messenger://user-thread/\(userID)") {

            // Attempt to open in Messenger App first
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: {
                    (success) in
                    if success == false {
                        let url = URL(string: "https://m.me/\(userID)")
                        if UIApplication.shared.canOpenURL(url!) {
                            UIApplication.shared.open(url!)
                        }
                    }
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    static func makePhoneCall(_ phone: String) {
        guard let url = URL(string: "tel://\(phone)") else { return }
        if UIApplication.shared.canOpenURL(url) {
           if #available(iOS 10, *) {
             UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
