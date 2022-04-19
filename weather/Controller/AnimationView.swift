//
//  AnimationView.swift
//  weather
//
//  Created by Lina on 2/14/22.
//

import UIKit

extension CAGradientLayer {

    static var loading: CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0, 0.48, 0.52, 1]
        layer.startPoint = .init(x: 0.0, y: 0.5)
        layer.endPoint = .init(x: 1.0, y: 0.5)
        return layer
    }
}

class LoadingView: UIView {

    let gradientLayer = CAGradientLayer.loading
    let animation = CABasicAnimation(keyPath: "transform.translation.x")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        animation.repeatCount = Float.infinity
        animation.duration = 1.7
        layer.mask = gradientLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        animation.fromValue = -self.frame.width
        animation.toValue = self.frame.width
        gradientLayer.frame = bounds
        gradientLayer.add(animation, forKey: "Null")
    }
}

class AnimationView: UIView {

    let labelGradientLayer = CAGradientLayer.loading

    let labelAnimation = CABasicAnimation(keyPath: "transform.translation.x")


    private func startAnmiationLabel(with layer: UILabel){
        //TODO: test from and to value on different devices (view.frame.width)
        labelAnimation.fromValue = -layer.frame.width
        labelAnimation.toValue = layer.frame.width
        labelAnimation.repeatCount = Float.infinity
        labelAnimation.duration = 1.7
        labelGradientLayer.add(labelAnimation, forKey: "Null")
    }



    func startAnimations(withCurrent currentView: UILabel) {
        startAnmiationLabel(with: currentView)
    }

}
