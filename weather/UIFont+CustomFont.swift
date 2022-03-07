//
//  UIFont+CustomFont.swift
//  weather
//
//  Created by Lina on 3/7/22.
//

import UIKit


public enum FontStyle {
    case regular
    case medium
}

extension UIFont {

    static func scriptFont(size: CGFloat, style: FontStyle) -> UIFont {

        switch style {
        case .regular:
            return UIFont(name: "AvenirNext-Regular", size: size)!
        case .medium:
            return UIFont(name: "AvenirNext-Medium", size: size)!
        }
    }
}
