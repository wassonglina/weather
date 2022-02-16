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

    var locationManager = CLLocationManager()

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
                locationManager.requestWhenInUseAuthorization() //still need this here?
                locationManager.requestLocation()
            case .city(let cityname):
                weatherOperator.createCityURL(city: cityname)
            case nil:
                break
            }
        }
    }

    //TODO: Optimize functions
    func getWeatherCity(with cityname: String) {
        weatherLocation = .city(cityname)
    }

    func getWeatherLocation() {
        weatherLocation = .currentLocation
    }

    func didCatchError(error: Error) {
        print(#function)
        print("didCatchError")
    }


    func getLocationAuthStatus() {

        switch locationManager.authorizationStatus {
        case .authorizedAlways:
            print("authorizedAlways")
            getWeatherLocation()
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            getWeatherLocation()
        case .denied:
            print("denied")
          //  getWeatherCity(with: "Sydney")
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("restricted")
           // getWeatherCity(with: "Sydney")
        default:
            print("location authorization status is unknown")
        }
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
        print("There was an error with the location authorization.")
        print(#function)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //        > Change an app’s location auth in Settings > Privacy > Location Services, or in Settings > (the app) >              Location Services.
        //        > Turn location services on or off globally in Settings > Privacy > Location Services.
        //        > Choose Reset Location & Privacy in Settings > General > Reset.
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
}


