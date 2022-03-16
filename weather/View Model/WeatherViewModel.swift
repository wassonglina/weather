//
//  ViewModel.swift
//  weather
//
//  Created by Lina on 2/2/22.
//

import UIKit
import CoreLocation

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}


protocol ViewModelDelegate: AnyObject {
    func updateCurrentUI(city: String, temperature: String, image: UIImage, forecastImage: UIImage, forecastMinTemp: String, forecastMaxTemp: String)

    func presentAuthAlert(with title: String, with message: String, with cancel: UIAlertAction, with action: UIAlertAction)

//    func updateForecastUI(VCForecast: [
//        (dayOfWeek: String, forecastImage: UIImage, forecastMinTemp: String, forecastMaxTemp: String)
//    ])

    func updateForecastUI(with forecastUIModels: [ForecastUIModel])

    func didCatchError(errorMsg: String, errorImage: UIImage)
}

class WeatherViewModel: NSObject {

    var locationManager = CLLocationManager()
    weak var delegate: ViewModelDelegate?
    let weatherManager = WeatherManager()
    var timer: Timer?
    let defaults = UserDefaults.standard
    let randomLocation = ["Honolulu", "Hobart", "Pattani", "Manaus", "Stavanger", "Taipei", "Dhaka"]

    override init() {
        super.init()
        weatherManager.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers    //faster response + energy efficient

        let prefSource = try? defaults.getObject(forKey: "PrefSource", castTo: PreferedLocationSource.self)

        switch prefSource {
        case .city(let cityname):
            print("decoded city")
            preferedLocationSource = .city(cityname)
        default:
            preferedLocationSource = .currentLocation
        }
    }

    enum PreferedLocationSource: Equatable, Codable {
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
                //TODO: saving unnecessary bc it's default
                try? defaults.setObject(PreferedLocationSource.currentLocation, forKey: "PrefSource")
            case .city(let cityname):
                print("case city")
                locationManager.stopUpdatingLocation()
                weatherManager.createCityURL(city: cityname)
                try? defaults.setObject(PreferedLocationSource.city(cityname), forKey: "PrefSource")
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

    //didBecomeActive
    //>> check user Pref  >>Not quite right here
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
            if let url = settingsUrl {
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
        var x = 1
        let forcastUIModels: [ForecastUIModel] = forecastEntries.compactMap { item in
            let allEntries = filterDay(unfilteredList: forecastEntries, dayNumber: x)
            let day = allEntries.first!.getDayOfWeek()
            let image = UIImage(systemName: allEntries[4].symbolName(isNight: allEntries.first!.isNight!, isForecast: allEntries.first!.isForecast ))
            let tempMin = createTempString(temp: getMinTemp(unfilteredList: allEntries))
            let tempMax = createTempString(temp: getMaxTemp(unfilteredList: allEntries))
            if x <= 3 {
                x += 1
            }
            return ForecastUIModel(forcastDay: day, forcastImage: image!, forcastTempMin: tempMin, forcastTempMax: tempMax)
        }
        delegate?.updateForecastUI(with: forcastUIModels)
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
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)
    }
}



extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }

    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }

    enum ObjectSavableError: String, LocalizedError {
        case unableToEncode = "Unable to encode object into data"
        case noValue = "No data object found for the given key"
        case unableToDecode = "Unable to decode object into given type"

        var errorDescription: String? {
            rawValue
        }
    }
}
