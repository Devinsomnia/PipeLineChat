//
//  LoginController.swift
//  PipeLineChat
//
//  Created by Tuncay Cansız on 30.08.2019.
//  Copyright © 2019 Tuncay Cansız. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController{
    
    var messagesController: MessagesController?
    
    //All Object on the LoginController
    //LoginController üzerinde bulunan tüm nesneler
    var areaTop : UIView = {
        let area = UIView()
        area.translatesAutoresizingMaskIntoConstraints = false
        return area
    }()
    
    lazy var logo : UIImageView = {
        let logoImage = UIImage(named: "AppLogo_Register")
        let logo = UIImageView()
        logo.image = logoImage
        logo.clipsToBounds = true
        logo.contentMode = UIView.ContentMode.scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        logo.isUserInteractionEnabled = true
        return logo
    }()
    
    let areaBottom : UIView = {
        let area = UIView()
        area.translatesAutoresizingMaskIntoConstraints = false
        return area
    }()
    
    let textFieldTopSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor =  UIColor.rgb(red: 220, green: 220, blue: 220, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "User Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        tf.textColor = .white
        tf.textAlignment = .center
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let textFieldBottomSeparatorViewFirst: UIView = {
        let view = UIView()
        view.backgroundColor =  UIColor.rgb(red: 220, green: 220, blue: 220, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textFieldBottomSeparatorViewSecond: UIView = {
        let view = UIView()
        view.backgroundColor =  UIColor.rgb(red: 220, green: 220, blue: 220, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textFieldBottomSeparatorViewThird: UIView = {
        let view = UIView()
        view.backgroundColor =  UIColor.rgb(red: 220, green: 220, blue: 220, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let textFieldBottomSeparatorViewFourth : UIView = {
        let view = UIView()
        view.backgroundColor =  UIColor.rgb(red: 220, green: 220, blue: 220, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        tf.textColor = .white
        tf.textAlignment = .center
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        tf.textColor = .white
        tf.textAlignment = .center
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor =  .white
        button.setTitle("Register", for: UIControl.State())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.rgb(red: 28, green: 154, blue: 224, alpha: 1), for: UIControl.State())
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
        self.hideKeyboardWhenTappedAround()
        view.backgroundColor = UIColor.rgb(red: 30, green: 185, blue: 211, alpha: 1)
        setupMainController()
    }
    
    //For the purpose of dynamic control, carrier variables have been defined to make the restrictions active and passive (to be used only for the height of defined objects).
    //Dinamik kontrol amaçlı, kısıtlamaları(sadece tanımlanan nesnelerin yüksekliği için kullanıcılacak) aktif ve pasif yapmak amacıyla taşıyıcı değişkenler tanımlandı.
    var logoWidthAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var textFieldBottomSeparatorViewFirstHeightAnchor: NSLayoutConstraint?
    
    //All Object on LoginController are located here.
    //LoginController üzerinde bulunan tüm nesneler burada konumlandırılıyor.
    func setupMainController(){
        view.addSubview(areaTop)
        NSLayoutConstraint.activate([areaTop.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: (Device.screenHeight * 5) / 100),
                                     areaTop.leftAnchor.constraint(equalTo: view.leftAnchor, constant: (Device.screenHeight * 5) / 100),
                                     areaTop.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -(Device.screenHeight * 5) / 100),
                                     areaTop.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -(Device.screenHeight * 8) / 100)
                                     ])
        
        areaTop.addSubview(logo)
        logoWidthAnchor = logo.widthAnchor.constraint(equalTo: areaTop.widthAnchor, multiplier: 1)
        logoWidthAnchor?.isActive = true
        NSLayoutConstraint.activate([logo.heightAnchor.constraint(equalTo: areaTop.heightAnchor, multiplier: 2/3),
                                     logo.centerYAnchor.constraint(equalTo: areaTop.centerYAnchor),
                                     logo.centerXAnchor.constraint(equalTo: areaTop.centerXAnchor)
                                     ])
        
        view.addSubview(areaBottom)
        NSLayoutConstraint.activate([areaBottom.topAnchor.constraint(equalTo: areaTop.bottomAnchor, constant: (Device.screenHeight * 2) / 100),
                                     areaBottom.leftAnchor.constraint(equalTo: view.leftAnchor, constant: (Device.screenHeight * 5) / 100),
                                     areaBottom.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -(Device.screenHeight * 5) / 100)
                                    ])
    
        view.addSubview(loginRegisterSegmentedControl)
        NSLayoutConstraint.activate([loginRegisterSegmentedControl.topAnchor.constraint(equalTo: areaTop.bottomAnchor, constant: (Device.screenHeight * 2) / 100),
                                     loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: areaBottom.widthAnchor),
                                     loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: areaBottom.centerXAnchor),
                                     loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36)
            ])
    
        areaBottom.addSubview(textFieldTopSeparatorView)
        NSLayoutConstraint.activate([textFieldTopSeparatorView.topAnchor.constraint(equalTo: loginRegisterSegmentedControl.bottomAnchor,constant: (Device.screenHeight * 2) / 100),
                                     textFieldTopSeparatorView.leftAnchor.constraint(equalTo: areaBottom.leftAnchor),
                                     textFieldTopSeparatorView.rightAnchor.constraint(equalTo: areaBottom.rightAnchor),
                                     textFieldTopSeparatorView.heightAnchor.constraint(equalToConstant: 1)
                                     ])
        
        areaBottom.addSubview(nameTextField)
        nameTextFieldHeightAnchor =  nameTextField.heightAnchor.constraint(equalToConstant: 40)
        nameTextFieldHeightAnchor?.isActive = true
        NSLayoutConstraint.activate([nameTextField.widthAnchor.constraint(equalTo: areaBottom.widthAnchor),
                                     nameTextField.topAnchor.constraint(equalTo: textFieldTopSeparatorView.bottomAnchor),
                                     ])
        
        areaBottom.addSubview(textFieldBottomSeparatorViewFirst)
        textFieldBottomSeparatorViewFirstHeightAnchor = textFieldBottomSeparatorViewFirst.heightAnchor.constraint(equalToConstant: 1)
        textFieldBottomSeparatorViewFirstHeightAnchor?.isActive = true
        NSLayoutConstraint.activate([textFieldBottomSeparatorViewFirst.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
                                     textFieldBottomSeparatorViewFirst.leftAnchor.constraint(equalTo: areaBottom.leftAnchor),
                                     textFieldBottomSeparatorViewFirst.rightAnchor.constraint(equalTo: areaBottom.rightAnchor)
                                     ])
        
        areaBottom.addSubview(emailTextField)
        NSLayoutConstraint.activate([emailTextField.widthAnchor.constraint(equalTo: areaBottom.widthAnchor),
                                     emailTextField.topAnchor.constraint(equalTo: textFieldBottomSeparatorViewFirst.bottomAnchor),
                                     emailTextField.heightAnchor.constraint(equalToConstant: 40)
                                     ])

        areaBottom.addSubview(textFieldBottomSeparatorViewSecond)
        NSLayoutConstraint.activate([textFieldBottomSeparatorViewSecond.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
                                     textFieldBottomSeparatorViewSecond.leftAnchor.constraint(equalTo: areaBottom.leftAnchor),
                                     textFieldBottomSeparatorViewSecond.rightAnchor.constraint(equalTo: areaBottom.rightAnchor),
                                     textFieldBottomSeparatorViewSecond.heightAnchor.constraint(equalToConstant: 1)
                                    ])
        
        areaBottom.addSubview(passwordTextField)
        NSLayoutConstraint.activate([passwordTextField.widthAnchor.constraint(equalTo: areaBottom.widthAnchor),
                                     passwordTextField.heightAnchor.constraint(equalToConstant: 40),
                                     passwordTextField.topAnchor.constraint(equalTo: textFieldBottomSeparatorViewSecond.bottomAnchor)
                                    ])
        
        areaBottom.addSubview(textFieldBottomSeparatorViewThird)
        NSLayoutConstraint.activate([textFieldBottomSeparatorViewThird.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
                                     textFieldBottomSeparatorViewThird.leftAnchor.constraint(equalTo: areaBottom.leftAnchor),
                                     textFieldBottomSeparatorViewThird.rightAnchor.constraint(equalTo: areaBottom.rightAnchor),
                                     textFieldBottomSeparatorViewThird.heightAnchor.constraint(equalToConstant: 1)
                                    ])

        areaBottom.addSubview(textFieldBottomSeparatorViewFourth)
        NSLayoutConstraint.activate([textFieldBottomSeparatorViewFourth.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor),
                                     textFieldBottomSeparatorViewFourth.leftAnchor.constraint(equalTo: areaBottom.leftAnchor),
                                     textFieldBottomSeparatorViewFourth.rightAnchor.constraint(equalTo: areaBottom.rightAnchor),
                                     textFieldBottomSeparatorViewFourth.heightAnchor.constraint(equalToConstant: 1)
                                    ])

        areaBottom.addSubview(loginRegisterButton)
        NSLayoutConstraint.activate([loginRegisterButton.topAnchor.constraint(equalTo: textFieldBottomSeparatorViewFourth.bottomAnchor, constant: (Device.screenHeight * 2) / 100),
                                     loginRegisterButton.leftAnchor.constraint(equalTo: areaBottom.leftAnchor, constant: (Device.screenHeight * 8) / 100),
                                     loginRegisterButton.rightAnchor.constraint(equalTo: areaBottom.rightAnchor,constant: -(Device.screenHeight * 8) / 100),
                                     loginRegisterButton.heightAnchor.constraint(equalToConstant: 50),
                                     areaBottom.bottomAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor)
                                    ])
    }
}


