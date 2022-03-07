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

    let animationForecast = CABasicAnimation(keyPath: "transform.translation.x")
    let animationLabel = CABasicAnimation(keyPath: "transform.translation.x")

    let animationColors = [
        UIColor.clear.cgColor,
        UIColor.white.cgColor,
        UIColor.white.cgColor,
        UIColor.clear.cgColor
    ]

    //TODO: only one function
    func defineLabelGradient() {
        labelGradientLayer.colors = animationColors
        labelGradientLayer.locations = [0, 0.48, 0.52, 1]
        labelGradientLayer.startPoint = .init(x: 0.0, y: 0.5)
        labelGradientLayer.endPoint = .init(x: 1.0, y: 0.5)
    }

    func defineForecastGradient() {
        forecastGradientLayer.colors = animationColors
        forecastGradientLayer.locations = [0, 0.48, 0.52, 1]
        forecastGradientLayer.startPoint = .init(x: 0.0, y: 0.5)
        forecastGradientLayer.endPoint = .init(x: 1.0, y: 0.5)
    }

    func startAnmiationLabel(with layer: UILabel){
        //TODO: test from and to value on different devices (view.frame.width)
        animationLabel.fromValue = -layer.frame.width
        animationLabel.toValue = layer.frame.width
        animationLabel.repeatCount = Float.infinity
        animationLabel.duration = 1.7
        labelGradientLayer.add(animationLabel, forKey: "Null")
    }

    func startAnmiationForecast(with layer: UIView){
        //TODO: test from and to value on different devices (view.frame.width)
        animationForecast.fromValue = -layer.frame.width
        animationForecast.toValue = layer.frame.width
        animationForecast.repeatCount = Float.infinity
        animationForecast.duration = 1.7
        forecastGradientLayer.add(animationForecast, forKey: "Null")
    }
}
