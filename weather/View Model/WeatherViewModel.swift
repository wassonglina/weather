//
//  ViewModel.swift
//  weather
//
//  Created by Lina on 2/2/22.
//

import UIKit
import CoreLocation


protocol ViewModelDelegate: AnyObject {
    func updateCurrentUI(city: String, temperature: String, image: UIImage, forecastImage: UIImage, forecastTemp: String)

    func presentAuthAlert(with title: String, with message: String, with cancel: UIAlertAction, with action: UIAlertAction)

    func updateForecastUI(VCForecast: [
        (dayOfWeek: String, forecastImage: UIImage, forecastTemp: String)
    ])

    func didCatchError(errorMsg: String, errorImage: UIImage)
}


class WeatherViewModel: NSObject {

    var locationManager = CLLocationManager()
    weak var delegate: ViewModelDelegate?
    let weatherManager = WeatherManager()
    var timer: Timer?
    let randomLocation = ["Honolulu", "Hobart", "Pattani", "Manaus", "Stavanger", "Taipei", "Dhaka"]

    override init() {
        super.init()
        weatherManager.delegate = self
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
                print("case location")
                locationManager.startUpdatingLocation()
                getWeatherWithCoordinates()
            case .city(let cityname):
                print("case city")
                locationManager.stopUpdatingLocation()
                weatherManager.createCityURL(city: cityname)

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

    func getLocationBasedOnUserPref() {
        print(#function)
        switch preferedLocationSource {
        case .currentLocation:
            let auth = locationManager.authorizationStatus
            if auth == .authorizedWhenInUse || auth == .authorizedAlways {
                preferedLocationSource = .currentLocation
            } else if auth == .notDetermined || auth == .denied || auth == .restricted {
                weatherManager.createCityURL(city: randomLocation.randomElement()!)
            }
        case .city(let name):
            weatherManager.createCityURL(city: name)
        case nil:
            break
        }
    }

    func getWeatherWithCoordinates() {
        if let location = locationManager.location {
            let coordinates = location.coordinate
            weatherManager.createGeoURL(with: coordinates)
        }
    }

    func didTapLocation() {
        handleAuthCase()
    }

    func didBecomeActive() {
        print("WVM: \(#function)")
        getLocationBasedOnUserPref()
    }

    func willEnterForeground() {
        getLocationBasedOnUserPref()
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
}


extension WeatherViewModel: WeatherManagerDelegate {

    func didFetchCurrent(with currentWeather: CurrentModel) {
        let city = currentWeather.name
        let temp = currentWeather.tempString
        let image = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast))")!

        let conditionImage = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast)).fill")!
        let forecastTemp = currentWeather.tempString

        delegate?.updateCurrentUI(city: city, temperature: temp, image: image, forecastImage: conditionImage, forecastTemp: forecastTemp)
    }


    func didFetchForecast(with forecastEntries: [ForecastModel]) {
        let firstDay = forecastEntries[0].getDayOfWeek()
        let firstImage = UIImage(systemName: "\(forecastEntries[0].symbolName(isNight: forecastEntries[0].isNight!, isForecast: forecastEntries[0].isForecast))")!

        let firstDayAll = filterDay(unfilteredList: forecastEntries, dayNumber: 1)
        let firstMin = getMinTempString(unfilteredList: firstDayAll)
        let firstMax = getMaxTempString(unfilteredList: firstDayAll)
        let firstTempRange = "\(firstMin) - \(firstMax)"

        let secondDay = forecastEntries[1].getDayOfWeek()   //all entries so first few aleays same day
        let secondImage = UIImage(systemName: "\(forecastEntries[1].symbolName(isNight: forecastEntries[1].isNight!, isForecast: forecastEntries[1].isForecast))")!

        let secondDayAll = filterDay(unfilteredList: forecastEntries, dayNumber: 2)
        let secondMin = getMinTempString(unfilteredList: secondDayAll)
        let secondMax = getMaxTempString(unfilteredList: secondDayAll)
        let secondTempRange = "\(secondMin) - \(secondMax)"

        let thirdDay = forecastEntries[2].getDayOfWeek()
        let thirdImage = UIImage(systemName: "\(forecastEntries[2].symbolName(isNight: forecastEntries[2].isNight!, isForecast: forecastEntries[2].isForecast))")!

        let thirdDayAll = filterDay(unfilteredList: forecastEntries, dayNumber: 3)
        let thirdMin = getMinTempString(unfilteredList: thirdDayAll)
        let thirdMax = getMaxTempString(unfilteredList: thirdDayAll)
        let thirdTempRange = "\(thirdMin) - \(thirdMax)"

        let fourthDay = forecastEntries[3].getDayOfWeek()
        let fourthImage = UIImage(systemName: "\(forecastEntries[3].symbolName(isNight: forecastEntries[3].isNight!, isForecast: forecastEntries[3].isForecast))")!

        let fourthDayAll = filterDay(unfilteredList: forecastEntries, dayNumber: 4)
        let fourthMin = getMinTempString(unfilteredList: fourthDayAll)
        let fourthMax = getMaxTempString(unfilteredList: fourthDayAll)
        let fourthTempRange = "\(fourthMin) - \(fourthMax)"

        delegate?.updateForecastUI(VCForecast: [(dayOfWeek: firstDay, forecastImage: firstImage, forecastTemp:  firstTempRange), (dayOfWeek: secondDay, forecastImage: secondImage, forecastTemp: secondTempRange), (dayOfWeek: thirdDay, forecastImage: thirdImage, forecastTemp: thirdTempRange), (dayOfWeek: fourthDay, forecastImage: fourthImage, forecastTemp: fourthTempRange)])
    }

    func didCatchError(error: Error) {
        //TODO: Use error code instead
        let text: String
        let image: UIImage
        if error.localizedDescription == "The data couldn’t be read because it is missing." {
            text = "City Not Found"
            image = UIImage(systemName: "globe.asia.australia")!
        } else if error.localizedDescription == "The Internet connection appears to be offline." {
            text = "No Internet"
            image = UIImage(systemName: "wifi.slash")!
        } else {
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

