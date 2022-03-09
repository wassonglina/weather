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
            let dt: Int
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


//get all min and max of same day > add date and filter (instead of map) all temps for same day

//
//func getMinMaxDay(unfilteredList: [List]) -> (day: Date, min: Double, max: Double) {
//
//    let date: Date
//    let min: Double
//    let max: Double
//
//    let temp: [Double] = unfilteredList.map { item in
//        let min = item.main.temp_min
//        return min
//    }
//    return temp.min()!
//}

//func getMaxOneDay(unfilteredList: [List]) -> Double {
//
//    let temp = unfilteredList.filter { <#List#> in
//        <#code#>
//    }
//
//}





//extension Array where Element: DateContaining {
//    func filterNoon() -> 
//}
