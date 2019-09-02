//
//  LoginController+handlers.swift
//  PipeLineChat
//
//  Created by Tuncay Cansız on 30.08.2019.
//  Copyright © 2019 Tuncay Cansız. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleLoginRegisterChange() {
        loginRegisterSegmentedControl.selectedSegmentIndex == 1 ? (logo.isUserInteractionEnabled = true) : (logo.isUserInteractionEnabled = false)
        
        let loginImage = UIImage(named: "AppLogo")
        let registerImage = UIImage(named: "AppLogo_Register")
        
        loginRegisterSegmentedControl.selectedSegmentIndex == 1 ? (logo.image = registerImage) : (logo.image = loginImage)
        
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: UIControl.State())
        
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalToConstant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 40)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0
        
        textFieldBottomSeparatorViewFirstHeightAnchor?.isActive = false
        textFieldBottomSeparatorViewFirstHeightAnchor = textFieldBottomSeparatorViewFirst.heightAnchor.constraint(equalToConstant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1)
        textFieldBottomSeparatorViewFirstHeightAnchor?.isActive = true
        textFieldBottomSeparatorViewFirst.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0
    }
    
    @objc func handleLoginRegister() {
        loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? handleLogin() : handleRegister()
    }

    //User Register
    //Kullanıcı kayıt
    func handleRegister() {
        loginRegisterButton.isEnabled = false
        if self.logo.image == nil || self.logo.image == UIImage(named: "AppLogo_Register"){
            let alert = UIAlertController(title: "Error", message: "You should upload a photo of you!\n Touch the logo for add photo", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.loginRegisterButton.isEnabled = true
            self.present(alert, animated: true, completion: nil)
        }
        else {
            guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
                print("Form is not valid")
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password, completion: { (res, error) in
                
                //User Errors during registration are checked here.
                //Kayıt sırasında oluşacak hatalar burada kontrol edilmektedir.
                if error != nil {
                    if self.nameTextField.text?.count == 0 || self.nameTextField.text!.count < 4{
                        let alert = UIAlertController(title: "Error", message: "Name cannot be blank! \n Name must be at least 4 characters!", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.loginRegisterButton.isEnabled = true
                        self.present(alert, animated: true, completion: nil)
                    }
                    else if self.emailTextField.text?.count == 0 && self.passwordTextField.text?.count == 0 {
                        let alert = UIAlertController(title: "Error", message: "Email and Password cannot be blank!", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.loginRegisterButton.isEnabled = true
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    if self.passwordTextField.text?.count == 0 {
                        let alert = UIAlertController(title: "Error", message: "Password cannot be blank!", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.loginRegisterButton.isEnabled = true
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    else if self.passwordTextField.text!.count < 6 {
                        let alert = UIAlertController(title: "Error", message: "password must be at least 6 characters!", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.loginRegisterButton.isEnabled = true
                        self.present(alert, animated: true, completion: nil)
                    }
                    print("Hata Kodu: ",error!._code)
                    self.handleError(error!)
                    self.loginRegisterButton.isEnabled = true
                    return
                }
            
                guard let uid = res?.user.uid else {
                    return
                }
                
                // The quality of the profile photo decreases in order not to be included in the database.
                //Kalite düşürülerek, profil fotoğrafının database üzerinde çok fazla yer kaplamaması için sıkıştırma işlemi yapılmaktadır.
                let imageName = UUID().uuidString
                let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
                
                if let profileImage = self.logo.image, let uploadData = profileImage.jpegData(compressionQuality: 0.1){
                    storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
                        if let error = error {
                            print(error)
                            return
                        }
                    
                        storageRef.downloadURL(completion: { (url, err) in
                            if let err = err {
                                print(err)
                                return
                            }
                            
                            guard let url = url else { return }
                            let values = ["name": name, "email": email, "profileImageUrl": url.absoluteString]
                            self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                        })
                    })
                }
            })
        }
    }
    
    //The user is saved selected database.
    //Kullanıcı belirtilen database'e kaydedilir.
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference(fromURL: "https://pipelinechat.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                print(err)
                return
            }
            
            let user = User(dictionary: values)
            self.messagesController?.setupNavBarWithUser(user)
            self.loginRegisterButton.isEnabled = true
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true) {
            self.logo.image = nil
        }
    }
    
    //The gallery opens to select a profile photo.
    //Galeri, bir profil fotoğrafı seçmek için çağrılır.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            logo.image = selectedImage
            logoWidthAnchor?.isActive = false
            logoWidthAnchor = logo.widthAnchor.constraint(equalToConstant: 150)
            logo.layer.cornerRadius = 75
            logoWidthAnchor?.isActive = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    //The gallery is closed.
    //Galeri kapatılır.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        let registerImage = UIImage(named: "AppLogo_Register")
        logo.image = registerImage
        dismiss(animated: true, completion: nil)
    }
    
    //User Login.
    //Kullanıcı giriş.
    func handleLogin() {
        loginRegisterButton.isEnabled = false
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            //User Errors during login are checked here.
            //Login sırasında oluşacak hatalar burada kontrol edilmektedir.
            if error != nil {
                if self.emailTextField.text?.count == 0 && self.passwordTextField.text?.count == 0 {
                    let alert = UIAlertController(title: "Error", message: "Email and Password cannot be blank!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.loginRegisterButton.isEnabled = true
                    self.present(alert, animated: true, completion: nil)
                }
                
                if self.passwordTextField.text?.count == 0 {
                    let alert = UIAlertController(title: "Error", message: "Password cannot be blank!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.loginRegisterButton.isEnabled = true
                    self.present(alert, animated: true, completion: nil)
                }
                else if self.passwordTextField.text!.count < 6 {
                    let alert = UIAlertController(title: "Error", message: "password must be at least 6 characters!", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.loginRegisterButton.isEnabled = true
                    self.present(alert, animated: true, completion: nil)
                }
                self.handleError(error!)
                self.loginRegisterButton.isEnabled = true
                return
            }
            self.loginRegisterButton.isEnabled = true
            self.messagesController?.fetchUserAndSetupNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        })
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
