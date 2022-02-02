//
//  WeatherModel.swift
//  weather
//
//  Created by Lina on 1/25/22.
//

import Foundation


struct WeatherDataModel: Decodable {
    let name: String
    let main: Main
    let weather: [Weather]
    let sys: Sys
}

struct Forecast: Decodable {
    let city: City
    let list: [List]
}

protocol DateContaining {
    var dt: Double { get }
}

struct List: Decodable, DateContaining {
    let dt: Double
    let main: Main
    let weather: [Weather]

}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let id: Int
}

struct City: Decodable {
    let name: String
}

struct Sys: Decodable {
    let sunrise: Double
    let sunset: Double
}

//concept of generics: Generic code enables you to write flexible, reusable functions and types that can work with any type
func filterNoon<T: DateContaining>(unfilteredList: [T]) -> [T] {

    let filteredList = unfilteredList.filter { item in
        let date = Date(timeIntervalSince1970: item.dt)
        let components = Calendar.current.dateComponents(in: .current, from: date)

        return (11...13).contains(components.hour!)
 //       return components.hour == 12
    }
    return filteredList
}
