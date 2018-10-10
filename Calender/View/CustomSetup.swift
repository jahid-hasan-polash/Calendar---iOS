//
//  CustomSetup.swift
//  Calender
//
//  Created by Jahid Hasan Polash on 6/8/18.
//  Copyright © 2018 sawanmind. All rights reserved.
//

import UIKit

public class CustomSetup {
    static let labelFont: UIFont = UIDevice.current.userInterfaceIdiom == .pad ? UIFont.systemFont(ofSize: 24) : UIFont.systemFont(ofSize: 16)
    static let boldLabelFont: UIFont = UIDevice.current.userInterfaceIdiom == .pad ? UIFont.boldSystemFont(ofSize: 24) : UIFont.boldSystemFont(ofSize: 16)
    static let selectorColor: UIColor = UIColor.red
    static let selectedBackgroundColor: UIColor = UIColor.purple
}
