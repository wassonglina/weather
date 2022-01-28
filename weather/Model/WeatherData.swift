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


struct List: Decodable {
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



