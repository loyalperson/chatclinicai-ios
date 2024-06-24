//
//  MainTabBarController.swift
//  ChatClinic AI
//
//  Created by charmer on 6/4/24.
//

import UIKit

import KRProgressHUD
import Alamofire
import SocketIO
import NotificationBannerSwift

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    let menuTitles:[String] = ["Messages", "Tickets", "Support", "Settings"]
    var loadedMarket:Bool = false, loadedGeofence:Bool = false
    static var socket: SocketIOClient? = nil
    static var socketManager: SocketManager? = nil

//    static var messageReceivedCallbackMessage : ((Message)->())?
//    static var messageReceivedCallbackChat : ((Message)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers?.forEach({
            $0.tabBarItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 13.0, weight: .regular)], for: .normal)
        })
        
        tabBar.items?[0].title = menuTitles[0]
        
        let messageTab: MessageTab = self.viewControllers![0] as! MessageTab
        messageTab.mainTab = self
        let ticketTab: TicketTab = self.viewControllers![1] as! TicketTab
        ticketTab.mainTab = self
        let supportTab: SupportTab = self.viewControllers![2] as! SupportTab
        supportTab.mainTab = self
        let settingsTab: SettingsTab = self.viewControllers![3] as! SettingsTab
        settingsTab.mainTab = self
        
    }

    private func setUpSocketMessageListener() {
        MainTabBarController.socket?.on("message", callback: { (data, ack) in
            print(data)
            let dataArray = data as NSArray

            let json = dataArray[0] as! NSDictionary
            let fromId = json["fromId"] as! String
            let message = json["message"] as! NSDictionary

            let content = message["content"] as! String
            let created_at = message["created_at"] as! String
            let file = message["file"] as! File
            let readFlag = message["readFlag"] as! Int
            let role = message["role"] as! String
            
            let msg: Message = Message(_id: "", content: content, file: file, role: role, readFlag: readFlag, created_at: created_at)
            let info = ["message": msg, "thread": fromId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "receivedMessage" + String(Utils.cur_page!)), object: nil, userInfo: info)
            
            let banner = NotificationBanner(title: "New message", subtitle: content, style: .success)
            banner.show()
        })
        MainTabBarController.socket?.on("newVisitor", callback: { (data, ack) in
            print(data)
            let dataArray = data as NSArray

            let json = dataArray[0] as! NSDictionary
            let thread = json["thread"] as! String
//
//            let content = message["content"] as! String
//            let created_at = message["created_at"] as! String
//            let file = message["file"] as! String
//            let readFlag = message["readFlag"] as! Int
//            let role = message["role"] as! String
//            
//            let msg: Message = Message(_id: "", content: content, file: file, role: role, readFlag: readFlag, created_at: created_at)
            let info = ["thread": thread]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "newVisitor"), object: nil, userInfo: info)
        })
    }
    static func socketConnect() {
        MainTabBarController.socketManager = SocketManager(socketURL: URL(string: "https://chatclinic-socket-3e6816576ccc.herokuapp.com")!, config: [.log(true), .compress])

        // Create a Socket.IO client
        MainTabBarController.socket = socketManager!.defaultSocket
        MainTabBarController.socket!.on(clientEvent: .connect) {data, ack in
            print(data)
            print("socket connected")

            self.socket!.emit("identify", "support", "vHQb555TdlFOXB79reD8b")

        }
        socket!.connect()
    }
    static func socketSendMessage(json: NSDictionary) {
        MainTabBarController.socket!.emit("message", json)
    }
    override func viewWillAppear(_ animated: Bool) {
        MainTabBarController.socketConnect()
        setUpSocketMessageListener()
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    func setMessageBadge(number: Int) {
        blinkAnim(item: tabBar.items![0])
//        if tabBar.items?[0].badgeValue != nil {
//            let old_number: Int = (tabBar.items?[0].badgeValue?.codingKey.intValue)!
//            if number != old_number {
//                blinkAnim(item: tabBar.items![0])
//            }
//        } else {
//            blinkAnim(item: tabBar.items![0])
//        }
        
        if number == 0 {
            tabBar.items?[0].badgeValue = nil
        } else {
            tabBar.items?[0].badgeValue = String(number)
        }
    }
    func blinkAnim(item: UITabBarItem) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            item.badgeColor = UIColor.clear
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                item.badgeColor = UIColor.systemRed
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    item.badgeColor = UIColor.clear
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        item.badgeColor = UIColor.systemRed
                    }
                }
            }
        }
     }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Selected item")
    
    
//            self.viewControllers?.forEach({
//                $0.tabBarItem.title = ""
//            })
//            if item == (self.tabBar.items!)[0]{
//                item.title = menuTitles[0]
//            } else if item == (tabBar.items!)[1]{
//                item.title = menuTitles[1]
//            } else if item == (tabBar.items!)[2]{
//                item.title = menuTitles[2]
////                item.badgeValue = nil
////                MyUtils.setUserDefaultInt(key: MyUtils.NewAlert, value: 0)
//            }
    }
    
    func changeTabBar(hidden:Bool, animated: Bool){
        let tabBar = self.tabBar
        let offset = (hidden ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.height - (tabBar.frame.size.height) )
        if offset == tabBar.frame.origin.y {return}
        print("changing origin y position")
        let duration:TimeInterval = (animated ? 0.5 : 0.0)
        UIView.animate(withDuration: duration,
                       animations: {tabBar.frame.origin.y = offset},
                       completion:nil)
    }
}
