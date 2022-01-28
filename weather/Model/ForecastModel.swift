//
//  ForecastModel.swift
//  weather
//
//  Created by Lina on 1/27/22.
//

import Foundation


struct ForecastModel {

    let temp: Double
    let name: String
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


    func getDayOfWeek() {

    }



}

