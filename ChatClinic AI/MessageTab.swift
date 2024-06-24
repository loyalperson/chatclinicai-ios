//
//  ChatVC.swift
//  ChatClinic AI
//
//  Created by charmer on 6/4/24.
//

import UIKit
import Toast_Swift
import KRProgressHUD
import Alamofire

class MessageTab: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    var chatRooms:[ChatRoom] = [ChatRoom]()
    var chatRoomsFiltered:[ChatRoom] = [ChatRoom]()
    @IBOutlet weak var label_no_message: UILabel!
    @IBOutlet weak var edit_search: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var view_click_menu: UIView!
    @IBOutlet weak var btn_erase_key: UIButton!
    var mainTab: MainTabBarController? = nil
    var search_flag: Bool = false
    var search_key: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.refreshPage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self, name: Notification.Name("receivedMessage" + String(Utils.cur_page!)), object: nil)
//        NotificationCenter.default.removeObserver(self, name: Notification.Name("newVisitor"), object: nil)
    }

    func refreshPage() {
        Utils.cur_page = 0;
        NotificationCenter.default.addObserver(self, selector: #selector(receivedMessage(_:)), name: NSNotification.Name(rawValue: "receivedMessage" + String(Utils.cur_page!)), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receivedNewVisitor(_:)), name: NSNotification.Name(rawValue: "newVisitor"), object: nil)
        getFullChatRooms()
    }
    @objc func receivedNewVisitor(_ notification: Notification) {
        let userInfo = notification.userInfo
        let thread = userInfo!["thread"] as! String
        var flag: Bool = false
        for chatRoom: ChatRoom in self.chatRooms {
            if chatRoom.thread == thread {
                flag = true
                break
            }
        }
        if !flag {
            self.getNewChatRoom(thread: thread)
        }
    }
    @objc func receivedMessage(_ notification: Notification) {
        let userInfo = notification.userInfo
        let thread = userInfo!["thread"] as! String
        if let message = userInfo!["message"] as? Message {
//            self.getFullChatRooms()
            var flag_thread: Bool = false
            var i: Int = 0
            for var chatRoom in chatRooms {
                if chatRoom.thread == thread {
                    var flag_message: Bool = false
                    for msg: Message in chatRoom.messages {
                        if msg.created_at == message.created_at {
                            flag_message = true
                            break
                        }
                    }
                    if !flag_message {
                        chatRoom.messages.append(message)
                        self.chatRooms[i] = chatRoom
                        self.filterSearch()
                    }
                    flag_thread = true
                    break
                }
                i += 1
            }
            if !flag_thread {
                self.getNewChatRoom(thread: thread, message: message)
            }
        }
        self.getUnreadChatRooms()
    }

    @IBAction func eraseSearchKey(_ sender: Any) {
        self.edit_search.text = ""
        filterSearch()
    }
    @IBAction func editChanged(_ sender: Any) {
        
        filterSearch()
    }
    private func filterSearch() {
        let key: String = self.edit_search.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        search_key = key
        if key.count > 0 {
            self.btn_erase_key.isHidden = false
        } else {
            self.btn_erase_key.isHidden = true
        }
        self.chatRoomsFiltered = [ChatRoom]()
        if key == "" {
            self.chatRoomsFiltered = [ChatRoom](self.chatRooms)
            search_flag = false
        } else {
            search_flag = true
            for chatRoom in self.chatRooms {
                if chatRoom.name.lowercased().contains(key.lowercased()) {
                    self.chatRoomsFiltered.append(chatRoom)
                } else {
                    for msg in chatRoom.messages {
                        if msg.content.lowercased().contains(key.lowercased()) {
                            self.chatRoomsFiltered.append(chatRoom)
                            break
                        }
                    }
                }
            }
        }
        if self.chatRoomsFiltered.count == 0 {
            self.label_no_message.isHidden = false
            self.label_no_message.text = "No message contains '" + key + "'"
        } else {
            self.label_no_message.isHidden = true
            self.label_no_message.text = ""
        }
        self.tableView.reloadData()
    }
    private func getUnreadChatRooms() {
        var unread: Int = 0
        for chatRoom in chatRooms {
            for msg in chatRoom.messages {
                if msg.role == "user" && msg.readFlag == 0 {
                    unread += 1
                    break
                }
            }
        }
        self.mainTab?.setMessageBadge(number: unread)
    }

    private func goActiveChatRoom(chatRoom: ChatRoom) {
        KRProgressHUD.show()
        let token = Utils.readUserDefault(key: "token")
        var clientId: String = ""
        if Utils.cur_user != nil {
            clientId = Utils.cur_user!.clientId
        } else {
            clientId = "vHQb555TdlFOXB79reD8b"
        }
        
        let urlString = "https://app.chatclinicai.com/api/mobile/livechats/" + chatRoom.clientId + "/" + chatRoom.thread + "/active"
        
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
                let json = data as! NSDictionary
                let success:Bool = json.object(forKey: "success") as! Bool
                if success {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                    vc.modalPresentationStyle = .fullScreen
                    vc.chatRoom = chatRoom
                    vc.messageTab = self
                    self.present(vc, animated: true, completion: nil)
                    vc.callbackChatFinished = { chatRoom in
                        self.refreshPage()
                    }

                } else {
                    self.view.makeToast("Unable to go to chat room")
                }
                break

            case .failure(let error):
                print("Request failed with error: \(error)")
                self.view.makeToast("Unable to go to chat room")
            }
        }
    }
    private func getNewChatRoom(thread: String, message: Message = Message()) {
        var messages: [Message] = [Message]()
        messages.append(message)
        let token = Utils.readUserDefault(key: "token")
        var clientId: String = ""
        if Utils.cur_user != nil {
            clientId = Utils.cur_user!.clientId
        } else {
            clientId = "vHQb555TdlFOXB79reD8b"
        }
        
        let urlString = "https://app.chatclinicai.com/api/mobile/livechats/" + clientId + "/" + thread
        
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")

        AF.request(request).responseJSON {
            (response) in
            print(response)
            switch response.result {
            case .success(let data):
                print("Success with JSON: \(data)")
                if data as! NSObject == NSNull() {
                    
//                    self.chatRooms.append(ChatRoom(_id: "", thread: thread, clientId: Utils.cur_user!.clientId, name: "Anonymous", email: "", messages: messages, activeFlag: 0, createdAt: Utils.getISOStringFromDate(date: Date()), updatedAt: ""))
//                    self.filterSearch()
//                    self.getUnreadChatRooms()
                    return
                }
                do {
                    let dict = try data as! NSDictionary
                    let chatRoom = ChatRoom(dict: dict)
                    var flag: Bool = false
                    for ch: ChatRoom in self.chatRooms {
                        if ch.thread == chatRoom.thread {
                            flag = true
                            break
                        }
                    }
                    if !flag {
                        self.chatRooms.append(chatRoom)
                    }
                    
                    self.filterSearch()
                    self.getUnreadChatRooms()
                } catch let error {
                    print("Unexpected error: \(error).")
                }
                
                break
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    private func getFullChatRooms() {
        KRProgressHUD.show()
        let token = Utils.readUserDefault(key: "token")
        var clientId: String = ""
        if Utils.cur_user != nil {
            clientId = Utils.cur_user!.clientId
        } else {
            clientId = "vHQb555TdlFOXB79reD8b"
        }
        
        let urlString = "https://app.chatclinicai.com/api/mobile/livechats/" + clientId
        
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
                let array = data as! NSArray
                self.chatRooms = [ChatRoom]()
                for dict in array {
                    let chatRoom = ChatRoom(dict: dict as! NSDictionary)
                    self.chatRooms.append(chatRoom)
                }
                self.chatRoomsFiltered = [ChatRoom](self.chatRooms)
                self.tableView.reloadData()
                if self.chatRoomsFiltered.count == 0 {
                    self.label_no_message.text = "No message"
                    self.label_no_message.isHidden = false
                } else {
                    self.label_no_message.isHidden = true
                    self.getUnreadChatRooms()
                }
                break

            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as? MessageCell {
            let chatRoom: ChatRoom = self.chatRoomsFiltered[indexPath.row]
            let name = chatRoom.name
            cell.view_avatar.backgroundColor = Utils.generateColorFor(text: name)
            cell.label_avatar.text = Utils.getAvatarSymbolByName(name: name)
            // ------------
            if search_flag {
                Utils.setColoredTextLabel(fullText: chatRoom.name, subText: search_key, label: cell.label_name, normalColor: UIColor.black, subColor: UIColor.blue)
            } else {
                cell.label_name.text = chatRoom.name
                cell.label_name.textColor = UIColor.black
            }
            // ---------------
            // --------------
            if search_flag {
                var newMsg: Message? = nil
                for i in stride(from: chatRoom.messages.count-1, to: 0, by: -1) {
                    let msg: Message = chatRoom.messages[i]
                    if msg.content.lowercased().contains(search_key.lowercased()) {
                        newMsg = msg
                        break
                    }
                }
                if newMsg != nil {
                    Utils.setColoredTextLabel(fullText: newMsg!.content, subText: search_key, label: cell.label_message, normalColor: UIColor.darkGray, subColor: UIColor.blue)
                    let date: Date = Utils.getDateFromString(isoDate: newMsg!.created_at)
                    cell.label_time.text = Utils.getDateStringFromDate(date: date)
                }
            } else {
                if chatRoom.messages.count > 0 {
                    let lastMsg: Message = chatRoom.messages[chatRoom.messages.count-1]
                    cell.label_message.text = lastMsg.content
                    cell.label_message.textColor = UIColor.darkGray
                    let date: Date = Utils.getDateFromString(isoDate: lastMsg.created_at)
                    cell.label_time.text = Utils.getDateStringFromDate(date: date)
                } else {
                    cell.label_message.text = ""
                    cell.label_message.textColor = UIColor.darkGray
                    
                    cell.label_time.text = ""
                }
            }
            // ----------------
            
            var unreadMsgCount: Int = 0
            for msg in chatRoom.messages {
                if msg.role == "user" && msg.readFlag == 0 {
                    unreadMsgCount += 1
                }
            }
            cell.label_badge.text = String(unreadMsgCount)
            if unreadMsgCount == 0 {
                cell.view_badge.isHidden = true
//                cell.label_message.textColor = UIColor.darkText
            } else {
                cell.view_badge.isHidden = false
//                cell.label_message.textColor = UIColor.orange
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRoomsFiltered.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let chatRoom: ChatRoom = self.chatRoomsFiltered[indexPath.row]

        if editingStyle == .delete {
            let alert = UIAlertController(title: "Warning", message: "Are you sure to delete?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style {
                    case .default:
                    self.deleteMessage(clientId: chatRoom.clientId, thread: chatRoom.thread)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.goActiveChatRoom(chatRoom: self.chatRoomsFiltered[indexPath.row])
    }
    var lastContentOffset: CGFloat = 0

    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }

    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.lastContentOffset < scrollView.contentOffset.y {
            // did move up
            self.mainTab!.changeTabBar(hidden: true, animated: true)
        } else if self.lastContentOffset > scrollView.contentOffset.y {
            // did move down
            self.mainTab!.changeTabBar(hidden: false, animated: true)
        } else {
            // didn't move
            self.mainTab!.changeTabBar(hidden: false, animated: true)
        }
        
        let isReachingEnd = scrollView.contentOffset.y >= 0
              && scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)
        if isReachingEnd {
            self.mainTab!.changeTabBar(hidden: false, animated: true)
        }
    }
    func deleteMessage(clientId: String, thread: String) {
        KRProgressHUD.show()
        let token = Utils.readUserDefault(key: "token")
        var clientId: String = ""
        if Utils.cur_user != nil {
            clientId = Utils.cur_user!.clientId
        } else {
            clientId = "vHQb555TdlFOXB79reD8b"
        }
        
        let urlString = "https://app.chatclinicai.com/api/mobile/livechats/" + clientId + "/" + thread + "/delete"
        
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
                    self.view.makeToast("Chat has been removed successfully")
                    self.getFullChatRooms()
                    
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
}

