////
////  MessagesController+handlers.swift
////  PipeLineChat
////
////  Created by Tuncay Cansız on 1.09.2019.
////  Copyright © 2019 Tuncay Cansız. All rights reserved.
////
//
//import UIKit
//import Firebase
//
//// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
//// Consider refactoring the code to use the non-optional operators.
//fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//    switch (lhs, rhs) {
//    case let (l?, r?):
//        return l < r
//    case (nil, _?):
//        return true
//    default:
//        return false
//    }
//}
//
//// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
//// Consider refactoring the code to use the non-optional operators.
//fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//    switch (lhs, rhs) {
//    case let (l?, r?):
//        return l > r
//    default:
//        return rhs < lhs
//    }
//}
//
//
//
//extension MessagesController{
//    
//    @objc func handleNewMessage() {
//        let newMessageController = NewMessageController()
//        newMessageController.messagesController = self
//        let navController = UINavigationController(rootViewController: newMessageController)
//        present(navController, animated: true, completion: nil)
//    }
//    
//    
//    func attemptReloadOfTable() {
//        self.timer?.invalidate()
//        
//        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
//    }
//    
//    var timer: Timer?
//    
//    @objc func handleReloadTable() {
//        self.messages = Array(self.messagesDictionary.values)
//        self.messages.sort(by: { (message1, message2) -> Bool in
//            
//            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
//        })
//        
//        //this will crash because of background thread, so lets call this on dispatch_async main thread
//        DispatchQueue.main.async(execute: {
//            self.tableView.reloadData()
//        })
//    }
//    
//    @objc func handleDeleteAllMessage(){
//        guard let uid = Auth.auth().currentUser?.uid else {
//            return
//        }
//        
//        let alert = UIAlertController(title: "Do you want to delete all conversations before you sign out?", message: "", preferredStyle: .alert)
//        //let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: nil)
//        //let okAction = UIAlertAction(title: "No", style: .default, handler: nil)
//        //alert.addAction(deleteAction)
//        //alert.addAction(okAction)
//        
//        
//        alert.addAction(UIAlertAction.init(title: "Delete", style: .destructive, handler: { (action) in
//            Database.database().reference().child("user-messages").child(uid).removeValue { (error, ref) in
//                
//                if error != nil {
//                    print("Failed to delete message:", error!)
//                    return
//                }
//                
//                self.messagesDictionary.removeValue(forKey: uid)
//                self.attemptReloadOfTable()
//                
//                //                //this is one way of updating the table, but its actually not that safe..
//                //                self.messages.removeAtIndex(indexPath.row)
//                //                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//            }
//            self.handleLogout()
//        }))
//        
//        alert.addAction(UIAlertAction.init(title: "No", style: .default, handler: { (action) in
//            self.handleLogout()
//        }))
//        
//        self.present(alert, animated: true, completion: nil)
//        
//        //        Database.database().reference().child("user-messages").child(uid).removeValue { (error, ref) in
//        //
//        //            if error != nil {
//        //                print("Failed to delete message:", error!)
//        //                return
//        //            }
//        //
//        //            self.messagesDictionary.removeValue(forKey: uid)
//        //            self.attemptReloadOfTable()
//        //
//        //            //                //this is one way of updating the table, but its actually not that safe..
//        //            //                self.messages.removeAtIndex(indexPath.row)
//        //            //                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//        //        }
//        //
//    }
//    
//}
