//
//  LoginVC.swift
//  ChatClinic AI
//
//  Created by charmer on 6/3/24.
//

import UIKit
import Toast_Swift
import KRProgressHUD
import Alamofire
import GoogleSignIn
//import MSAL

class LoginVC: UIViewController {
    
    @IBOutlet weak var view_google: HighlightView!
    @IBOutlet weak var view_outlook: HighlightView!
    @IBOutlet weak var img_password: UIImageView!
    @IBOutlet weak var btn_visible: UIButton!
    @IBOutlet weak var edit_password: UITextField!
    @IBOutlet weak var edit_email: UITextField!
    @IBOutlet weak var btn_signin: UIButton!
    @IBOutlet weak var img_email: UIImageView!
    @IBOutlet weak var view_email: UIView!
    @IBOutlet weak var view_password: UIView!
    
//    var applicationContext : MSALPublicClientApplication?
//    var webViewParamaters : MSALWebviewParameters?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let gestureGoogle = UITapGestureRecognizer(target: self, action:  #selector(self.googleLogin))
        self.view_google.addGestureRecognizer(gestureGoogle)
        let gestureOutlook = UITapGestureRecognizer(target: self, action:  #selector(self.outlookLogin))
        self.view_outlook.addGestureRecognizer(gestureOutlook)
        btn_visible.tag = 0
        
        btn_signin.layer.shadowColor = UIColor.darkGray.cgColor
        btn_signin.layer.shadowOpacity = 0.5
        btn_signin.layer.shadowOffset = CGSizeMake(3.0, 3.0);
        btn_signin.layer.shadowRadius = 3
        
        // outlook auth
//        do {
//                try self.initMSAL()
//            } catch let error {
//                self.view.makeToast("Outlook authentication error: \(error)")
//            }
    }
//    func initMSAL() throws {
//
//        guard let authorityURL = URL(string: Constants.kAuthority) else {
//            
//            self.view.makeToast("Unable to create authority URL for Outlook")
//            return
//        }
//
//        let authority = try MSALCIAMAuthority(url: authorityURL)
//
//        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: Constants.kClientID, redirectUri: Constants.kRedirectUri,
//                                                                  authority: authority)
//        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
//    }
    override func viewDidAppear(_ animated: Bool) {
        let token: String = Utils.readUserDefault(key: "token")
        if token.count > 0 {
            self.getMyProfile(token: token)
        }
    }
    private func signIn(email: String, password: String) {
//        goToTabBarPage()
//        return
        
        KRProgressHUD.show()
        
        var deviceToken = Utils.readUserDefault(key: "device_token")
        if deviceToken == "" {
            deviceToken = "123"
        }

        let urlString = "https://app.chatclinicai.com/api/mobile/auth/login"
        let json = "{\"email\":\"\(email)\", \"password\":\"\(password)\", \"deviceToken\":\"\(deviceToken)\"}"

        let url = URL(string: urlString)!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
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
                    let token = res.object(forKey: "token")!
                
                    print(token)
//                    Utils.setUserDefault(key: "token", value: token as! String )
//                    self.goToTabBarPage()
                    self.getMyProfile(token: token as! String)
                } else {
//                    let error = res.object(forKey: "error")!
                    Utils.deleteUserDefault(key: "token")
                    self.view.makeToast("Error occured")
//                    print(error)
                }
                
                break

            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }

