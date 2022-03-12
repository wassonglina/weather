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

    public func monospacingNumbers() -> UIFont {
        // Replace these string keys with UIFontDescriptor.FeatureKey.type/.selector when possible.
        // As of Xcode 13 beta 5, the old deprecated keys (.featureIdentifier/.typeIdentifier) will
        // cause a crash. However, the new keys (.type/.selector) aren't available to Xcode 12, so
        // we can't use those either. So once we don't use Xcode 12 for development, we can use the
        // new keys. Or we can go back to using the deprecated keys if Apple fixes the crash.
        let fontFeature: [String: Any] = [
            "CTFeatureTypeIdentifier": kNumberSpacingType,
            "CTFeatureSelectorIdentifier": kMonospacedNumbersSelector,
        ]
        let attributes: [UIFontDescriptor.AttributeName: Any] = [
            .featureSettings: [fontFeature],
        ]
        let updatedFontDescriptor = self.fontDescriptor.addingAttributes(attributes)
        return UIFont(descriptor: updatedFontDescriptor, size: 0)
    }
}
