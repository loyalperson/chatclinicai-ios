//
//  SupportVC.swift
//  ChatClinic AI
//
//  Created by charmer on 6/4/24.
//

import UIKit
import Toast_Swift

class SettingsTab: UIViewController {
    var mainTab: MainTabBarController? = nil
    @IBOutlet weak var label_avatar: UILabel!
    @IBOutlet weak var view_avatar: UIView!
    @IBOutlet weak var view_logoff: HighlightView!
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var label_email: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    func loadInfo() {
        let name = Utils.cur_user?.name
        view_avatar.backgroundColor = Utils.generateColorFor(text: Utils.cur_user!.name)
        label_avatar.text = Utils.getAvatarSymbolByName(name: Utils.cur_user!.name)
        let gestureLogoff = UITapGestureRecognizer(target: self, action:  #selector(self.doLogoff))
        self.view_logoff.addGestureRecognizer(gestureLogoff)
        self.label_email.text = Utils.cur_user?.email
        self.label_name.text = name
    }
    override func viewWillAppear(_ animated: Bool) {
        loadInfo()
    }
    @objc func doLogoff(sender : UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Warning", message: "Are you sure to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style {
                case .default:
                MainTabBarController.socket!.disconnect()
                Utils.deleteUserDefault(key: "token")
                self.tabBarController?.dismiss(animated: true, completion: nil)
                break
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
}
