//
//  WeatherModel.swift
//  weather
//
//  Created by Lina on 1/25/22.
//

import Foundation

struct WeatherModel {

    let temp: Double
    let name: String
    let condition: Int
    var isNight: Bool

    var tempString: String {
        String(format: "%.0f ºC", temp)
    }

    func symbolName(isNight: Bool) -> String {
        switch condition {
        case 200..<300:
            //Ternary Operator > Value = condition? ifTure : ifFalse
            return isNight ? "cloud.moon.bolt" : "cloud.bolt"
        case 300..<400:
            return isNight ? "cloud.moon.rain" : "cloud.drizzle"
        case 500..<600:
            return isNight ? "cloud.rain" : "cloud.rain"
        case 600..<700:
            return isNight ? "cloud.snow" : "cloud.snow"
        case 700..<800:
            return isNight ? "cloud.moon" : "sun.haze"
        case 800:
            return isNight ? "moon.stars" : "sun.max"
        case 801...802:
            return isNight ? "cloud.moon" : "cloud.sun"
        case 803...804:
            return isNight ? "cloud" : "cloud"
        default:
            return "trash"
        }
    }
}
