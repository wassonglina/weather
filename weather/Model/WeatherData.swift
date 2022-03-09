//
//  WeatherModel.swift
//  weather
//
//  Created by Lina on 1/25/22.
//

import Foundation

struct OpenWeatherAPI {

    struct Current: Decodable {
        let name: String
        let main: Temperature
        let weather: [Weather]
        let sys: Sys

        struct Sys: Decodable {
            let sunrise: Double
            let sunset: Double
        }
    }

    struct Forecast: Decodable {
        let city: City
        let list: [Entry]

        struct City: Decodable {
            let name: String
        }

        struct Entry: Decodable, DateContaining {
            let dt: Int //Date
            let main: Temperature
            let weather: [Weather]
        }
    }

    struct Temperature: Decodable {
        let temp: Double
        let temp_min: Double
        let temp_max: Double
    }

    struct Weather: Decodable {
        let id: Int
    }

}

protocol DateContaining {
    var dt: Int { get }
}

//Generics > flexible, reusable functions and types > [T]
func filterNoon<T: DateContaining>(unfilteredList: [T]) -> [T] {

    let filteredList = unfilteredList.filter { item in

        //creates the day of timestamp dt > prints:
        //2022-03-13 18:00:00 +0000
        let date = Date(timeIntervalSince1970: Double(item.dt))

        //gives infos of choosen calendar fo date > prints:
        //calendar: gregorian (current) timeZone: America/Los_Angeles (fixed (equal to current)) era: 1 year: 2022 month: 3 day: 13 hour: 11 minute: 0 second: 0 nanosecond: 0 weekday: 1 weekdayOrdinal: 2 quarter: 0 weekOfMonth: 3 weekOfYear: 12 yearForWeekOfYear: 2022 isLeapMonth: false
        let components = Calendar.current.dateComponents(in: .current, from: date)

        return (11...13).contains(components.hour!)
    }
    return filteredList
}

//TODO: function is for todays weather:
func getMaxDay(unfilteredList: [OpenWeatherAPI.Forecast.Entry]) -> Double {

    let temp: [Double] = unfilteredList.map { item in
        let max = item.main.temp_max
        return max
    }
    return temp.max()!
}

func getMinDay(unfilteredList: [OpenWeatherAPI.Forecast.Entry]) -> Double {

    let temp: [Double] = unfilteredList.map { item in
        let min = item.main.temp_min
        return min
    }
    return temp.min()!
}

//TODO: function is for forecast weather:
func filterDay(unfilteredList: [ForecastModel], dayNumber: Int) -> [ForecastModel] {

    var forecastDay =  Date.now

//    let now = Date.now

    switch dayNumber {
    case 1:
        forecastDay = Date.now.addingTimeInterval(86400)  //1 Day
    case 2:
        forecastDay = Date.now.addingTimeInterval(172800)  //2 Days
    case 3:
        forecastDay = Date.now.addingTimeInterval(259200)  //3 Days
    case 4:
        forecastDay = Date.now.addingTimeInterval(345600)  //4 Days
    default:
        print("Error getting values for current day.")
    }

    let forecastDayComponent = Calendar.current.dateComponents(in: .current, from: forecastDay).day  //15

    let filteredList = unfilteredList.filter { item in

        let date = Date(timeIntervalSince1970: Double(item.day!))
        let dayComponent = Calendar.current.dateComponents(in: .current, from: date).day
        return dayComponent == forecastDayComponent
    }
    print(filteredList)
    return filteredList
}

func minTemp(unfilteredList: [ForecastModel]) -> Double {
    let temp: [Double] = unfilteredList.map { item in
        return item.temp
    }
    return temp.min()!
}

func maxTemp(unfilteredList: [ForecastModel]) -> Double {
    let temp: [Double] = unfilteredList.map { item in
        return item.temp
    }
    return temp.max()!

}



//extension Array where Element: DateContaining {
//    func filterNoon() -> 
//}
