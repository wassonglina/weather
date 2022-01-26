//
//  BackgroundGradientView.swift
//  weather
//
//  Created by Lina on 1/26/22.
//

import UIKit

class BackgroundGradientView: UIView {

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {

        let topColor = UIColor(red: 108/255, green: 125/255, blue: 169/255, alpha: 1)
        let bottomColor =   UIColor(red: 220/255, green: 180/255, blue: 180/255, alpha: 1)

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            topColor.cgColor,
            bottomColor.cgColor
        ]

        layer.addSublayer(gradientLayer)
    }
}
