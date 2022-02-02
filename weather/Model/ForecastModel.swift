//
//  ForecastModel.swift
//  weather
//
//  Created by Lina on 1/27/22.
//

import Foundation


struct ForecastModel {

    let day: Double
    let temp: Double
    let condition: Int

    var tempString: String {
        String(format: "%.0f ºC", temp)
    }

    //more cases for a more accurate desciption (like thunder etc)
    var conditionString: String {
        switch condition {
        case 200..<300:
            return "cloud.bolt.fill"
        case 300..<400:
            return "cloud.drizzle.fill"
        case 500..<600:
            return "cloud.rain.fill"
        case 600..<700:
            return "cloud.snow.fill"
        case 700..<800:
            return "sun.haze.fill"
        case 800:
            return "sun.max.fill"
        case 801..<900:
            return "cloud.fill"
        default:
            return"cloud"
        }
    }


    func getDayOfWeek() -> String {
        let dayFormatter = DateFormatter()
        let dayOfWeek = Date(timeIntervalSince1970: day)
        let nameOfDay = dayFormatter.weekdaySymbols[Calendar.current.component(.weekday, from: dayOfWeek) - 1]
        print(nameOfDay)
        return nameOfDay
    }



}

