//
//  WeatherOperator.swift
//  weather
//
//  Created by Lina on 1/19/22.
//

import UIKit
import CoreLocation

protocol WeatherManagerDelegate {
    func didFetchWeather(with: WeatherModel)
    func didFetchForecast(with: [WeatherModel])
    func didCatchError(error: Error)
}

//filter characters for URL
extension String {
  func stringByAddingPercentEncodingForRFC3986() -> String? {
    let unreserved = "-._~/?"
    let allowed = NSMutableCharacterSet.alphanumeric()
    allowed.addCharacters(in: unreserved)
    return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
  }
}


class WeatherOperator {

    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=63f43c85a20418a56d7bd2c747992f0e&units=metric"

    //gives weather of today and next 5 days
    let weatherForecastURL = "https://api.openweathermap.org/data/2.5/forecast?appid=63f43c85a20418a56d7bd2c747992f0e&units=metric"

    var delegate: WeatherManagerDelegate?

    func createCityURL(city: String) {
        let weatherURLString = "\(weatherURL)&q=\(city.stringByAddingPercentEncodingForRFC3986()!)"
        let forcastURLString = "\(weatherForecastURL)&q=\(city.stringByAddingPercentEncodingForRFC3986()!)"
        print(weatherURLString)
        performNetworkRequest(with: weatherURLString) { data in
            print("HERE")
            if let currentWeather = self.parseJSONWeather(with: data) {
              //  print(currentWeather)
                self.delegate?.didFetchWeather(with: currentWeather)
            }
        }
        performNetworkRequest(with: forcastURLString) { data in
            if let forecastWeather = self.parseJSONForecast(with: data) {

                self.delegate?.didFetchForecast(with: forecastWeather)
            }
        }
    }

    func createGeoURL(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let weatherURLString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        let forcastURLString = "\(weatherForecastURL)&lat=\(latitude)&lon=\(longitude)"
        print(weatherURLString)
        performNetworkRequest(with: weatherURLString) { data in
            if let currentWeather = self.parseJSONWeather(with: data) {
                self.delegate?.didFetchWeather(with: currentWeather)
            }
        }
        performNetworkRequest(with: forcastURLString) { data in
            if let forecastWeather = self.parseJSONForecast(with: data) {
                self.delegate?.didFetchForecast(with: forecastWeather)
            }
        }
    }


    func performNetworkRequest(with urlString: String, handler: @escaping (Data) -> Void ) {

        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didCatchError(error: error!)
                    print("There was an error performing the network request: \(error!).")
                    return
                }
                if let weatherData = data {
                    handler(weatherData)
                }
            }
            task.resume()
        }
    }


    func parseJSONWeather(with encodedData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()

        do {

            let decodedWeather = try decoder.decode(WeatherDataModel.self, from: encodedData)
            let decodedTemp = decodedWeather.main.temp
            let decodedName = decodedWeather.name
            let decodedCondition = decodedWeather.weather[0].id
            let decodedTimeSunrise = decodedWeather.sys.sunrise
            let decodedTimeSunset = decodedWeather.sys.sunset

            let sunrise = Date(timeIntervalSince1970: decodedTimeSunrise)
            let sunset = Date(timeIntervalSince1970: decodedTimeSunset)
            let now = Date()
            var sunsetCheck: Bool

            if now > sunrise && now < sunset {
                sunsetCheck = false
            } else {
                sunsetCheck = true
            }

            return WeatherModel(temp: decodedTemp, condition: decodedCondition, isForecast: false, name: decodedName, isNight: sunsetCheck, day: nil)

        } catch {
            delegate?.didCatchError(error: error)
            return nil
        }
    }


    func parseJSONForecast(with encodedData: Data) -> [WeatherModel]? {
        let decoder = JSONDecoder()

        do {

            let decodedForecast = try decoder.decode(Forecast.self, from: encodedData)
            let filteredList = filterNoon(unfilteredList: decodedForecast.list)

            let forecastModels: [WeatherModel] = filteredList.compactMap { list in
                let forecastTemp = list.main.temp
                let forecastCondition = list.weather[0].id
                let foracastDay = list.dt

                let weekday = Calendar.current.component(.weekday, from: Date())
                let foracastDate = Date(timeIntervalSince1970: Double(list.dt))
                let forecastWeekday = Calendar.current.component(.weekday, from: foracastDate)

                if forecastWeekday != weekday {

                    return WeatherModel(temp: forecastTemp, condition: forecastCondition, isForecast: true, name: nil, isNight: false, day: foracastDay)
                } else {
                    return nil
                }
            }
            return forecastModels
        } catch {
            delegate?.didCatchError(error: error)
            return nil
        }
    }
}

