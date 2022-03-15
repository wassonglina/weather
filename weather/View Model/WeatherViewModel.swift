//
//  ViewModel.swift
//  weather
//
//  Created by Lina on 2/2/22.
//

import UIKit
import CoreLocation


protocol ViewModelDelegate: AnyObject {
    func updateCurrentUI(city: String, temperature: String, image: UIImage, forecastImage: UIImage, forecastMinTemp: String, forecastMaxTemp: String)

    func presentAuthAlert(with title: String, with message: String, with cancel: UIAlertAction, with action: UIAlertAction)

    func updateForecastUI(VCForecast: [
        (dayOfWeek: String, forecastImage: UIImage, forecastMinTemp: String, forecastMaxTemp: String)
    ])

    func didCatchError(errorMsg: String, errorImage: UIImage)
}

class WeatherViewModel: NSObject {

    var locationManager = CLLocationManager()
    weak var delegate: ViewModelDelegate?
    let weatherManager = WeatherManager()
    var timer: Timer?
    let randomLocation = ["Honolulu", "Hobart", "Pattani", "Manaus", "Stavanger", "Taipei", "Dhaka"]

    let defaults = UserDefaults.standard

    override init() {
        super.init()
        weatherManager.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers    //faster response + energy efficient

        // set PreferedLocationSource based on last settings
        //true if .city was set and false when never or .location set
        let userPrefCity = defaults.bool(forKey: "UserPrefCity")
        print("User prefers city: \(userPrefCity)")

        if userPrefCity == false {
            preferedLocationSource = .currentLocation
        } else if userPrefCity == true {
            preferedLocationSource = .city(defaults.string(forKey: "savedCity")!)
        } else {
            print("Something didn't work setting prefs with user defaults.")
        }
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
                defaults.set(false, forKey: "UserPrefCity")
                print("User prefers city: \(defaults.bool(forKey: "UserPrefCity"))")
            case .city(let cityname):
                print("case city")
                locationManager.stopUpdatingLocation()
                weatherManager.createCityURL(city: cityname)
                //called when city search tapped; sets USerPrefCity == true and saves City in defaults
                defaults.set(true, forKey: "UserPrefCity")
                print("User prefers city: \(defaults.bool(forKey: "UserPrefCity"))")
                defaults.set(cityname, forKey: "savedCity")
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

    //called in viewDidLoad, didBecomeActive and willEnterForeground
    //>> check user Pref  >>Not quit right here
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
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            self.getLocationBasedOnUserPref()
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .cancel) { _ in
            self.preferedLocationSource = .currentLocation
            let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
            if let url = settingsUrl {git 
                UIApplication.shared.open(url as URL)
            }
        }
        delegate?.presentAuthAlert(with: title, with: message, with: cancelAction, with: settingsAction)
    }

    //style depends on temp unit and region setting > if temp unit selected that's less common will show unit (e.g. °C for USA or °F for DE)
    func createTempString(temp: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.numberFormatter.roundingMode = .halfEven
        formatter.unitStyle = .short
        let tempUnit = Measurement(value: temp, unit: UnitTemperature.celsius)
        let temp = formatter.string(from: tempUnit)

        return (temp)
    }
}

extension WeatherViewModel: WeatherManagerDelegate {

    func didFetchCurrent(with currentWeather: CurrentModel) {
        let city = currentWeather.name
        let currentTemp = currentWeather.tempString
        let image = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast))")!
        let conditionImage = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast)).fill")!
        let minTemp = createTempString(temp: currentWeather.minTemp)
        let maxTemp = createTempString(temp: currentWeather.maxTemp)

        delegate?.updateCurrentUI(city: city, temperature: currentTemp, image: image, forecastImage: conditionImage, forecastMinTemp: minTemp, forecastMaxTemp: maxTemp)
    }

    func didFetchForecast(with forecastEntries: [ForecastModel]) {

        let firstDayAll = filterDay(unfilteredList: forecastEntries, dayNumber: 1)
        let firstDay = firstDayAll.first!.getDayOfWeek()
        let firstImage = UIImage(systemName: (firstDayAll[4].symbolName(isNight: (firstDayAll.first!.isNight!), isForecast: firstDayAll.first!.isForecast)))
        let firstMinTemp = createTempString(temp: getMinTemp(unfilteredList: firstDayAll))
        let firstMaxTemp = createTempString(temp: getMaxTemp(unfilteredList: firstDayAll))

        let secondDayAll = filterDay(unfilteredList: forecastEntries, dayNumber: 2)
        let secondDay = secondDayAll.first!.getDayOfWeek()
        let secondImage = UIImage(systemName: (secondDayAll[4].symbolName(isNight: (secondDayAll.first!.isNight!), isForecast: secondDayAll.first!.isForecast)))
        let secondMinTemp = createTempString(temp: getMinTemp(unfilteredList: secondDayAll))
        let secondtMaxTemp = createTempString(temp: getMaxTemp(unfilteredList: secondDayAll))

        let thirdDayAll = filterDay(unfilteredList: forecastEntries, dayNumber: 3)
        let thirdDay = thirdDayAll.first!.getDayOfWeek()
        let thirdImage = UIImage(systemName: (thirdDayAll[4].symbolName(isNight: (thirdDayAll.first!.isNight!), isForecast: thirdDayAll.first!.isForecast)))
        let thirdMinTemp = createTempString(temp: getMinTemp(unfilteredList: thirdDayAll))
        let thirdMaxTemp = createTempString(temp: getMaxTemp(unfilteredList: thirdDayAll))

        let fourthDayAll = filterDay(unfilteredList: forecastEntries, dayNumber: 4)
        let fourthDay = fourthDayAll.first!.getDayOfWeek()
        let fourthImage = UIImage(systemName: (fourthDayAll[4].symbolName(isNight: (fourthDayAll.first!.isNight!), isForecast: fourthDayAll.first!.isForecast)))
        let fourthMinTemp = createTempString(temp: getMinTemp(unfilteredList: fourthDayAll))
        let fourthMaxTemp = createTempString(temp: getMaxTemp(unfilteredList: fourthDayAll))

        delegate?.updateForecastUI(VCForecast: [(dayOfWeek: firstDay, forecastImage: firstImage!, forecastMinTemp: firstMinTemp, forecastMaxTemp: firstMaxTemp), (dayOfWeek: secondDay, forecastImage: secondImage!, forecastMinTemp: secondMinTemp, forecastMaxTemp: secondtMaxTemp), (dayOfWeek: thirdDay, forecastImage: thirdImage!, forecastMinTemp: thirdMinTemp, forecastMaxTemp: thirdMaxTemp), (dayOfWeek: fourthDay, forecastImage: fourthImage!, forecastMinTemp: fourthMinTemp, forecastMaxTemp: fourthMaxTemp)])
    }

    func didCatchError(error: NSError) {
        //TODO: Use error code instead
        let text: String
        let image: UIImage

        if error.code == 4865 {
            text = "City Not Found"
            image = UIImage(systemName: "globe.asia.australia")!
        } else if error.code == -1009 {
            text = "No Internet"
            image = UIImage(systemName: "wifi.slash")!
        } else if error.code == -1001 {
            text = "Request Timed Out"
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
        print(#function)
        getWeatherWithCoordinates()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        //don't call getLocationBasedOnUserPref() here -> weather will update once didBecomeActive() is called
     //   getLocationBasedOnUserPref()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)
        //send error "no auth"
    }
}

