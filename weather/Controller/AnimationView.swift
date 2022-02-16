//
//  AnimationView.swift
//  weather
//
//  Created by Lina on 2/14/22.
//

import UIKit

class AnimationView: UIView {

    let forecastGradientLayer = CAGradientLayer()

    let labelGradientLayer = CAGradientLayer()

    let animation = CABasicAnimation(keyPath: "transform.translation.x")

    let animation2 = CABasicAnimation(keyPath: "transform.translation.x")


    //TODO: only one function
    func defineLabelGradient() {
        labelGradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        labelGradientLayer.locations = [0, 0.48, 0.52, 1]
        labelGradientLayer.startPoint = .init(x: 0.0, y: 0.5)
        labelGradientLayer.endPoint = .init(x: 1.0, y: 0.5)
    }


    func defineAnimationGradient() {
        forecastGradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        forecastGradientLayer.locations = [0, 0.48, 0.52, 1]
        forecastGradientLayer.startPoint = .init(x: 0.0, y: 0.5)
        forecastGradientLayer.endPoint = .init(x: 1.0, y: 0.5)
    }

    func startAnmiation2(with layer: UILabel){
        //TODO: test from and to value on different devices (view.frame.width)
        animation2.fromValue = -layer.frame.width
        animation2.toValue = layer.frame.width
        animation2.repeatCount = Float.infinity
        animation2.duration = 1.7
        labelGradientLayer.add(animation2, forKey: "Null")
    }


    func startAnmiation(with layer: UIView){

        //TODO: test from and to value on different devices (view.frame.width)
        animation.fromValue = -layer.frame.width
        animation.toValue = layer.frame.width
        animation.repeatCount = Float.infinity
        animation.duration = 1.7
        forecastGradientLayer.add(animation, forKey: "Null")
    }



}
