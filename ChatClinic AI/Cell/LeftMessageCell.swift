//
//  LeftMessageCell.swift
//  GrowingTextViewExample
//
//  Created by 洪鑫 on 16/2/17.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit
import CircleImageView

let kLeftMessageCellID = "LeftMessageCell"
private let leftPadding: CGFloat = 30
private let rightPadding: CGFloat = UIScreen.main.bounds.width / 4

class LeftMessageCell: UITableViewCell {
    @IBOutlet weak var view_date: UIView!
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var constraint_content: NSLayoutConstraint!
    
    @IBOutlet weak var constraint_pic: NSLayoutConstraint!
    @IBOutlet weak var constraint_time: NSLayoutConstraint!
    @IBOutlet weak var constraint_avatar: NSLayoutConstraint!
    @IBOutlet weak var view_avatar: UIView!
    
    @IBOutlet weak var img_pic: UIImageView!
    
    @IBOutlet weak var label_avatar: UILabel!
    @IBOutlet weak var label_time: UILabel!
    var vcP:ChatVC? = nil
    var message:Message? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        let shortImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(shortImageTap))
        img_pic.addGestureRecognizer(shortImageTapGesture)
        
        view_date.layer.cornerRadius = 8
        view_date.layer.borderWidth = 1
        view_date.layer.borderColor = UIColor(red: 200.0/255, green: 200.0/255, blue: 200.0/255, alpha: 1).cgColor
        view_date.layer.masksToBounds = true
    }
    @objc func shortImageTap(sender : UITapGestureRecognizer){
            print("Long tap")
            if vcP != nil {
                let vc = vcP?.storyboard?.instantiateViewController(withIdentifier: "ImageViewerVC") as! ImageViewerVC
                vc.photoUrl = message?.file.url
                vc.modalPresentationStyle = .fullScreen
                vcP?.present(vc, animated: true, completion: nil)
            }
        }
    
}
