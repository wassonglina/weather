//
//  WeatherOperator.swift
//  weather
//
//  Created by Lina on 1/19/22.
//

import Foundation
import CoreLocation


struct WeatherOperator {

    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=63f43c85a20418a56d7bd2c747992f0e&units=metric"

    func createCityURL(city: String) {
        let URLString = "\(weatherURL)&q=\(city)"
        print(URLString)
        performNetworkRequest(with: URLString)
    }

    func createGeoURL(location: CLLocation) {
        let URLString = "\(weatherURL)&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)"
        print(URLString)
        performNetworkRequest(with: URLString)
    }

    func performNetworkRequest(with urlString: String) {

        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    print("There was an error performing the network request: \(error).")
                    return
                }

                if let encodedData = data {
                    let dataString = String(data: encodedData, encoding: .utf8)
                    print(dataString)
                    }

                }

            task.resume()
            }



    }

    func parseJSON(){

    }

}
