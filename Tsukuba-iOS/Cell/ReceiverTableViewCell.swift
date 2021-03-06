//
//  ReceiverTableViewCell.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 30/01/2018.
//  Copyright © 2018 MuShare. All rights reserved.
//

import UIKit

class ReceiverTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var unreadLabel: UILabel!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    var room: Room? {
        didSet {
            guard let room = room else {
                return
            }
            avatarImageView.kf.setImage(with: Config.shared.imageURL(room.receiverAvatar!))
            nameLabel.text = room.receiverName!
            let updateAt = room.updateAt! as Date
            if updateAt.isInToday {
                timeLabel.text = timeFormatter.string(for: updateAt)
            } else if updateAt.isInYesterday {
                timeLabel.text = R.string.localizable.yesterday_name()
            } else {
                timeLabel.text = dateFormatter.string(for: updateAt)
            }
            messageLabel.text = room.lastMessage
            if room.unread > 0 {
                unreadLabel.text = "\(room.unread)"
                unreadLabel.isHidden = false
            } else {
                unreadLabel.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
