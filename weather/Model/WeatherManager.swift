//
//  WeatherOperator.swift
//  weather
//
//  Created by Lina on 1/19/22.
//

import UIKit
import CoreLocation


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

    let currentWeatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=63f43c85a20418a56d7bd2c747992f0e&units=metric"

    //gives weather of today and next 5 days of every 3h
    let weatherForecastURL = "https://api.openweathermap.org/data/2.5/forecast?appid=63f43c85a20418a56d7bd2c747992f0e&units=metric"

    func requestCurrentCityURL(city: String, completion: @escaping (Result<CurrentModel, Error>) -> Void) {
        print(#function)
        let weatherURLString = "\(currentWeatherURL)&q=\(city.stringByAddingPercentEncodingForRFC3986()!)"
        perform(urlString: weatherURLString, transform: parseJSONCurrent, completion: completion)
    }

    func requestForecastCityURL(city: String, completion: @escaping (Result<[ForecastModel], Error>) -> Void) {
        print(#function)
        let forecastURLString = "\(weatherForecastURL)&q=\(city.stringByAddingPercentEncodingForRFC3986()!)"
        perform(urlString: forecastURLString, transform: parseJSONForecast, completion: completion)
    }

    func requestCurrentGeoURL(with coordinates: CLLocationCoordinate2D, completion: @escaping (Result<CurrentModel, Error>) -> Void) {
        print(#function)
        let weatherURLString = "\(currentWeatherURL)&lat=\(coordinates.latitude)&lon=\(coordinates.longitude)"
        perform(urlString: weatherURLString, transform: parseJSONCurrent, completion: completion)
        print(weatherURLString)
    }

    func requestForecastGeoURL(with coordinates: CLLocationCoordinate2D, completion: @escaping (Result<[ForecastModel], Error>) -> Void) {
        print(#function)
        let forecastURLString = "\(weatherForecastURL)&lat=\(coordinates.latitude)&lon=\(coordinates.longitude)"
        perform(urlString: forecastURLString, transform: parseJSONForecast, completion: completion)
    }


    //Generics: types not defined
    func perform<T>(urlString: String,
                    transform: @escaping (Data) throws -> T,      //T: Current or Forecast Models
                    completion: @escaping (Result<T, Error>) -> Void  //Result T > .success > Current or Forecast Models
    ) {
        performNetworkRequest(with: urlString) { result in

            switch result {
            case .success(let data):        // Network request successful:
                do {
                    let entity = try transform(data)  //transform calls parseJSONCurrent or parseJSONForecast
                    completion(.success(entity))      //if parsing success > data passed on
                } catch {
                    completion(.failure(error))     //if parsing failure > throws error
                    print("Error parsing JSON: \(error)")
                }
            case .failure(let error):       //Network request not succesful
                completion(.failure(error))
            }
        }
    }

    func performNetworkRequest(with urlString: String, completion: @escaping (Result<Data, Error>) -> Void ) {

        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    completion(.failure(error!))
                    return
                }
                if let weatherData = data {
                    completion(.success(weatherData))
                }
            }
            task.resume()
        }
    }

    func parseJSONCurrent(with encodedData: Data) throws -> CurrentModel {
        let decoder = JSONDecoder()

        let decodedWeather = try decoder.decode(OpenWeatherAPI.Current.self, from: encodedData)
        let decodedTemp = decodedWeather.main.temp
        let decodedName = decodedWeather.name
        let decodedCondition = decodedWeather.weather[0].id
        let sunrise = Date(timeIntervalSince1970: decodedWeather.sys.sunrise)
        let sunset = Date(timeIntervalSince1970: decodedWeather.sys.sunset)
        let answer = Date().isBetween(with: sunrise, with: sunset)
        let decodedMinTemp = decodedWeather.main.temp_min
        let decodedMaxTemp = decodedWeather.main.temp_max


        return CurrentModel(currentTemp: decodedTemp, minTemp: decodedMinTemp, maxTemp: decodedMaxTemp, condition: decodedCondition, name: decodedName, isNight: answer, isForecast: false)
    }

    func parseJSONForecast(with encodedData: Data) throws -> [ForecastModel] {
        let decoder = JSONDecoder()

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
    }
}
