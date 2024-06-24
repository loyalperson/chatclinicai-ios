//
//  MessageCell.swift
//  ChatClinic AI
//
//  Created by charmer on 6/4/24.
//

import UIKit
import CircleImageView

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var label_avatar: UILabel!
    @IBOutlet weak var view_avatar: UIView!
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var label_message: UILabel!
    @IBOutlet weak var label_time: UILabel!
    @IBOutlet weak var view_badge: UIView!
    @IBOutlet weak var label_badge: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
