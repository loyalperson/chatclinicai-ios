//
//  Model.swift
//  AlertStar
//
//  Created by jhon on 1/17/23.
//
import UIKit


class User : Decodable{
    var _id: String = ""
    var name: String = ""
    var email: String = ""
    var clientId: String = ""
    var plan: String = ""
    var deviceToken: String = ""

    init(dict: NSDictionary) {
        self._id = dict.object(forKey: "_id") as! String
        self.name = dict.object(forKey: "name") as! String
        self.email = dict.object(forKey: "email") as! String
        self.clientId = dict.object(forKey: "clientId") as! String
        self.plan = dict.object(forKey: "plan") as! String
        self.deviceToken = dict.object(forKey: "deviceToken") as! String
    }
}

struct ChatRoom : Decodable {
    var _id: String
    var thread: String
    var clientId: String
    var name: String
    var email: String
    var messages: [Message]
    var activeFlag: Int
    var createdAt: String
    var updatedAt: String
    init(_id: String, thread: String, clientId: String, name: String, email: String, messages: [Message], activeFlag: Int, createdAt: String, updatedAt: String) {
        self._id = _id
        self.thread = thread
        self.clientId = clientId
        self.name = name
        self.email = email
        self.messages = messages
        self.activeFlag = activeFlag
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    init(dict: NSDictionary) {
        self._id = dict.object(forKey: "_id") as! String
        self.thread = dict.object(forKey: "thread") as! String
        self.clientId = dict.object(forKey: "clientId") as! String
        self.name = dict.object(forKey: "name") as! String
        self.email = dict.object(forKey: "email") as! String
        let array = dict.object(forKey: "messages") as! [NSDictionary]
        self.messages = [Message]()
        for dict in array {
            let msg: Message = Message(dict: dict)
            self.messages.append(msg)
        }
        self.activeFlag = dict.object(forKey: "activeFlag") as! Int
        self.createdAt = dict.object(forKey: "createdAt") as! String
        self.updatedAt = dict.object(forKey: "updatedAt") as! String
    }
    init() {
        self._id = ""
        self.thread = ""
        self.clientId = ""
        self.name = ""
        self.email = ""
        self.messages = []
        self.activeFlag = 0
        self.createdAt = ""
        self.updatedAt = ""
    }
    
}
class Message : Decodable {
    var _id: String = ""
    var content: String = ""
    var file: File = File()
    var role: String = ""
    var readFlag: Int = 0
    var created_at: String = ""

    init() {
        self._id = ""
        self.content = ""
        self.file = File()
        self.role = ""
        self.readFlag = 0
        self.created_at = ""
    }
    
    init(_id: String, content: String, file: File, role: String, readFlag: Int, created_at: String) {
        self._id = _id
        self.content = content
        self.file = file
        self.role = role
        self.readFlag = readFlag
        self.created_at = created_at
    }
    init(dict: NSDictionary) {
        self._id = dict.object(forKey: "_id") as! String
        self.content = dict.object(forKey: "content") as! String
        
        if dict.object(forKey: "file") == nil {
            self.file = File()
        } else {
            self.file = dict.object(forKey: "file") as! File
        }
        self.role = dict.object(forKey: "role") as! String
        self.readFlag = dict.object(forKey: "readFlag") as! Int
        self.created_at = dict.object(forKey: "created_at") as! String
    }
}
struct LoginModel: Codable {
    var email: String
    var password: String
    var deviceToken: String
}
struct Ticket : Decodable {
    var _id: String
    var name: String
    var email: String
    var details: String
    var status: String
    var referenceId: String
    var createdAt: String
    var updatedAt: String
    
    init(dict: NSDictionary) {
        self._id = dict.object(forKey: "_id") as! String
        self.name = dict.object(forKey: "name") as! String
        self.email = dict.object(forKey: "email") as! String
        self.details = dict.object(forKey: "details") as! String
        self.status = dict.object(forKey: "status") as! String
        self.referenceId = dict.object(forKey: "referenceId") as! String
        self.createdAt = dict.object(forKey: "createdAt") as! String
        self.updatedAt = dict.object(forKey: "updatedAt") as! String
    }
    
}
class File: Codable {
    var fileName: String = "";
    var fileType: String = "";
    var url: String = "";
    
    init(dict: NSDictionary) {
        self.fileName = dict.object(forKey: "fileName") as! String
        self.fileType = dict.object(forKey: "fileType") as! String
        self.url = dict.object(forKey: "url") as! String
    }
    
    init(fileName: String, fileType: String, url: String) {
        self.fileName = fileName
        self.fileType = fileType
        self.url = url
    }
    init() {
        self.fileName = ""
        self.fileType = ""
        self.url = ""
    }
}
