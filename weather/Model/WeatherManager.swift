//
//  WeatherOperator.swift
//  weather
//
//  Created by Lina on 1/19/22.
//

import UIKit
import CoreLocation

protocol WeatherManagerDelegate: AnyObject {
    func didFetchCurrent(with: CurrentModel)
    func didFetchForecast(with: [ForecastModel])
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


class WeatherManager {

    let placeholder = [
        1.3475,
        2.3556,
        5.5768
    ]

    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=63f43c85a20418a56d7bd2c747992f0e&units=metric"

    //gives weather of today and next 5 days of every 3h
    let weatherForecastURL = "https://api.openweathermap.org/data/2.5/forecast?appid=63f43c85a20418a56d7bd2c747992f0e&units=metric"

    //TODO: check weak > protocol conformance AnyObject?
    weak var delegate: WeatherManagerDelegate?

    func createCityURL(city: String) {
        print(#function)
        let weatherURLString = "\(weatherURL)&q=\(city.stringByAddingPercentEncodingForRFC3986()!)"
        let forcastURLString = "\(weatherForecastURL)&q=\(city.stringByAddingPercentEncodingForRFC3986()!)"
        print(forcastURLString)
        performNetworkRequest(with: weatherURLString) { data in
            
            if let currentWeather = self.parseJSONWeather(with: data) {
                self.delegate?.didFetchCurrent(with: currentWeather)
            }
        }
        performNetworkRequest(with: forcastURLString) { data in
            if let forecastWeather = self.parseJSONForecast(with: data) {
                self.delegate?.didFetchForecast(with: forecastWeather)
            }
        }
    }

    func createGeoURL(with coordinates: CLLocationCoordinate2D) {
        print(#function)
        let lat = coordinates.latitude
        let long = coordinates.longitude
        let weatherURLString = "\(weatherURL)&lat=\(lat)&lon=\(long)"
        let forcastURLString = "\(weatherForecastURL)&lat=\(lat)&lon=\(long)"
        performNetworkRequest(with: weatherURLString) { data in
            if let currentWeather = self.parseJSONWeather(with: data) {
                self.delegate?.didFetchCurrent(with: currentWeather)
            }
        }
        performNetworkRequest(with: forcastURLString) { data in
            if let forecastWeather = self.parseJSONForecast(with: data) {
                self.delegate?.didFetchForecast(with: forecastWeather)
             //   self.delegate?.
            }
        }
    }

    func performNetworkRequest(with urlString: String, handler: @escaping (Data) -> Void ) {

        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didCatchError(error: error!)
                    print("Error performing network request")
                    return
                }
                if let weatherData = data {
                    handler(weatherData)
                }
            }
            task.resume()
        }
    }

    func parseJSONWeather(with encodedData: Data) -> CurrentModel? {
        let decoder = JSONDecoder()

        do {
            let decodedWeather = try decoder.decode(OpenWeatherAPI.Current.self, from: encodedData)
            let decodedTemp = decodedWeather.main.temp
            let decodedName = decodedWeather.name
            let decodedCondition = decodedWeather.weather[0].id
            let sunrise = Date(timeIntervalSince1970: decodedWeather.sys.sunrise)
            let sunset = Date(timeIntervalSince1970: decodedWeather.sys.sunset)
            let answer = Date().isBetween(with: sunrise, with: sunset)

            return CurrentModel(temp: decodedTemp, condition: decodedCondition, name: decodedName, isNight: answer, isForecast: false)

        } catch {
            delegate?.didCatchError(error: error)
            return nil
        }
    }

    func parseJSONForecast(with encodedData: Data) -> [ForecastModel]? {
        let decoder = JSONDecoder()

        do {

            let decodedForecast = try decoder.decode(OpenWeatherAPI.Forecast.self, from: encodedData)
 //           let filteredList = filterNoon(unfilteredList: decodedForecast.list)
//            let highLowDay = []
//            let tempMin =
//            let tempMax =

//            let filteredList = filterDay(unfilteredList: decodedForecast, dayNumber: <#T##Int#>)

            //only get temp, weather id and date of filtered list
            let forecastModels: [ForecastModel] = decodedForecast.list.compactMap { list in
                let forecastTemp = list.main.temp
                let forecastCondition = list.weather[0].id
                let foracastDay = list.dt

                let today = Calendar.current.component(.weekday, from: Date())
                let foracastDate = Date(timeIntervalSince1970: Double(list.dt))
                let forecastWeekday = Calendar.current.component(.weekday, from: foracastDate)

                if forecastWeekday != today {
                    return ForecastModel(temp: forecastTemp, condition: forecastCondition, day: foracastDay, isForecast: true, isNight: false)
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
