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

    //style depends on temp unit and region setting > if temp unit selected that's less common will show unit (e.g. °C for USA or °F for DE)
    func createTempString(min: Double, max: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.numberFormatter.roundingMode = .halfEven
        formatter.unitStyle = .short
        let minUnit = Measurement(value: min, unit: UnitTemperature.celsius)
        let maxUnit = Measurement(value: max, unit: UnitTemperature.celsius)
        let min = (formatter.string(from: minUnit))
        let max = (formatter.string(from: maxUnit))
        return ("\(min) - \(max)")
    }

    func createTempString2(min: Double, max: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.numberFormatter.roundingMode = .halfEven
        formatter.unitStyle = .short

        let minUnit = Measurement(value: min, unit: UnitTemperature.celsius)
        let maxUnit = Measurement(value: max, unit: UnitTemperature.celsius)
        let min = formatter.string(from: minUnit)
        let max = formatter.string(from: maxUnit)
        return ("\(min) - \(max)")
    }

}


extension WeatherViewModel: WeatherManagerDelegate {

    func didFetchCurrent(with currentWeather: CurrentModel) {
        let city = currentWeather.name
        let currentTemp = currentWeather.tempString

        let image = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast))")!

        let conditionImage = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast)).fill")!

        let tempsString = createTempString(min: currentWeather.minTemp, max: currentWeather.maxTemp)
  //      let forecastTemp = currentWeather.tempString

        delegate?.updateCurrentUI(city: city, temperature: currentTemp, image: image, forecastImage: conditionImage, forecastTemp: tempsString)
    }

    func didFetchForecast(with forecastEntries: [ForecastModel]) {

        let firstDayAll = filterDay(unfilteredList: forecastEntries, dayNumber: 1)
        let firstDay = firstDayAll.first!.getDayOfWeek()
        let firstImage = UIImage(systemName: (firstDayAll.first!.symbolName(isNight: (firstDayAll.first!.isNight!), isForecast: firstDayAll.first!.isForecast)))
        let firstMinMaxTemps = getTemps(unfilteredList: firstDayAll)
        let firstTempsString = createTempString(min: firstMinMaxTemps.min, max: firstMinMaxTemps.max)

        let secondDayAll = filterDay(unfilteredList: forecastEntries, dayNumber: 2)
        let secondDay = secondDayAll.first!.getDayOfWeek()
        let secondImage = UIImage(systemName: (secondDayAll.first!.symbolName(isNight: (firstDayAll.first!.isNight!), isForecast: secondDayAll.first!.isForecast)))
        let secondMinMaxTemps = getTemps(unfilteredList: secondDayAll)
        let secondTempsString = createTempString(min: secondMinMaxTemps.min, max: secondMinMaxTemps.max)

        let thirdDayAll = filterDay(unfilteredList: forecastEntries, dayNumber: 3)
        let thirdDay = thirdDayAll.first!.getDayOfWeek()
        let thirdImage = UIImage(systemName: (thirdDayAll.first!.symbolName(isNight: (thirdDayAll.first!.isNight!), isForecast: thirdDayAll.first!.isForecast)))
        let thirdMinMaxTemps = getTemps(unfilteredList: thirdDayAll)
        let thirdTempsString = createTempString(min: thirdMinMaxTemps.min, max: thirdMinMaxTemps.max)

        let fourthDayAll = filterDay(unfilteredList: forecastEntries, dayNumber: 4)
        let fourthDay = fourthDayAll.first!.getDayOfWeek()
        let fourthImage = UIImage(systemName: (fourthDayAll.first!.symbolName(isNight: (thirdDayAll.first!.isNight!), isForecast: fourthDayAll.first!.isForecast)))
        let fourthMinMaxTemps = getTemps(unfilteredList: fourthDayAll)
        let fourthTempsString = createTempString(min: fourthMinMaxTemps.min, max: fourthMinMaxTemps.max)


        delegate?.updateForecastUI(VCForecast: [(dayOfWeek: firstDay, forecastImage: firstImage!, forecastTemp:  firstTempsString), (dayOfWeek: secondDay, forecastImage: secondImage!, forecastTemp: secondTempsString), (dayOfWeek: thirdDay, forecastImage: thirdImage!, forecastTemp: thirdTempsString), (dayOfWeek: fourthDay, forecastImage: fourthImage!, forecastTemp: fourthTempsString)])
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

