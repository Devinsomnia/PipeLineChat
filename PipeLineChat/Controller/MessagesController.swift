//
//  MessagesController.swift
//  PipeLineChat
//
//  Created by Tuncay Cansız on 30.08.2019.
//  Copyright © 2019 Tuncay Cansız. All rights reserved.
//


import UIKit
import Firebase
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class MessagesController: UITableViewController {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleDeleteAllMessage))
        
        let image = UIImage(named: "NewMessage")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
        checkIfUserIsLoggedIn()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    //To delete the message on the TableView by sliding it to the left.
    //TableView üzerinde ki mesajları sola kaydırarak silmek için.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }

                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
            })
        }
    }
    
    //Observes/checks user messages.
    //Kullanıcı mesajlarını gözlemler/kontrol eder.
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId)
            }, withCancel: nil)
            
        }, withCancel: nil)

        ref.observe(.childRemoved, with: { (snapshot) in
            //print(snapshot.key)
            //print(self.messagesDictionary)
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        }, withCancel: nil)
    }
    
    // Deletes all messages in the user id.
    //Kullanıcı id'sinde bulunan tüm mesajları siler.
    @objc func handleDeleteAllMessage(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let alert = UIAlertController(title: "Do you want to delete all conversations before you sign out?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Delete", style: .destructive, handler: { (action) in
            Database.database().reference().child("user-messages").child(uid).removeValue { (error, ref) in
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }
                self.messagesDictionary.removeValue(forKey: uid)
                self.attemptReloadOfTable()
            }
            self.handleLogout()
        }))

        alert.addAction(UIAlertAction.init(title: "No", style: .default, handler: { (action) in
            self.handleLogout()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //Fetch messages with message id.
    //Mesaj id ile mesajları getirir.
    fileprivate func fetchMessageWithMessageId(_ messageId: String) {
        let messagesReference = Database.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
        
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }
                self.attemptReloadOfTable()
            }
        }, withCancel: nil)
    }
    
    //Checks messages at 0.1 second intervals.
    //Mesaj listesini 0.1 saniye aralıklarla kontrol eder.
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    //Check the message list, edit the list if there are changes.
    //Mesaj listesini kontrol eder, değişiklik varsa listeyi düzenler.
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
        })
        
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
    
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    //Returns the height of the element for each element in the TableView.
    //TableView üzerinde ki herbir eleman için elemanın yükselik değerini döndürür.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    //Allows us to select objects on the TableView.
    //TableView üzerindeki nesneleri seçmemizi sağlar.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = User(dictionary: dictionary)
            user.id = chatPartnerId
            self.showChatControllerForUser(user)
            
        }, withCancel: nil)
    }
    
    //Fetch the NewMessageController page.
    //NewMessageController sayfasını çağırır.
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    //Controls the user's session.
    //Kullanıcının oturumunu kontrol eder.
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    //Fetch user name.
    //Kullanıcı isim bilgisini getirir.
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return //for some reason uid = nil
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.setupNavBarWithUser(user)
            }
        }, withCancel: nil)
    }
    
    //The user name and photo to be brought to Navbara are positioned.
    //Navbar'a getirilecek isim bilgisi ve fotoğraf konumlandırılıyor.
    func setupNavBarWithUser(_ user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        NSLayoutConstraint.activate([containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
                                     containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor)
                                    ])
        
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 15
        profileImageView.clipsToBounds = true
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        NSLayoutConstraint.activate([profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                                     profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                                     profileImageView.widthAnchor.constraint(equalToConstant: 30),
                                     profileImageView.heightAnchor.constraint(equalToConstant: 30)
                                     ])
    
        
        let nameLabel = UILabel()
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(nameLabel)
        NSLayoutConstraint.activate([nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8),
                                     nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
                                     nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor),
                                     nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor)
                                    ])
    
        
        self.navigationItem.titleView = titleView
    }
    
    //Fetch the ChatLogController page.
    //ChatLogController sayfasını çağırır.
    func showChatControllerForUser(_ user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    //User's closed the session and fetch the LoginController page.
    //Kullanıcı oturumu kapatır, LoginController sayfası çağırılır.
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
    
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
    }
}
