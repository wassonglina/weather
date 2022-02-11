//
//  ViewModel.swift
//  weather
//
//  Created by Lina on 2/2/22.
//

import UIKit
import CoreLocation


protocol ViewModelDelegate {
    func updateWeatherUI(city: String, temperature: String, image: UIImage, forecastImage: UIImage, forecastTemp: String)

    func updateForecastUI(dayOfWeek: String, forecastImage: UIImage, forecastTemp: String)
}


class WeatherViewModel: NSObject, WeatherManagerDelegate, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()

    var delegate: ViewModelDelegate?

    let weatherOperator = WeatherOperator()

    override init() {
        super.init()
        weatherOperator.delegate = self
        locationManager.delegate = self
    }

    enum WeatherLocation: Equatable {
        case currentLocation
        case city(String)
    }

    var weatherLocation: WeatherLocation? {
        didSet {
            switch weatherLocation {
            case .currentLocation:
                locationManager.requestWhenInUseAuthorization()
                locationManager.requestLocation()
            case .city(let cityname):
                weatherOperator.createCityURL(city: cityname)
            case nil:
                break
            }
        }
    }

    func getWeatherCity(with cityname: String) {
        weatherLocation = .city(cityname)
    }

    func getWeatherLocation() {
        weatherLocation = .currentLocation
    }

    func didFetchWeather(with currentWeather: WeatherModel) {

        let city = currentWeather.name!
        let temp = currentWeather.tempString
        let image = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast))")!

        let conditionImage = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast)).fill")!
        let forecastTemp = currentWeather.tempString

        delegate?.updateWeatherUI(city: city, temperature: temp, image: image, forecastImage: conditionImage, forecastTemp: forecastTemp)
    }

    func didFetchForecast(with: [WeatherModel]) {

        let dayOfWeek = "Monday"
    let forecastImage = UIImage(systemName: "sun.max.fill")!
    let forecastTemp = "13"

        delegate?.updateForecastUI(dayOfWeek: dayOfWeek, forecastImage: forecastImage, forecastTemp: forecastTemp)

    }

    func didCatchError(error: Error) {
        print("didCatchError")
    }

    //function to send status to WeatherViewModel
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if weatherLocation == .currentLocation, let location = locations.first {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            weatherOperator.createGeoURL(latitude: latitude, longitude: longitude)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }






}
