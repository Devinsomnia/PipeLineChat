//
//  UserCell.swift
//  PipeLineChat
//
//  Created by Tuncay Cansız on 31.08.2019.
//  Copyright © 2019 Tuncay Cansız. All rights reserved.
//

import UIKit
import Firebase

//creating user cells.
//Kullanıcı hücreleri oluşturuluyor.
class UserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            
            detailTextLabel?.text = message?.text
            message?.imageUrl != nil ? detailTextLabel?.text = "Photo" : nil
            message?.videoUrl != nil ? detailTextLabel?.text = "Video" : nil
        
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
        }
    }
    
    fileprivate func setupNameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                    }
                }
                
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        //        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        NSLayoutConstraint.activate([profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
                                     profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                                     profileImageView.widthAnchor.constraint(equalToConstant: 48),
                                     profileImageView.heightAnchor.constraint(equalToConstant: 48)
                                    ])
        
        NSLayoutConstraint.activate([timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
                                     timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18),
                                     timeLabel.widthAnchor.constraint(equalToConstant: 100),
                                     timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!)
                                     ])

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
