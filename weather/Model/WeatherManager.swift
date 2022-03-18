//
//  WeatherOperator.swift
//  weather
//
//  Created by Lina on 1/19/22.
//

import UIKit
import CoreLocation

protocol WeatherManagerDelegate: AnyObject {
    func didCatchError(error: NSError)
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

    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=63f43c85a20418a56d7bd2c747992f0e&units=metric"

    //gives weather of today and next 5 days of every 3h
    let weatherForecastURL = "https://api.openweathermap.org/data/2.5/forecast?appid=63f43c85a20418a56d7bd2c747992f0e&units=metric"

    weak var delegate: WeatherManagerDelegate?

    func createCityURL2(city: String, completion: @escaping (CurrentModel) -> Void) {
        print(#function)
        let weatherURLString = "\(weatherURL)&q=\(city.stringByAddingPercentEncodingForRFC3986()!)"
        print(weatherURLString)
        performNetworkRequest(with: weatherURLString) { data in
            if let currentWeather = self.parseJSONWeather(with: data) {
                completion(currentWeather)
            }
        }
    }

    func createCityURL(city: String, completion: @escaping ([ForecastModel]) -> Void) {
        print(#function)
        let forecastURLString = "\(weatherForecastURL)&q=\(city.stringByAddingPercentEncodingForRFC3986()!)"
        print(forecastURLString)
        performNetworkRequest(with: forecastURLString) { data in
            if let forecastWeather = self.parseJSONForecast(with: data) {
                completion(forecastWeather)
            }
        }
    }

    func createGeoURL(with coordinates: CLLocationCoordinate2D, completion: @escaping ([ForecastModel]) -> Void) {
        print(#function)
        let lat = coordinates.latitude
        let long = coordinates.longitude
        let forecastURLString = "\(weatherForecastURL)&lat=\(lat)&lon=\(long)"
        print(forecastURLString)
        performNetworkRequest(with: forecastURLString) { data in
            if let forecastWeather = self.parseJSONForecast(with: data) {
                completion(forecastWeather)
            }
        }
    }

    func createGeoURL2(with coordinates: CLLocationCoordinate2D, completion: @escaping (CurrentModel) -> Void) {
        print(#function)
        let lat = coordinates.latitude
        let long = coordinates.longitude
        let weatherURLString = "\(weatherURL)&lat=\(lat)&lon=\(long)"
        print(weatherURLString)
        performNetworkRequest(with: weatherURLString) { data in
            if let currentWeather = self.parseJSONWeather(with: data) {
                completion(currentWeather)
            }
        }
    }

    func performNetworkRequest(with urlString: String, handler: @escaping (Data) -> Void ) {

        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didCatchError(error: error! as NSError)
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
            let decodedMinTemp = decodedWeather.main.temp_min
            let decodedMaxTemp = decodedWeather.main.temp_max

            let lat = decodedWeather.coord.lat
            let long = decodedWeather.coord.lon

            print(lat, long)

            return CurrentModel(currentTemp: decodedTemp, minTemp: decodedMinTemp, maxTemp: decodedMaxTemp, condition: decodedCondition, name: decodedName, isNight: answer, isForecast: false, lat: lat, long: long)

        } catch {
            delegate?.didCatchError(error: error as NSError)
            return nil
        }
    }

    func parseJSONForecast(with encodedData: Data) -> [ForecastModel]? {
        let decoder = JSONDecoder()

        do {

            let decodedForecast = try decoder.decode(OpenWeatherAPI.Forecast.self, from: encodedData)

            //only get temp, weather id and date of filtered list
            let forecastModels: [ForecastModel] = decodedForecast.list.compactMap { list in
                let forecastTemp = list.main.temp
                let forecastCondition = list.weather[0].id
                let foracastDay = list.dt

                let today = Calendar.current.component(.weekday, from: Date())
                let foracastDate = Date(timeIntervalSince1970: Double(list.dt))
                let forecastWeekday = Calendar.current.component(.weekday, from: foracastDate)

                if forecastWeekday != today {
                    return ForecastModel(currentTemp: forecastTemp, condition: forecastCondition, day: foracastDay, isForecast: true, isNight: false)
                } else {
                    return nil
                }
            }
            return forecastModels
        } catch {
            delegate?.didCatchError(error: error as NSError)
            return nil
        }
    }
}
