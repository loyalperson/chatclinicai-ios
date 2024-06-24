//
//  ChatVC.swift
//  ChatClinic AI
//
//  Created by charmer on 6/4/24.
//

import UIKit
import Toast_Swift
import KFSwiftImageLoader
import KRProgressHUD
import Alamofire
import HSAttachmentPicker
import FirebaseStorage


class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    var chatRoom: ChatRoom = ChatRoom()
    var messageTab: MessageTab? = nil
    @IBOutlet weak var view_search: UIView!
    @IBOutlet weak var edit_search: UITextField!
    @IBOutlet weak var view_info: UIView!
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var label_email: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn_send: UIButton!
    @IBOutlet weak var txt_input: UITextView!
    @IBOutlet weak var label_sending: UILabel!
    @IBOutlet weak var input_constraint: NSLayoutConstraint!
    var callbackChatFinished : ((ChatRoom)->())?
    var search_flag: Bool = false
    var search_key: String = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollToBottom()
        getChatRoom(thread: chatRoom.thread)
        self.label_email.text = chatRoom.email
        self.label_name.text = chatRoom.name
        
        Utils.cur_page = 1;
        NotificationCenter.default.addObserver(self, selector: #selector(receivedMessage(_:)), name: NSNotification.Name(rawValue: "receivedMessage" + String(Utils.cur_page!)), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("receivedMessage" + String(Utils.cur_page!)), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func receivedMessage(_ notification: Notification) {
        let userInfo = notification.userInfo
        if let message = userInfo!["message"] as? Message {
            self.addMessageToTable(message: message)
        }
    }
    @IBAction func clickMenu(_ sender: Any) {
        let alert = UIAlertController()
            
            alert.addAction(UIAlertAction(title: "Create a Ticket", style: .default , handler:{ (UIAlertAction)in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "TicketCreateVC") as! TicketCreateVC
                vc.modalPresentationStyle = .fullScreen
                vc.chatRoom = self.chatRoom
                self.present(vc, animated: true, completion: nil)
                vc.callbackTicketCreateFinished = { res in
                    self.view.makeToast(res)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Remove Chat", style: .destructive , handler:{ (UIAlertAction)in
                let alert1 = UIAlertController(title: "Warning", message: "Are you sure to remove current chat?", preferredStyle: .alert)
                alert1.addAction(UIKit.UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style {
                        case .default:
                        self.messageTab!.deleteMessage(clientId: self.chatRoom.clientId, thread: self.chatRoom.thread)
                        self.dismiss(animated: true)
                        break
                        
                        case .cancel:
                        print("cancel")
                        
                        case .destructive:
                        print("destructive")
                    }
                }))
                alert1.addAction(UIKit.UIAlertAction(title: "Cancel", style: .default, handler: { action in
                    
                }))
                self.present(alert1, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
                
            }))

            
            //uncomment for iPad Support
            //alert.popoverPresentationController?.sourceView = self.view

            self.present(alert, animated: true, completion: {
                print("completion block")
            })
    }
    private func getChatRoom(thread: String) {
        KRProgressHUD.show()
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
            KRProgressHUD.dismiss()
            switch response.result {
            case .success(let data):
                print("Success with JSON: \(data)")
                if data as! NSObject == NSNull() {
                    return
                }
                let dict = data as! NSDictionary
                self.chatRoom = ChatRoom(dict: dict)
                self.tableView.reloadData()
                self.scrollToBottom()
                break
                
            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func dismissActiveChatRoom() {
        KRProgressHUD.show()
        let token = Utils.readUserDefault(key: "token")
        var clientId: String = ""
        if Utils.cur_user != nil {
            clientId = Utils.cur_user!.clientId
        } else {
            clientId = "vHQb555TdlFOXB79reD8b"
        }
        
        let urlString = "https://app.chatclinicai.com/api/mobile/livechats/" + chatRoom.clientId + "/" + chatRoom.thread + "/inactive"
        
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
                    self.callbackChatFinished!(self.chatRoom)
                    self.dismiss(animated: true)

                } else {
                    self.view.makeToast("Unable to dismiss chat room")
                }
                break

            case .failure(let error):
                print("Request failed with error: \(error)")
                self.view.makeToast("Unable to dismiss chat room")
            }
        }
    }
    @objc func keyboardWillShow(notification:NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.tableView.contentInset
        contentInset.top = keyboardFrame.size.height
        tableView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        tableView.contentInset = contentInset
    }

    func addMessageToTable(message: Message) {
        var flag: Bool = false
        for msg: Message in self.chatRoom.messages {
            if msg.created_at == message.created_at {
                flag = true
                break
            }
        }
        if !flag {
            self.chatRoom.messages.append(message)
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    private func sendMessage(message: Message) {
        self.btn_send.isUserInteractionEnabled = false
        self.btn_send.tintColor = UIColor.lightGray
        self.label_sending.isHidden = false
        let token = Utils.readUserDefault(key: "token")
//        let clientId: String = "vHQb555TdlFOXB79reD8b"//Utils.cur_user!.clientId
        
        let urlString = "https://app.chatclinicai.com/api/mobile/livechats/" + chatRoom.clientId + "/" + chatRoom.thread + "/message"
        var content: String = message.content
        content = content.replacingOccurrences(of: "\n", with: "\\n", options: .literal, range: nil)
        let url = URL(string: urlString)!
        let msg_json = "{\"content\":\"\(content)\", \"file\":\"\(message.file)\", \"role\":\"\(message.role)\", \"readFlag\":\"\(message.readFlag)\", \"created_at\":\"\(message.created_at)\"}"
        let json = "{\"newMessage\":\(msg_json)}"
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        AF.request(request).responseJSON {
            (response) in
            print(response)
            self.label_sending.isHidden = true
            switch response.result {
            case .success(let data):
                print("Success with JSON: \(data)")
                let json = data as! NSDictionary
                let success:Bool = json.object(forKey: "success") as! Bool
                if success {
                    self.txt_input.text = ""
                    self.textViewDidChange(self.txt_input)
                    
                    self.addMessageToTable(message: message)
                } else {
                    self.btn_send.isUserInteractionEnabled = true
                    self.btn_send.tintColor = Constants.accentColor
                    self.view.makeToast("Unable to send message")
                }
                break

            case .failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    @IBAction func editingChanged(_ sender: Any) {
        let key: String = self.edit_search.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        self.search_key = key
        if key.count > 0 {
            var index: Int = -1
            for i in stride(from: chatRoom.messages.count-1, to: 0, by: -1) {
                let msg: Message = chatRoom.messages[i]
                if msg.content.lowercased().contains(key.lowercased()) {
                    index = i
                    break
                }
            }
            
            if index < 0 {
                self.view.makeToast("No message contains '" + key + "'")
//                scrollToBottom()
            } else {
                let indexPath = NSIndexPath(row: index, section: 0)
                DispatchQueue.main.async {
                    self.search_flag = true
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
            }
            
        } else {
            self.search_flag = false
            self.tableView.reloadData()
            scrollToBottom()
        }
    }
    private func scrollToBottom() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.chatRoom.messages.count-1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    @IBAction func clickSearch(_ sender: Any) {
        view_info.isHidden = true
        view_search.isHidden = false
    }
    @IBAction func backToSearch(_ sender: Any) {
        view_info.isHidden = false
        view_search.isHidden = true
        edit_search.text = ""
        search_key = ""
        search_flag = false
        self.tableView.reloadData()
        scrollToBottom()
    }
    @IBAction func clickBack(_ sender: Any) {
        self.dismissActiveChatRoom()
    }

    func textViewDidChange(_ textView: UITextView) {
        adjustUITextViewHeight(arg: textView)
        
        let msg: String = txt_input.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if msg.count == 0 {
            btn_send.tintColor = UIColor.lightGray
            btn_send.isUserInteractionEnabled = false
        } else {
            btn_send.tintColor = Constants.accentColor
            btn_send.isUserInteractionEnabled = true
        }
    }
    
    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.isScrollEnabled = false
        let size = CGSize(width: txt_input.frame.width, height: .greatestFiniteMagnitude)
        let estimatedSize = arg.sizeThatFits(size)
        arg.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
                self.input_constraint.constant = estimatedSize.height+10
            }
        }
    }


    @IBAction func clickSend(_ sender: Any) {
        let msg: String = txt_input.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var jsonMsg: NSDictionary = NSMutableDictionary()
        jsonMsg.setValue(msg, forKey: "content")
        jsonMsg.setValue(Utils.getISOStringFromDate(date: Date()), forKey: "\"created_at\"")
        jsonMsg.setValue("", forKey: "file")
        jsonMsg.setValue(1, forKey: "readFlag")
        jsonMsg.setValue("support", forKey: "role")
        
        var json: NSDictionary = NSMutableDictionary()
        json.setValue("support", forKey: "from")
        json.setValue(chatRoom.clientId, forKey: "fromId")
        json.setValue(jsonMsg, forKey: "message")
        json.setValue(chatRoom.thread, forKey: "toId")
        
        MainTabBarController.socketSendMessage(json: json)

        let message: Message = Message(_id: "", content: msg, file: File(), role: "support", readFlag: 1, created_at: Utils.getISOStringFromDate(date: Date()))
        sendMessage(message: message)
    }
    @IBAction func clickAttach(_ sender: Any) {
//        AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
//         AttachmentHandler.shared.imagePickedBlock = { (image) in
//         /* get your image here */
//         }
//         AttachmentHandler.shared.videoPickedBlock = {(url) in
//         /* get your compressed video url here */
//         }
//         AttachmentHandler.shared.filePickedBlock = {(filePath) in
//         /* get your file path url here */
//         }
//        AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
//            AttachmentHandler.shared.imagePickedBlock = { (image) in
////                let chooseImage = image.resizeImage(targetSize: CGSize(width: 500, height: 600))
////                self.imageList.insert(chooseImage, at: self.imageList.count-1)
////                self.collectionView.reloadData()
//            }
        
        let picker = HSAttachmentPicker()
        
        picker.delegate = self
        picker.showAttachmentMenu()
    }
    func getFileUrl(name: String, type: String, data: Data) {
        KRProgressHUD.show()
        
        let token = Utils.readUserDefault(key: "token")

        let urlString = "https://app.chatclinicai.com/api/mobile/upload/file"
        let json = "{\"fileName\":\"\(name)\", \"fileType\":\"\(type)\"}"

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
                    let presignedURL = res.object(forKey: "presignedURL")! as! String
//                    self.view.makeToast(presignedURL)
//                    self.callbackTicketCreateFinished!("Ticket has been created successfully")
//                    self.dismiss(animated: true)
                    self.uploadImage(imgType: type, data: data, imageName: name, url: presignedURL)

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
    func uploadImage(imgType: String, data: Data, imageName: String, url: String){
        
//        let file = File(link: url,data: data);
//        uploadService.start(file: file)
        
//        let uploadService = UploadService()
//        lazy var uploadSession: URLSession = {
//                let configuration = URLSessionConfiguration.default
//                return URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
//            }()
//        uploadService.uploadSession = uploadSession
//        uploadService.start(file: file)
        
//        let S3BucketName = "BUCKET_NAME"
//        let remoteName = "test.jpg"
//        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(remoteName)
//        let image = UIImage(named: "test")
//        let data = image!.jpegData(compressionQuality: 0.9)
//        do {
//            try data?.write(to: fileURL)
//        }
//        catch {}
//        
//        let uploadRequest = AWSS3TransferManagerUploadRequest()!
//        uploadRequest.body = fileURL
//        uploadRequest.key = remoteName
//        uploadRequest.bucket = S3BucketName
//        uploadRequest.contentType = "image/jpeg"
//        uploadRequest.acl = .publicRead
//        
//        let transferManager = AWSS3TransferManager.default()
//        
//        transferManager.upload(uploadRequest).continueWith { [weak self] (task) -> Any? in
//            DispatchQueue.main.async {
//                self?.uploadButton.isHidden = false
//                self?.activityIndicator.stopAnimating()
//            }
//            
//            if let error = task.error {
//                print("Upload failed with error: (\(error.localizedDescription))")
//            }
//            
//            if task.result != nil {
//                let url = AWSS3.default().configuration.endpoint.url
//                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
//                if let absoluteString = publicURL?.absoluteString {
//                    print("Uploaded to:\(absoluteString)")
//                }
//            }
//            
//            return nil
//        }
        
//        // params to send additional data, for eg. AccessToken or userUserId
//        KRProgressHUD.show()
//        AWSS3Manager.configAWS()
//        AWSS3Manager.shared.uploadImage(image: image, progress: {[weak self] ( uploadProgress) in
//                
//                guard let strongSelf = self else { return }
////                strongSelf.progressView.progress = Float(uploadProgress)//2
//                
//            }) {[weak self] (uploadedFileUrl, error) in
//                
//                guard let strongSelf = self else { return }
//                if let finalPath = uploadedFileUrl as? String { // 3
////                    strongSelf.s3UrlLabel.text = "Uploaded file url: " + finalPath
//                } else {
//                    print("\(String(describing: error?.localizedDescription))") // 4
//                }
//            }
        
////        let params = ["userID":"userId","accessToken":"your accessToken"]
//        let headers: HTTPHeaders = [
//                    /* "Authorization": "your_access_token",  in case you need authorization header */
////                    "Content-type": imgType
//                    "Content-type": "image/jpeg"
//                ]
//        AF.upload(multipartFormData: { multiPart in
//            
//            multiPart.append(imgData, withName: "key",fileName: imageName, mimeType: "image/jpeg")
//        }, to: url, method: .put , headers: headers).responseJSON { apiResponse in
//            KRProgressHUD.dismiss()
//            switch apiResponse.result{
//            case .success(_):
//                print (apiResponse.data)
//                let apiDictionary = apiResponse.value as? [String:Any]
//                
//            case .failure(let error):
//                if (apiResponse.data?.count)! > 0 {print(error)}
//            }
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var pre_message: Message? = nil
        if indexPath.row >= 1 {
            pre_message = chatRoom.messages[indexPath.row-1]
        }
        let message = chatRoom.messages[indexPath.row]
        
        if(message.role == "user") {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "LeftMessageCell") as! LeftMessageCell
            
            if pre_message != nil {
                
                let pre_message_created = Utils.getDateStringFromDate(date: Utils.getDateFromString(isoDate: pre_message!.created_at))
                let message_created = Utils.getDateStringFromDate(date: Utils.getDateFromString(isoDate: message.created_at))
                if  pre_message_created == message_created {
                    cell2.view_date.isHidden = true
                    
                    if pre_message?.role == "user" {
                        let diff: Bool = Utils.isMinuteDifferentBetweenDates(oldDate: Utils.getDateFromString(isoDate: pre_message!.created_at), newDate: Utils.getDateFromString(isoDate: message.created_at))
                        if !diff {
                            cell2.view_avatar.isHidden = true
                            cell2.label_time.isHidden = true
                            cell2.constraint_content.constant = 0
                            cell2.constraint_pic.constant = 0
                        } else {
                            cell2.view_avatar.isHidden = false
                            cell2.label_time.isHidden = false
                            cell2.constraint_content.constant = 20
                            cell2.constraint_pic.constant = 30
                            cell2.constraint_time.constant = 5
                            cell2.constraint_avatar.constant = 5
                        }
                    } else {
                        cell2.view_avatar.isHidden = false
                        cell2.label_time.isHidden = false
                        cell2.constraint_content.constant = 20
                        cell2.constraint_pic.constant = 30
                        cell2.constraint_time.constant = 5
                        cell2.constraint_avatar.constant = 5
                    }
                } else {
                    cell2.view_date.isHidden = false
                    cell2.view_avatar.isHidden = false
                    cell2.label_time.isHidden = false
                    cell2.constraint_avatar.constant = 35
                    cell2.constraint_time.constant = 35
                    cell2.constraint_content.constant = 50
                    cell2.constraint_pic.constant = 60
                }
                
            } else {
                cell2.view_date.isHidden = false
                cell2.view_date.isHidden = false
                cell2.view_avatar.isHidden = false
                cell2.label_time.isHidden = false
                cell2.constraint_avatar.constant = 35
                cell2.constraint_time.constant = 35
                cell2.constraint_content.constant = 50
                cell2.constraint_pic.constant = 60
            }
            cell2.label_date.text = Utils.getWeekdayFromDate(date: Utils.getDateFromString(isoDate: message.created_at))
            
            // -------------
            if search_flag {
                Utils.setColoredTextLabel(fullText: message.content, subText: search_key, label: cell2.contentLabel, normalColor: UIColor.black, subColor: UIColor.blue)
            } else {
                cell2.contentLabel.text = message.content
                cell2.contentLabel.textColor = UIColor.black
            }
            // -------------
            
            
            cell2.label_time.text = Utils.getTimeStringFromDate(date: Utils.getDateFromString(isoDate: message.created_at))
            cell2.label_avatar.text = Utils.getAvatarSymbolByName(name: chatRoom.name)
            cell2.view_avatar.backgroundColor = Utils.generateColorFor(text: chatRoom.name)

            cell2.contentLabel.font = UIFont.systemFont(ofSize: 18)
            
            cell2.contentLabel?.layer.masksToBounds = true
            cell2.contentLabel.layer.cornerRadius = 7
            if message.file.url.count > 0 {
                cell2.img_pic.isHidden = false
                cell2.contentLabel.isHidden = true
                cell2.img_pic.loadImage(urlString: message.file.url, placeholder: UIImage(systemName: "photo")) {
                    (success, error) in
                    
                    // 'success' is a 'Bool' indicating success or failure.
                    // 'error' is an 'Error?' containing the error (if any) when 'success' is 'false'.
                }
            } else {
                cell2.img_pic.isHidden = true
                cell2.contentLabel.isHidden = false
            }
            cell2.message = message
            cell2.vcP = self
            cell2.layoutIfNeeded()
            return cell2
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightMessageCell") as! RightMessageCell
            
            if pre_message != nil {
                
                let pre_message_created = Utils.getDateStringFromDate(date: Utils.getDateFromString(isoDate: pre_message!.created_at))
                let message_created = Utils.getDateStringFromDate(date: Utils.getDateFromString(isoDate: message.created_at))
                if  pre_message_created == message_created {
                    cell.view_date.isHidden = true
                    
                    if pre_message?.role == "support" {
                        let diff: Bool = Utils.isMinuteDifferentBetweenDates(oldDate: Utils.getDateFromString(isoDate: pre_message!.created_at), newDate: Utils.getDateFromString(isoDate: message.created_at))
                        if !diff {
                            cell.label_time.isHidden = true
                            cell.constraint_content.constant = 0
                            cell.constraint_pic.constant = 0
                        } else {
                            cell.label_time.isHidden = false
                            cell.constraint_time.constant = 0
                            cell.constraint_content.constant = 20
                            cell.constraint_pic.constant = 30
                        }
                    } else {
                        cell.label_time.isHidden = false
                        cell.constraint_time.constant = 0
                        cell.constraint_content.constant = 20
                        cell.constraint_pic.constant = 30
                    }
                } else {
                    cell.view_date.isHidden = false
                    cell.label_time.isHidden = false
                    cell.constraint_time.constant = 30
                    cell.constraint_content.constant = 50
                    cell.constraint_pic.constant = 60
                }
                
            } else {
                cell.view_date.isHidden = false
                cell.view_date.isHidden = false
                cell.label_time.isHidden = false
                cell.constraint_time.constant = 30
                cell.constraint_content.constant = 50
                cell.constraint_pic.constant = 60
            }
            cell.label_date.text = Utils.getWeekdayFromDate(date: Utils.getDateFromString(isoDate: message.created_at))
            // -------------
            if search_flag {
                Utils.setColoredTextLabel(fullText: message.content, subText: search_key, label: cell.contentLabel, normalColor: UIColor.black, subColor: UIColor.blue)
            } else {
                cell.contentLabel.text = message.content
                cell.contentLabel.textColor = UIColor.black
            }
            // -------------
            cell.label_time.text = Utils.getTimeStringFromDate(date: Utils.getDateFromString(isoDate: message.created_at))

            cell.contentLabel.font = UIFont.systemFont(ofSize: 18)
            
            cell.contentLabel?.layer.masksToBounds = true
            cell.contentLabel.layer.cornerRadius = 7
            
            if message.file.url.count > 0 {
                cell.img_pic.isHidden = false
                cell.contentLabel.isHidden = true
                cell.img_pic.loadImage(urlString: message.file.url, placeholder: UIImage(systemName: "photo")) {
                    (success, error) in

                }
            } else {
                cell.img_pic.isHidden = true
                cell.contentLabel.isHidden = false
            }
            cell.message = message
            cell.vcP = self
            cell.layoutIfNeeded()
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = chatRoom.messages[indexPath.row]
        if message.file.url.count > 0 {
            return 200
        }
//        if indexPath.row == 2 {
//            return UITableView.automaticDimension - 30
//        }
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatRoom.messages.count
    }
    func uploadMedia(fileName: String, data: Data, fileType: String, completion: @escaping (_ url: String?) -> Void) {
//        let uploadData:Data = image.jpegData(compressionQuality: 0.5)!
        let stoRef:StorageReference = Storage.storage().reference().child("chat/"+String(Utils.getCurrentTimestamp()))
        let metaData = StorageMetadata()
        metaData.contentType = fileType
        stoRef.putData(data, metadata: metaData) { metadata, error in
            if error != nil {
                print("error")
                
            } else {
                stoRef.downloadURL(completion: { (url, error) in

                    print(url?.absoluteString)
                    completion(url?.absoluteString)
                })
                // your uploaded photo url.
            }
        }
        
    }
    
}

extension ChatVC: HSAttachmentPickerDelegate {
  func attachmentPickerMenu(_ menu: HSAttachmentPicker, showErrorMessage errorMessage: String) {
    // Handle errors
      self.view.makeToast(errorMessage)
  }

  func attachmentPickerMenuDismissed(_ menu: HSAttachmentPicker) {
    // Run some code when the picker is dismissed
  }

  func attachmentPickerMenu(_ menu: HSAttachmentPicker, show controller: UIViewController, completion: (() -> Void)? = nil) {
    self.present(controller, animated: true, completion: completion)
  }

  func attachmentPickerMenu(_ menu: HSAttachmentPicker, upload data: Data, filename: String, image: UIImage?) {
    // Do something with the data of the selected attachment, i.e. upload it to a web service
      DispatchQueue.main.async {
//          self.view.makeToast(filename)
          let name = filename.fileName()
          let ext = filename.fileExtension()
//          var filePath: URL? = nil
//          do {
//              filePath = try Utils.saveToDocuments(image: image!, name: filename, ext: ext)
//          } catch {
//              print (error)
//          }
//          self.sel_image = image
          KRProgressHUD.show()
          self.uploadMedia(fileName: name, data: data, fileType: ext) { url in
              
              KRProgressHUD.dismiss()
              let file: File = File(fileName: name, fileType: ext, url: url!)
//              let msg: String = txt_input.text!.trimmingCharacters(in: .whitespacesAndNewlines)
              var jsonMsg: NSDictionary = NSMutableDictionary()
              jsonMsg.setValue("", forKey: "content")
              jsonMsg.setValue(Utils.getISOStringFromDate(date: Date()), forKey: "\"created_at\"")
              jsonMsg.setValue(file, forKey: "file")
              jsonMsg.setValue(1, forKey: "readFlag")
              jsonMsg.setValue("support", forKey: "role")
              
              var json: NSDictionary = NSMutableDictionary()
              json.setValue("support", forKey: "from")
              json.setValue(self.chatRoom.clientId, forKey: "fromId")
              json.setValue(jsonMsg, forKey: "message")
              json.setValue(self.chatRoom.thread, forKey: "toId")
              
              MainTabBarController.socketSendMessage(json: json)

              let message: Message = Message(_id: "", content: "", file: file, role: "support", readFlag: 1, created_at: Utils.getISOStringFromDate(date: Date()))
              self.sendMessage(message: message)
//              self.view.makeToast(url)
          }
      }
  }
    
}
extension String {

    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}

