//
//  BackgroundGradientView.swift
//  weather
//
//  Created by Lina on 1/26/22.
//

import UIKit

class BackgroundGradientView: UIView {

    let gradientLayer = CAGradientLayer()

    let lightColors = [
        UIColor(red: 108/255, green: 125/255, blue: 169/255, alpha: 1).cgColor,
        UIColor(red: 220/255, green: 180/255, blue: 180/255, alpha: 1).cgColor
    ]

    let darkColors = [
        UIColor(red: 91/255, green: 111/255, blue: 164/255, alpha: 1).cgColor,
        UIColor(red: 8/255, green: 17/255, blue: 40/255, alpha: 1).cgColor
    ]

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {

        if traitCollection.userInterfaceStyle == .light {
            gradientLayer.colors = lightColors
        } else {
            gradientLayer.colors = darkColors
        }
        gradientLayer.frame = bounds
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .light {
            gradientLayer.colors = lightColors
        } else {
            gradientLayer.colors = darkColors
        }
    }
}
