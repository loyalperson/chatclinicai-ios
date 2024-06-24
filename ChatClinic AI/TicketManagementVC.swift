//
//  TicketManagement.swift
//  ChatClinic AI
//
//  Created by charmer on 6/13/24.
//
import UIKit
import MessageUI
import Toast_Swift
import KRProgressHUD
import Alamofire

class TicketManagementVC: UIViewController, MFMailComposeViewControllerDelegate {
    var ticketTab: TicketTab? = nil
    var ticket: Ticket? = nil
    var callbackTicketManagementFinished : ((Ticket)->())?

    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var label_email: UILabel!
    @IBOutlet weak var label_details: UITextView!
    @IBOutlet weak var btn_mark: UIButton!
    @IBOutlet weak var view_status: UIView!
    @IBOutlet weak var label_referId: UILabel!
    @IBOutlet weak var label_status: UILabel!
    @IBOutlet weak var view_mail: HighlightView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view_mail.layer.shadowColor = UIColor.darkGray.cgColor
        view_mail.layer.shadowOpacity = 0.5
        view_mail.layer.shadowOffset = CGSizeMake(3.0, 3.0);
        view_mail.layer.shadowRadius = 3

        btn_mark.layer.shadowColor = UIColor.darkGray.cgColor
        btn_mark.layer.shadowOpacity = 0.5
        btn_mark.layer.shadowOffset = CGSizeMake(3.0, 3.0);
        btn_mark.layer.shadowRadius = 3

        let gestureMail = UITapGestureRecognizer(target: self, action:  #selector(self.goMail))
        self.view_mail.addGestureRecognizer(gestureMail)
        loadTicket()
    }
    @objc func goMail(sender : UITapGestureRecognizer) {
        // Do what you want
        var recipientEmail = [String]()
        recipientEmail.append(ticket!.email)
        let subject = "Reply for ticket #" + ticket!.referenceId
        let body = "Hello, " + ticket!.name
        
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
    private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
            return gmailUrl
        } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
            return outlookUrl
        } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
            return yahooMail
        } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
            return sparkUrl
        }
        
        return defaultUrl
    }
            
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    func loadTicket() {
        label_referId.text = ticket?.referenceId
        label_name.text = ticket?.name
        label_email.text = ticket?.email
        label_details.text = ticket?.details
        label_status.text = ticket?.status
        if ticket?.status == "Resolved" {
            view_status.backgroundColor = UIColor.systemGreen
            btn_mark.isHidden = true
        } else {
            view_status.backgroundColor = UIColor.systemRed
            btn_mark.isHidden = false
        }
        
    }
    @IBAction func clickBack(_ sender: Any) {
        self.dismissWithCallback()
    }
    func dismissWithCallback() {
        self.callbackTicketManagementFinished!(self.ticket!)
        self.dismiss(animated: true)
    }
    @IBAction func clickMark(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure to resolve the ticket #" + ticket!.referenceId + " ?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style {
                case .default:
                self.resolveTicket()
                alert.dismiss(animated: true)
                break
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            switch action.style {
                case .default:
                alert.dismiss(animated: true)

                break
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    private func resolveTicket() {
        KRProgressHUD.show()
        let token = Utils.readUserDefault(key: "token")
        var clientId: String = ""
        if Utils.cur_user != nil {
            clientId = Utils.cur_user!.clientId
        } else {
            clientId = "vHQb555TdlFOXB79reD8b"
        }
        
        let urlString = "https://app.chatclinicai.com/api/mobile/tickets/" + self.ticket!._id + "/resolve"
        
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")

        AF.request(request).responseJSON {
            (response) in
            KRProgressHUD.dismiss()
            print(response)
            switch response.result {
            case .success(let data):
                print("Success with JSON: \(data)")
                let dict = data as! NSDictionary
                let success = dict.object(forKey: "success") as! Bool
                if success {
                    self.btn_mark.isHidden = true
                    self.label_status.text = "Resolved"
                    self.view_status.backgroundColor = UIColor.systemGreen
                    self.showSuccessAlert()
                    
                } else {
                    let error = dict.object(forKey: "error") as! String
                    self.view.makeToast(error)
                }
                
                break

            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "You resolved the ticket #" + ticket!.referenceId, preferredStyle: .alert)
//        alert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.green
//
//            // Accessing buttons tintcolor :
//        alert.view.tintColor = UIColor.white
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style {
                case .default:
                alert.dismiss(animated: true)
                break
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
            }
        }))
        alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: { action in
            switch action.style {
                case .default:
                alert.dismiss(animated: true)
                self.dismissWithCallback()

                break
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}


