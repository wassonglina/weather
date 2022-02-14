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

    func updateForecastUI(VCForecast: [
        (dayOfWeek: String, forecastImage: UIImage, forecastTemp: String)
    ])
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

    func didFetchForecast(with forecastWeather: [WeatherModel]) {

        let firstDay = forecastWeather[0].getDayOfWeek()
        let firstImage = UIImage(systemName: "\(forecastWeather[0].symbolName(isNight: forecastWeather[0].isNight!, isForecast: forecastWeather[0].isForecast))")!
        let firstTemp = forecastWeather[0].tempString

        let secondsDay = forecastWeather[1].getDayOfWeek()
        let secondImage = UIImage(systemName: "\(forecastWeather[1].symbolName(isNight: forecastWeather[1].isNight!, isForecast: forecastWeather[1].isForecast))")!
        let secondTemp = forecastWeather[1].tempString

        let thirdDay = forecastWeather[2].getDayOfWeek()
        let thirdImage = UIImage(systemName: "\(forecastWeather[2].symbolName(isNight: forecastWeather[2].isNight!, isForecast: forecastWeather[2].isForecast))")!
        let thirdTemp = forecastWeather[2].tempString

        let fourthDay = forecastWeather[3].getDayOfWeek()
        let fourthImage = UIImage(systemName: "\(forecastWeather[3].symbolName(isNight: forecastWeather[3].isNight!, isForecast: forecastWeather[3].isForecast))")!
        let fourthTemp = forecastWeather[3].tempString

        delegate?.updateForecastUI(VCForecast: [(dayOfWeek: firstDay, forecastImage: firstImage, forecastTemp: firstTemp), (dayOfWeek: secondsDay, forecastImage: secondImage, forecastTemp: secondTemp), (dayOfWeek: thirdDay, forecastImage: thirdImage, forecastTemp: thirdTemp), (dayOfWeek: fourthDay, forecastImage: fourthImage, forecastTemp: fourthTemp)])

    }


    func didCatchError(error: Error) {
        print("didCatchError")
    }

    //send status to WeatherViewModel
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
