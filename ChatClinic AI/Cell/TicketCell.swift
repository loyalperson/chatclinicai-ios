//
//  MessageCell.swift
//  ChatClinic AI
//
//  Created by charmer on 6/4/24.
//

import UIKit
import CircleImageView

class TicketCell: UITableViewCell {
    
    @IBOutlet weak var view_card: UIView!
    
    @IBOutlet weak var label_status: UILabel!
    @IBOutlet weak var view_status: UIView!
    @IBOutlet weak var label_referId: UILabel!
    @IBOutlet weak var label_email: UILabel!
    @IBOutlet weak var label_details: UILabel!
    @IBOutlet weak var label_no: UILabel!
    @IBOutlet weak var label_date: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        view_card.layer.borderColor = UIColor.lightGray.cgColor
        view_card.layer.borderWidth = 0.5
        view_card.layer.shadowColor = UIColor.darkGray.cgColor
        view_card.layer.shadowOpacity = 0.5
//        view_card.layer.shadowOffset = .zero
        view_card.layer.shadowOffset = CGSizeMake(3.0, 3.0);
        view_card.layer.shadowRadius = 3
//        view_card.dropShadowWithCornerRaduis()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

