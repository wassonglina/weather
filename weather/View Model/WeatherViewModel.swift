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

    func didCatchError()
}


class WeatherViewModel: NSObject, WeatherManagerDelegate, CLLocationManagerDelegate {

    var locationManager = CLLocationManager()
    var delegate: ViewModelDelegate?
    let weatherOperator = WeatherOperator()
//    let auth: locationManager.authorizationStatus?
    var timer: Timer?
    let randomLocation = ["Honolulu", "Hobart", "Pattani", "Manaus", "Stavanger", "Taipei", "Dhaka"]

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
                timer?.invalidate()
                locationManager.requestLocation()
            case .city(let cityname):
                timer?.invalidate()
                weatherOperator.createCityURL(city: cityname)
            case nil:
                break
            }
        }
    }

    func didCatchError(error: Error) {
        delegate?.didCatchError()
        print(#function)
        print("didCatchError")
    }

    func handleAuthCase() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways:
            weatherLocation = .currentLocation
        case .authorizedWhenInUse:
            weatherLocation = .currentLocation
        case .denied:
            createAlert()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            createAlert()
        default:
            print("location authorization status is unknown")
        }
    }

    //called in viewDidLoad
    func checkAuthStatus() {
       let auth = locationManager.authorizationStatus      //created twice?
        if auth == .authorizedWhenInUse || auth == .authorizedAlways {
            weatherLocation = .currentLocation
        } else if auth == .notDetermined || auth == .denied || auth == .restricted {
            weatherOperator.createCityURL(city: randomLocation.randomElement()!)
        }
    }

    func createAlert(){
        let title = "Would you like the weather for your current location?"
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

    //called when app opened for first time
    func startAuthTimer() {
       let auth = locationManager.authorizationStatus        //created twice?
        if auth == .notDetermined {
            var runCount = 0
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                print(runCount)
                runCount += 1
                if runCount == 5 {
                    timer.invalidate()
                    self.handleAuthCase()
                }
            }
        }
    }

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
        self.weatherLocation = .currentLocation          //fails first time
    }


    func didFetchWeather(with currentWeather: WeatherModel) {

        let city = currentWeather.name!
        let temp = currentWeather.getTempUnit(with: currentWeather.temp)
        let image = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast))")!

        let conditionImage = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast)).fill")!
        let forecastTemp = currentWeather.getTempUnit(with: currentWeather.temp)

        delegate?.updateWeatherUI(city: city, temperature: temp, image: image, forecastImage: conditionImage, forecastTemp: forecastTemp)

        startTimer()
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

    func startTimer() {
        var x = 1

        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                print(x)
                x += 1

                //TODO: what to fecht if location restricted?
                if x == 900 {
                    self.checkAuthStatus()

                }
            }
        }
    }
}

