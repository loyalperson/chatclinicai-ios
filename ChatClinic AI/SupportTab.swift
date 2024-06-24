//
//  SupportVC.swift
//  ChatClinic AI
//
//  Created by charmer on 6/4/24.
//

import UIKit
import Toast_Swift
import MessageUI
import Toast_Swift

class SupportTab: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var img_support: UIImageView!
    var mainTab: MainTabBarController? = nil
    
    let str1: String = "We support technical problems in "
    let str2: String = "If you have any problem, please email to "
    let email: String = "hello@chatclinicai.com"
    @IBOutlet weak var btn_go: UIButton!
    let company: String = "ChatClinic AI"

    @IBOutlet weak var label_text2: UILabel!
    @IBOutlet weak var label_text1: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var image = UIImage(named: "ic_support3.png")!.withRenderingMode(.alwaysTemplate)
        img_support.image = image
        img_support.tintColor = UIColor.darkGray
        
        btn_go.layer.shadowColor = UIColor.darkGray.cgColor
        btn_go.layer.shadowOpacity = 0.5
        btn_go.layer.shadowOffset = CGSizeMake(3.0, 3.0);
        btn_go.layer.shadowRadius = 3
        
//        var main_string = "Hello World"
//        var string_to_color = "support"
//
//        var range = (str1 as NSString).range(of: string_to_color)
//        var attributedString = NSMutableAttributedString(string:str1)
//        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemYellow , range: range)
//        label_text1.attributedText = attributedString
    }
    @IBAction func goToMail(_ sender: Any) {
       
            // Do what you want
            var recipientEmail = [String]()
            recipientEmail.append(email)
            let subject = "I need a support"
            let body = ""
            
            // Show default mail composer
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(recipientEmail)
                mail.setSubject(subject)
                mail.setMessageBody(body, isHTML: false)
                
                present(mail, animated: true)
            
            // Show third party email composer if default Mail app is not present
            } else {
                self.view.makeToast("Please setup email on your device")
            }
    }
//    func configureSupportText() {
//        
//        let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)]
//        let emailString = NSMutableAttributedString(string:email, attributes:attrs1)
//
//        let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)]
//        let str2String = NSMutableAttributedString(string:str2, attributes:attrs2)
//        
//        str2String.append(emailString)
//
//        label_text2.attributedText = str2String
//    }
}
