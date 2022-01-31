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

//    func symbolName(isNight: Bool) -> String {
//        switch condition {
//        case 200..<300:
////            return isNight ? "asdfsadf" : "sdf"
//            if isNight {
//                return "asdfsadf"
//            } else {
//
//            } "sdf"
//        case 900:
//            return "gasdfsadf"
//        }
//    }

    var conditionString: String {
        switch condition {
        case 200..<300:
            return "cloud.bolt"
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
        case 801...802:
            return "cloud.sun"
        case 803...804:
            return "cloud"
        case 901:
            return "cloud.moon.bolt"
        case 902:
            return "cloud.moon.rain"
        case 903:
            return "cloud.rain"
        case 904:
            return "cloud.snow"
        case 905:
            return "cloud.moon"
        case 906:
            return "moon.stars"
        case 907:
            return "cloud.moon"
        case 908:
            return "cloud"
        default:
            return"cloud"
        }
    }
}