//        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
//           KRProgressHUD.dismiss()
//        }
        
    }
    private func getMyProfile(token: String) {
        KRProgressHUD.show()

        let urlString = "https://app.chatclinicai.com/api/mobile/profile"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")

        AF.request(request).responseJSON {
            (response) in
            KRProgressHUD.dismiss()
            print(response)
            switch response.result {
            case .success(let JSON):
                print("Success with JSON: \(JSON)")
                let dict = JSON as! NSDictionary
                let success = dict.object(forKey: "success") as! Bool
                if success {
                    Utils.cur_user = User.init(dict: dict.object(forKey: "user") as! NSDictionary)
                    Utils.setUserDefault(key: "token", value: token )
                    self.goToTabBarPage()
                } else {
                    let error: String = dict.object(forKey: "error") as! String
                    self.view.makeToast(error)
                }
                break

            case .failure(let error):
                self.view.makeToast(error as! String)
                print("Request failed with error: \(error)")
            }
        }
    }
    private func socialSignIn(email: String) {
        KRProgressHUD.show()
        var deviceToken = Utils.readUserDefault(key: "device_token")
        if deviceToken == "" {
            deviceToken = "123"
        }
        
        let urlString = "https://app.chatclinicai.com/api/mobile/auth/login_social"
        let json = "{\"email\":\"\(email)\", \"deviceToken\":\"\(deviceToken)\"}"

        let url = URL(string: urlString)!
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
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
                    let token = res.object(forKey: "token")!
                    
                    Utils.setUserDefault(key: "token", value: token as! String)
                    self.goToTabBarPage()
                    print(token)
                } else {
                    let error = res.object(forKey: "error")!
                    Utils.deleteUserDefault(key: "token")
                    self.view.makeToast(error as! String)
                    print(error)
                }
                
                break

            case .failure(let error):
                self.view.makeToast("We are sorry to make you incovenience. Server has got a minor issue.\nPlease try again later.")
                print("Request failed with error: \(error)")
            }
        }

//        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
//           KRProgressHUD.dismiss()
//        }
        
    }
        
    
    @objc func googleLogin(sender : UITapGestureRecognizer) {
        // Do what you want
        view_google.isUserInteractionEnabled = false
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else {
                self.view_google.isUserInteractionEnabled = true
                return
            }

          // If sign in succeeded, display the app's main content View.
            guard let signInResult = signInResult else { return }
            let user = signInResult.user

            let emailAddress = user.profile?.email
            self.view_google.isUserInteractionEnabled = true
            self.socialSignIn(email: emailAddress!)
        }
    }
    @objc func outlookLogin(sender : UITapGestureRecognizer) {
        // Do what you want
        /*
        view_outlook.isUserInteractionEnabled = false
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }

//        updateLogging(text: "Acquiring token interactively...")

        let parameters = MSALInteractiveTokenParameters(scopes: Constants.kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount

        applicationContext.acquireToken(with: parameters) { (result, error) in

            if let error = error {
//                self.view.makeToast(error)
//                self.updateLogging(text: "Could not acquire token: \(error)")
                return
            }

            guard let result = result else {

//                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }

//            self.accessToken = result.accessToken
            self.view.makeToast("Access token is \(result.accessToken)")
//            self.updateCurrentAccount(account: result.account)
//            let emailAddress = result.
//            self.view_outlook.isUserInteractionEnabled = true
//            self.socialSignIn(email: emailAddress!)
        }
         */
    }
    
    @IBAction func clickSignin(_ sender: Any) {
        let email:String = edit_email.text!.trimmingCharacters(in: .whitespaces)
        if !Utils.isValidEmail(email) {
            self.view.makeToast("Invalid email address!")
            Utils.shakeView(view: view_email)
            return
        }
        let password:String = edit_password.text!
        if password.count == 0 {
            self.view.makeToast("Please input password!")
            Utils.shakeView(view: view_password)
            return
        }
        signIn(email: email, password: password)
    }
    func goToTabBarPage() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarC") as! MainTabBarController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
    }
    @IBAction func clickPasswordVisible(_ sender: Any) {
        if btn_visible.tag == 0 {
            btn_visible.setImage(UIImage(named: "ic_password_invisible"), for: UIControl.State.normal)
            btn_visible.tag = 1
            edit_password.isSecureTextEntry = false
        } else {
            btn_visible.setImage(UIImage(named: "ic_password_visible"), for: UIControl.State.normal)
            btn_visible.tag = 0
            edit_password.isSecureTextEntry = true
        }
        
    }
    func setUpImageTintColor() {
        img_password.tintColor = Constants.darkGrayColor
        img_email.tintColor = Constants.darkGrayColor
    }
}
