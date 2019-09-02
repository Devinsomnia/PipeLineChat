//
//  ChatMessageCell.swift
//  PipeLineChat
//
//  Created by Tuncay Cansız on 31.08.2019.
//  Copyright © 2019 Tuncay Cansız. All rights reserved.
//

import UIKit
import AVFoundation


//creating chat message cells.
//mesaj hücreleri oluşturuluyor.
class ChatMessageCell: UICollectionViewCell {
    
    var message: Message?
    
    var chatLogController: ChatLogController?
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.translatesAutoresizingMaskIntoConstraints = false
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "PlayVideo")
        button.tintColor = UIColor.white
        button.setImage(image, for: .normal)
        
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        
        return button
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    @objc func handlePlay() {
        if let videoUrlString = message?.videoUrl, let url = URL(string: videoUrlString) {
            player = AVPlayer(url: url)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bubbleView.bounds
            bubbleView.layer.addSublayer(playerLayer!)
            
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            
            print("Attempting to play video......???")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        activityIndicatorView.stopAnimating()
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.clear
        tv.textColor = .white
        tv.isEditable = false
        return tv
    }()
    
    static let blueColor = UIColor.rgb(red: 0, green: 137, blue: 249, alpha: 1)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var messageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        
        return imageView
    }()
    
    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
        if message?.videoUrl != nil {
            return
        }
        
        if let imageView = tapGesture.view as? UIImageView {
            //PRO Tip: don't perform a lot of custom logic inside of a view class
            //PRO İpucu: Bir görünüm sınıfının içerisinde çok fazla özel mantık kullanma
            self.chatLogController?.performZoomInForStartingImageView(imageView)
        }
    }
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleViewRightAnchor: NSLayoutConstraint?
    var bubbleViewLeftAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        bubbleView.addSubview(messageImageView)
        NSLayoutConstraint.activate([messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor),
                                     messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
                                     messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor),
                                     messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor)
                                    ])
        
        bubbleView.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([activityIndicatorView.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                                     activityIndicatorView.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
                                     activityIndicatorView.widthAnchor.constraint(equalToConstant: 50),
                                     activityIndicatorView.heightAnchor.constraint(equalToConstant: 50)
                                    ])
    
        NSLayoutConstraint.activate([profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
                                     profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                                     profileImageView.widthAnchor.constraint(equalToConstant: 32),
                                     profileImageView.heightAnchor.constraint(equalToConstant: 32)
                                    ])
        
    
        bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleViewRightAnchor?.isActive = true
        bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        //bubbleViewLeftAnchor?.active = false
        
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        NSLayoutConstraint.activate([textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8),
                                     textView.topAnchor.constraint(equalTo: self.topAnchor),
                                     textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor),
                                     textView.heightAnchor.constraint(equalTo: self.heightAnchor)
                                    ])
    
        bubbleView.addSubview(playButton)
        NSLayoutConstraint.activate([playButton.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
                                     playButton.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
                                     playButton.widthAnchor.constraint(equalToConstant: 50),
                                     playButton.heightAnchor.constraint(equalToConstant: 50)
                                    ])
    
        bringSubviewToFront(playButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
