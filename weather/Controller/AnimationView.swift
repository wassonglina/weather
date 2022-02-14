//
//  AnimationView.swift
//  weather
//
//  Created by Lina on 2/14/22.
//

import UIKit

class AnimationView: UIView {

    let anmiationGradientLayer = CAGradientLayer()

    let animation = CABasicAnimation(keyPath: "transform.translation.x")


    func defineAnimationGradient() {
        anmiationGradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        anmiationGradientLayer.locations = [0, 0.48, 0.52, 1]
        anmiationGradientLayer.startPoint = .init(x: 0.0, y: 0.5)
        anmiationGradientLayer.endPoint = .init(x: 1.0, y: 0.5)
    }


    func startAnmiation(layerInfo: UIView){

        //TODO: test from and to value on different devices (view.frame.width)
        animation.fromValue = -layerInfo.frame.width
        animation.toValue = layerInfo.frame.width
        animation.repeatCount = Float.infinity
        animation.duration = 1.7
        anmiationGradientLayer.add(animation, forKey: "Null")
    }



}
