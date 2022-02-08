//
//  WeatherModel.swift
//  weather
//
//  Created by Lina on 1/25/22.
//

import Foundation

struct WeatherModel {

    let temp: Double
    let condition: Int
    var isForecast: Bool
    let name: String?    //weather
    var isNight: Bool?   //weather
    let day: Int?       //Forecast


    var tempString: String {
        String(format: "%.0f ºC", temp)
    }

    func symbolName(isNight: Bool, isForecast: Bool) -> String {
        switch condition {
        case 200..<300:
            //Ternary Operator > Value = condition? ifTure : ifFalse
            if isForecast {
                return "cloud.bolt.fill"
            } else {
                return isNight ? "cloud.moon.bolt" : "cloud.bolt"
            }
        case 300..<400:
            if isForecast {
                return "cloud.drizzle.fill"
            } else {
                return isNight ? "cloud.moon.rain" : "cloud.drizzle"
            }
        case 500..<600:
            if isForecast {
                return "cloud.rain.fill"
            } else {
                return isNight ? "cloud.rain" : "cloud.rain"
            }
        case 600..<700:
            if isForecast {
                return "cloud.snow.fill"
            } else {
                return isNight ? "cloud.snow" : "cloud.snow"
            }
        case 700..<800:
            if isForecast {
                return "sun.haze.fill"
            } else {
                return isNight ? "cloud.moon" : "sun.haze"
            }
        case 800:
            if isForecast {
                return "sun.max.fill"
            } else {
                return isNight ? "moon.stars" : "sun.max"
            }
        case 801...802:
            if isForecast {
                return "cloud.sun.fill"
            } else {
                return isNight ? "cloud.moon" : "cloud.sun"
            }
        case 803...804:
            if isForecast {
                return "cloud.fill"
            } else {
                return isNight ? "cloud" : "cloud"
            }
        default:
            return "globe.europe.africa"
        }
    }


    func getDayOfWeek() -> String {
        let dayFormatter = DateFormatter()
        let dayOfWeek = Date(timeIntervalSince1970: Double(day!))
        let nameOfDay = dayFormatter.weekdaySymbols[Calendar.current.component(.weekday, from: dayOfWeek) - 1]
        print(nameOfDay)
        return nameOfDay
    }
}
