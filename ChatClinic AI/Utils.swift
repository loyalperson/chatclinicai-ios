//
//  Utils.swift
//  ChatClinic AI
//
//  Created by charmer on 6/3/24.
//

import Foundation
import UIKit

class Utils {
    static var cur_user: User? = nil
    static var cur_page: Int? = 0 // 0 message tab, 1 chat page
    static func shakeView(view:UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))

        view.layer.add(animation, forKey: "position")
    }
    static func getISOStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateStr = dateFormatter.string(from:date)
        return dateStr
    }
    static func getDateFromString(isoDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = dateFormatter.date(from:isoDate)!
        return date
    }
    static func getDateStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyy"
        let year = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "M"
        let month = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "d"
        let day = dateFormatter.string(from: date)
        let str = month + "/" + day + "/" + year
        
        // getTodaystring
        let today = Date()
        let year1 = dateFormatter.string(from: today)
        dateFormatter.dateFormat = "M"
        let month1 = dateFormatter.string(from: today)
        dateFormatter.dateFormat = "d"
        let day1 = dateFormatter.string(from: today)
        let todayStr = month1 + "/" + day1 + "/" + year1
        
        // getYesterdaystring
        let yesterday = Date.yesterday
        let year2 = dateFormatter.string(from: yesterday)
        dateFormatter.dateFormat = "M"
        let month2 = dateFormatter.string(from: yesterday)
        dateFormatter.dateFormat = "d"
        let day2 = dateFormatter.string(from: yesterday)
        let yesterdayStr = month2 + "/" + day2 + "/" + year2
        
        if str == todayStr {
            return "Today"
        } else if str == yesterdayStr {
            return "Yesterday"
        } else {
            return str
        }
    }
    static func getTimeStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH"
        let hour = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "mm"
        let minute = dateFormatter.string(from: date)
        let str = hour + ":" + minute
        return str
    }
    static func getWeekdayFromDate(date: Date) -> String{
        let dateStr: String = getDateStringFromDate(date: date)
        if !dateStr.contains("/") {
            return dateStr
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: date)
        return weekDay
    }
    static func isMinuteDifferentBetweenDates(oldDate: Date, newDate: Date) -> Bool {
        let oldTimeStr: String = getTimeStringFromDate(date: oldDate)
        let newTimeStr: String = getTimeStringFromDate(date: newDate)
        if oldTimeStr == newTimeStr {
            return false
        }
        return true
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    static func generateColorFor(text: String) -> UIColor{
        var hash = 0
        let colorConstant = 131
        let maxSafeValue = Int.max / colorConstant
        for char in text.unicodeScalars{
            if hash > maxSafeValue {
                hash = hash / colorConstant
            }
            hash = Int(char.value) + ((hash << 5) - hash)
        }
        let finalHash = abs(hash) % (256*256*256);
        //let color = UIColor(hue:CGFloat(finalHash)/255.0 , saturation: 0.40, brightness: 0.75, alpha: 1.0)
        let color = UIColor(red: CGFloat((finalHash & 0xFF0000) >> 16) / 255.0, green: CGFloat((finalHash & 0xFF00) >> 8) / 255.0, blue: CGFloat((finalHash & 0xFF)) / 255.0, alpha: 1.0)
        return color
    }
    static func getAvatarSymbolByName(name: String) -> String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: name) {
             formatter.style = .abbreviated
             return formatter.string(from: components)
        }
        return ""
    }
    
    static func setUserDefaultBool(key:String, value:Bool) {
            UserDefaults.standard.set(value, forKey: key)
        }
    static func readUserDefaultBool(key:String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    static func setUserDefaultInt(key:String, value:Int) {
        UserDefaults.standard.set(value, forKey: key)
    }
    static func readUserDefaultInt(key:String) -> Int {
        return UserDefaults.standard.integer(forKey: key)
    }
    static func setUserDefault(key:String, value:String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    static func readUserDefault(key:String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }
    static func deleteUserDefault(key:String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    static func deleteAllUserDefaults() {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
    static func setColoredTextLabel(fullText: String, subText: String, label: UILabel, normalColor: UIColor, subColor: UIColor) {
        var range = (fullText.lowercased() as NSString).range(of: subText.lowercased())
        if range.length > 0 {
            var attributedString = NSMutableAttributedString(string:fullText)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: subColor , range: range)
            label.attributedText = attributedString
        } else {
            label.text = fullText
            label.textColor = normalColor
        }
    }
    
    static func saveToDocuments(image: UIImage, name: String, ext: String) throws -> URL
    {
        let imageFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageURL = imageFolder.appendingPathComponent(name + "." + ext)
        let jpegData = image.jpegData(compressionQuality: 0.5)
        try jpegData?.write(to: imageURL, options: .atomic)
        return imageURL
    }
    static func getCurrentTimestamp() -> Int64 {
        return Date().millisecondsSince1970
    }
}
extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
