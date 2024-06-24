//
//  TicketVC.swift
//  ChatClinic AI
//
//  Created by charmer on 6/4/24.
//

import UIKit
import Toast_Swift
import KRProgressHUD
import Alamofire

class TicketTab: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tickets: [Ticket] = [Ticket]()
    
    var mainTab: MainTabBarController? = nil
    
    @IBOutlet weak var label_noticket: UILabel!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        getTickets()
    }
    private func getTickets() {
        KRProgressHUD.show()
        let token = Utils.readUserDefault(key: "token")
        var clientId: String = ""
        if Utils.cur_user != nil {
            clientId = Utils.cur_user!.clientId
        } else {
            clientId = "vHQb555TdlFOXB79reD8b"
        }
        
        let urlString = "https://app.chatclinicai.com/api/mobile/tickets"
        
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
                    self.tickets = [Ticket]()
                    let array = dict.object(forKey: "tickets") as! NSArray
                    for dic in array {
                        let ticket = Ticket(dict: dic as! NSDictionary)
                        self.tickets.append(ticket)
                    }
                    if self.tickets.count == 0 {
                        self.label_noticket.isHidden = false
                    } else {
                        self.label_noticket.isHidden = true
                    }
                    self.tableView.reloadData()
                    
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
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCell") as? TicketCell {
            let ticket: Ticket = self.tickets[indexPath.row]
            cell.label_no.text = String(indexPath.row.codingKey.intValue!+1)
            cell.label_details.text = ticket.details
            cell.label_email.text = ticket.email
            cell.label_referId.text = "# " + ticket.referenceId
            cell.label_date.text = Utils.getDateStringFromDate(date: Utils.getDateFromString(isoDate: ticket.createdAt))
            cell.label_status.text = ticket.status
            if ticket.status == "Resolved" {
                cell.view_status.backgroundColor = UIColor.systemGreen
            } else {
                cell.view_status.backgroundColor = UIColor.systemRed
            }
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tickets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let ticket: Ticket = self.tickets[indexPath.row]

        if editingStyle == .delete {
            let alert = UIAlertController(title: "Warning", message: "Are you sure to delete?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style {
                    case .default:
                    self.deleteTicket(ticketId: ticket._id)
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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TicketManagementVC") as! TicketManagementVC
        vc.modalPresentationStyle = .fullScreen
        vc.ticket = self.tickets[indexPath.row]
        self.present(vc, animated: true, completion: nil)
        vc.callbackTicketManagementFinished = { ticket in
            self.getTickets()
        }
    }
    private func deleteTicket(ticketId: String) {
        KRProgressHUD.show()
        let token = Utils.readUserDefault(key: "token")
        var clientId: String = ""
        if Utils.cur_user != nil {
            clientId = Utils.cur_user!.clientId
        } else {
            clientId = "vHQb555TdlFOXB79reD8b"
        }
        
        let urlString = "https://app.chatclinicai.com/api/mobile/tickets/" + ticketId + "/delete"
        
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
                    self.getTickets()
                    
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
