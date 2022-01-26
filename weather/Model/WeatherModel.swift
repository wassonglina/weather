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

    var tempString: String {
        String(format: "%.0f ºC", temp)
    }

    var conditionString: String {
        switch condition {
        case 200..<300:
            return "cloud.colt"
        case 300..<400:
            return "cloud.drizzle"
        case 500..<600:
            return "cloud.rain"
        case 600..<700:
            return "cloud.snow"
        case 700..<800:
            return "sun.haze"
        case 800:
            return "sun.max"
        case 801..<900:
            return "cloud"
        default:
            return"cloud"
        }
    }

}
