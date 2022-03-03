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

    func presentAuthAlert(with title: String, with message: String, with cancel: UIAlertAction, with action: UIAlertAction)

    func updateForecastUI(VCForecast: [
        (dayOfWeek: String, forecastImage: UIImage, forecastTemp: String)
    ])

    func didCatchError(errorMsg: String, errorImage: UIImage)
}


class WeatherViewModel: NSObject, WeatherManagerDelegate {

    var locationManager = CLLocationManager()
    var delegate: ViewModelDelegate?
    let weatherOperator = WeatherOperator()
    var timer: Timer?
    let randomLocation = ["Honolulu", "Hobart", "Pattani", "Manaus", "Stavanger", "Taipei", "Dhaka"]

    override init() {
        super.init()
        weatherOperator.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers    //faster response + energy efficient
    }

    enum PreferedLocationSource: Equatable {
        case currentLocation
        case city(String)
    }

    var preferedLocationSource: PreferedLocationSource? {
        didSet {
            switch preferedLocationSource {
            case .currentLocation:
                locationManager.startUpdatingLocation()
                getWeatherWithCoordinates()
                print("case location")
            case .city(let cityname):
                locationManager.stopUpdatingLocation()
                weatherOperator.createCityURL(city: cityname)
                print("case city")
            case nil:
                break
            }
        }
    }

    func handleAuthCase() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways:
            preferedLocationSource = .currentLocation
        case .authorizedWhenInUse:
            preferedLocationSource = .currentLocation
        case .denied:
            print("auth denied")
            createAlert()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            print("auth not determined")
        case .restricted:
            createAlert()
        default:
            print("auth status unknown")
        }
    }

    func getLocationBasedOnUserPreference() {
        print(#function)
        switch preferedLocationSource {
        case .currentLocation:
            let auth = locationManager.authorizationStatus
            if auth == .authorizedWhenInUse || auth == .authorizedAlways {
                preferedLocationSource = .currentLocation
            } else if auth == .notDetermined || auth == .denied || auth == .restricted {
                weatherOperator.createCityURL(city: randomLocation.randomElement()!)
            }
        case .city(let name):
            weatherOperator.createCityURL(city: name)
        case nil:
            break
        }
    }


    func getWeatherWithCoordinates() {
        if let location = locationManager.location {
            let coordinates = location.coordinate
            weatherOperator.createGeoURL(with: coordinates)
        }
    }

    func didTapLocation() {
        handleAuthCase()
    }

    func didBecomeActive() {
        getLocationBasedOnUserPreference()
    }

    func willEnterForeground() {
        getLocationBasedOnUserPreference()
    }

    func didEnterCity(with name: String) {
        preferedLocationSource = .city(name)
    }

    func createAlert(){
        let title = "Get weather for your current location?"
        let message = "Allow access to your location in settings."
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let settingsAction = UIAlertAction(title: "Settings", style: .cancel) { _ in
            let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL)
            }
        }
        delegate?.presentAuthAlert(with: title, with: message, with: cancelAction, with: settingsAction)
    }

    func didFetchWeather(with currentWeather: WeatherModel) {
        let city = currentWeather.name!
        let temp = currentWeather.getTempUnit(with: currentWeather.temp)
        let image = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast))")!

        let conditionImage = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast)).fill")!
        let forecastTemp = currentWeather.getTempUnit(with: currentWeather.temp)

        delegate?.updateWeatherUI(city: city, temperature: temp, image: image, forecastImage: conditionImage, forecastTemp: forecastTemp)
    }

    func didFetchForecast(with forecastWeather: [WeatherModel]) {
        let firstDay = forecastWeather[0].getDayOfWeek()
        let firstImage = UIImage(systemName: "\(forecastWeather[0].symbolName(isNight: forecastWeather[0].isNight!, isForecast: forecastWeather[0].isForecast))")!
        let firstTemp = forecastWeather[0].getTempUnit(with: forecastWeather[0].temp)

        let secondsDay = forecastWeather[1].getDayOfWeek()
        let secondImage = UIImage(systemName: "\(forecastWeather[1].symbolName(isNight: forecastWeather[1].isNight!, isForecast: forecastWeather[1].isForecast))")!
        let secondTemp = forecastWeather[1].getTempUnit(with: forecastWeather[1].temp)

        let thirdDay = forecastWeather[2].getDayOfWeek()
        let thirdImage = UIImage(systemName: "\(forecastWeather[2].symbolName(isNight: forecastWeather[2].isNight!, isForecast: forecastWeather[2].isForecast))")!
        let thirdTemp = forecastWeather[2].getTempUnit(with: forecastWeather[2].temp)

        let fourthDay = forecastWeather[3].getDayOfWeek()
        let fourthImage = UIImage(systemName: "\(forecastWeather[3].symbolName(isNight: forecastWeather[3].isNight!, isForecast: forecastWeather[3].isForecast))")!
        let fourthTemp = forecastWeather[3].getTempUnit(with: forecastWeather[3].temp)

        delegate?.updateForecastUI(VCForecast: [(dayOfWeek: firstDay, forecastImage: firstImage, forecastTemp: firstTemp), (dayOfWeek: secondsDay, forecastImage: secondImage, forecastTemp: secondTemp), (dayOfWeek: thirdDay, forecastImage: thirdImage, forecastTemp: thirdTemp), (dayOfWeek: fourthDay, forecastImage: fourthImage, forecastTemp: fourthTemp)])
    }

    func didCatchError(error: Error) {
        let text: String
        let image: UIImage
        if error.localizedDescription == "The data couldn’t be read because it is missing." {
            text = "City Not Found"
            image = UIImage(systemName: "globe.asia.australia")!
        } else if error.localizedDescription == "The Internet connection appears to be offline." {
            text = "No Internet"
            image = UIImage(systemName: "wifi.slash")!
        } else {
        //    text = "Error Loading Weather"
            text = "Error"
            image = UIImage(systemName: "exclamationmark.icloud")!
        }
        delegate?.didCatchError(errorMsg: text, errorImage: image)
    }
}


extension WeatherViewModel: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        getWeatherWithCoordinates()
        print(#function)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.preferedLocationSource = .currentLocation    //fails first time
        print(#function)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)
        //    >> check here for internet connection
    }
}

