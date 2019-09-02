//
//  UIColorExtension.swift
//  PipeLineChat
//
//  Created by Tuncay Cansız on 30.08.2019.
//  Copyright © 2019 Tuncay Cansız. All rights reserved.
//

import UIKit

extension UIColor{
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor{
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}
