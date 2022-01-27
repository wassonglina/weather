//
//  WeatherOperator.swift
//  weather
//
//  Created by Lina on 1/19/22.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didFetchWeather(with: WeatherModel)
    func didCatchError(error: Error)
}


struct WeatherOperator {

    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=63f43c85a20418a56d7bd2c747992f0e&units=metric"

    //only works with lat and lon and not city
    let forecastURL =  "https://api.openweathermap.org/data/2.5/onecall?&appid=63f43c85a20418a56d7bd2c747992f0e&units=metric&lat=37.762209829748194&lon=-122.41902864360966"

    //gives weather of today and next 5 days
    let weatherForecastURL = "https://api.openweathermap.org/data/2.5/forecast?appid=63f43c85a20418a56d7bd2c747992f0e&units=metric"


    var delegate: WeatherManagerDelegate?

    func createCityURL(city: String) {
        let URLString = "\(weatherForecastURL)&q=\(city)"
        print(URLString)
        performNetworkRequest(with: URLString)
    }

    func createGeoURL(location: CLLocation) {
        let URLString = "\(weatherForecastURL)&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)"
        print(URLString)
        performNetworkRequest(with: URLString)
    }

    func performNetworkRequest(with urlString: String) {

        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didCatchError(error: error!)
                    print("There was an error performing the network request: \(error!).")
                    return
                }
                if let weatherData = data {
                    if let currentWeather = parseJSON(with: weatherData) {
                        delegate?.didFetchWeather(with: currentWeather)
                    }
                }
            }
            task.resume()
        }
    }


    func parseJSON(with encodedData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()

        do {

            let decodedForecast = try decoder.decode(Forecast.self, from: encodedData)
            let decodedTemp = decodedForecast.list[0].main.temp
            let decodedName = decodedForecast.city.name
            let decodedCondition = decodedForecast.list[0].weather[0].id

            let weatherModel = WeatherModel(temp: decodedTemp, name: decodedName, condition: decodedCondition)

            print(weatherModel)
            print(weatherModel.conditionString)
            print(weatherModel.tempString)

            return weatherModel

        } catch {
            delegate?.didCatchError(error: error)
            return nil
        }
    }

}
