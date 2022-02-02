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
    func didFetchForecast(with: ForecastModel)
    func didCatchError(error: Error)
}


struct WeatherOperator {

    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=63f43c85a20418a56d7bd2c747992f0e&units=metric"

    //gives weather of today and next 5 days
    let weatherForecastURL = "https://api.openweathermap.org/data/2.5/forecast?appid=63f43c85a20418a56d7bd2c747992f0e&units=metric"


    var delegate: WeatherManagerDelegate?

    func createCityURL(city: String) {
        let weatherURLString = "\(weatherURL)&q=\(city)"
        let forcastURLString = "\(weatherForecastURL)&q=\(city)"
        print(weatherURLString)
        performNetworkRequest(with: weatherURLString) { data in
            if let currentWeather = parseJSONWeather(with: data) {
                delegate?.didFetchWeather(with: currentWeather)
            }
        }
        performNetworkRequest(with: forcastURLString) { data in
            if let forecastWeather = parseJSONForecast(with: data) {
                delegate?.didFetchForecast(with: forecastWeather)
            }
        }
    }

    func createGeoURL(location: CLLocation) {
        let weatherURLString = "\(weatherURL)&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)"
        let forcastURLString = "\(weatherForecastURL)&lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)"
        print(weatherURLString)
        performNetworkRequest(with: weatherURLString) { data in
            if let currentWeather = parseJSONWeather(with: data) {
                delegate?.didFetchWeather(with: currentWeather)
            }
        }
        performNetworkRequest(with: forcastURLString) { data in
            if let forecastWeather = parseJSONForecast(with: data) {
                delegate?.didFetchForecast(with: forecastWeather)
            }
        }
    }


    func performNetworkRequest(with urlString: String, handler: @escaping (Data) -> Void ) {

        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didCatchError(error: error!)
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
                print("it's daytime")
                sunsetCheck = false
            } else {
                print ("it's night")
                sunsetCheck = true
            }

            let weatherModel = WeatherModel(temp: decodedTemp, name: decodedName, condition: decodedCondition, isNight: sunsetCheck)


            print(weatherModel)

            return weatherModel

        } catch {
            delegate?.didCatchError(error: error)
            return nil
        }
    }


    //ToDo: run this function in loop until data of every forecast day is retrived
    func parseJSONForecast(with encodedData: Data) -> ForecastModel? {
        let decoder = JSONDecoder()

        do {

            let decodedForecast = try decoder.decode(Forecast.self, from: encodedData)

            let filteredList = filterNoon(unfilteredList: decodedForecast.list)

//            let dayOfWeek = Date(timeIntervalSince1970: filteredList[0].dt)
//            let weekday = Calendar.current.component(.weekday, from: dayOfWeek)
//            let dayFormatter = DateFormatter()
//            let nameOfDay = dayFormatter.weekdaySymbols[Calendar.current.component(.weekday, from: dayOfWeek) - 1]
//
//            print("Weekday: \(weekday)")
//            print(nameOfDay)

            //filtering only list > name not in list
            let forecastTemp = filteredList[1].main.temp
            let forecastCondition = filteredList[1].weather[0].id
            let foracastDay = filteredList[1].dt

            let forecastModel = ForecastModel(day: foracastDay, temp: forecastTemp, condition: forecastCondition)

            print(forecastModel)

            return forecastModel

        } catch {
            delegate?.didCatchError(error: error)
            return nil
        }
    }
}

