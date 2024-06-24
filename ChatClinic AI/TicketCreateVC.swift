//
//  TicketCreateVC.swift
//  ChatClinic AI
//
//  Created by charmer on 6/16/24.
//

import UIKit
import Toast_Swift
import KRProgressHUD
import Alamofire

class TicketCreateVC: UIViewController {
    var chatRoom: ChatRoom? = nil
    @IBOutlet weak var edit_details: UITextView!
    @IBOutlet weak var view_name: UIView!
    @IBOutlet weak var view_email: UIView!
    @IBOutlet weak var edit_email: UITextField!
    @IBOutlet weak var view_details: UIView!
    @IBOutlet weak var btn_create: UIButton!
    @IBOutlet weak var edit_name: UITextField!
    var callbackTicketCreateFinished : ((String)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btn_create.layer.shadowColor = UIColor.darkGray.cgColor
        btn_create.layer.shadowOpacity = 0.5
        btn_create.layer.shadowOffset = CGSizeMake(3.0, 3.0);
        btn_create.layer.shadowRadius = 3
        
        if self.chatRoom != nil {
            edit_name.text = chatRoom?.name
            edit_email.text = chatRoom?.email
        }
    }
    @IBAction func clickBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func clickCreate(_ sender: Any) {
        let name: String = edit_name.text!.trimmingCharacters(in: .whitespaces)
        if name.count == 0 {
            self.view.makeToast("Please input name!")
            Utils.shakeView(view: view_name)
            return
        }
        let email:String = edit_email.text!.trimmingCharacters(in: .whitespaces)
        if email.count == 0 {
            self.view.makeToast("Please input name!")
            Utils.shakeView(view: view_email)
            return
        } else if !Utils.isValidEmail(email) {
            self.view.makeToast("Invalid email address!")
            Utils.shakeView(view: view_email)
            return
        }
        let details: String = edit_details.text!.trimmingCharacters(in: .whitespaces)
        if details.count == 0 {
            self.view.makeToast("Please input details!")
            Utils.shakeView(view: view_details)
            return
        }
        KRProgressHUD.show()
        
        let token = Utils.readUserDefault(key: "token")

        let urlString = "https://app.chatclinicai.com/api/mobile/tickets/create"
        let json = "{\"email\":\"\(email)\", \"name\":\"\(name)\", \"details\":\"\(details)\"}"

        let url = URL(string: urlString)!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        AF.request(request).responseJSON {
            (response) in
            KRProgressHUD.dismiss()
            print(response)
            switch response.result {
            case .success(let JSON):
                print("Success with JSON: \(JSON)")
                let res = JSON as! NSDictionary

                //example if there is an id
                let success = res.object(forKey: "success")! as! Bool
                if success == true {
                    
                    self.callbackTicketCreateFinished!("Ticket has been created successfully")
                    self.dismiss(animated: true)

                } else {
//                    let error = res.object(forKey: "error")!
                    
                    self.view.makeToast("Error occured")
//                    print(error)
                }
                
                break

            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
}
