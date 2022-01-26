//
//  ViewController.swift
//  weather
//
//  Created by Lina on 1/19/22.
//

import UIKit
import CoreLocation


class WeatherViewController: UIViewController, WeatherManagerDelegate {

    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var cityTextLabel: UILabel!
    @IBOutlet var tempTextLabel: UILabel!

    var weatherOperator = WeatherOperator()

    //here or in view did load
    var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        cityTextField.delegate = self

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()

        weatherOperator.delegate = self

    }


    @IBAction func didTapSearch(_ sender: Any) {
        print(cityTextField.text!)
        getWeather()
        cityTextField.endEditing(true)
    }


    @IBAction func didTapLocation(_ sender: Any) {
        locationManager?.requestLocation()
        print("getting location")
    }


    func getWeather() {
        weatherOperator.createCityURL(city: cityTextField.text!)
    }


    func didFetchWeather(with currentWeather: WeatherModel) {

        DispatchQueue.main.async {
            self.cityTextLabel.text = currentWeather.name
            self.tempTextLabel.text = currentWeather.tempString
        }
    }

    func didCatchError(error: Error) {
        print("There was an error getting the current weather: \(error).")
    }

}



//Mark: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(cityTextField.text!)
        getWeather()
        cityTextField.endEditing(true)
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if cityTextField.text != "" {
            return true
        } else {
            cityTextField.placeholder = "Enter a city"
            return false
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        cityTextField.text = ""
    }

}



//Mark: - CCLocationWEatherDelegate

extension WeatherViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            //            let latitude = location.coordinate.latitude
            //            let longitude = location.coordinate.longitude
            //            let altidue = location.altitude
            //            print("long: \(longitude), lat: \(latitude), alt: \(altidue)")
            weatherOperator.createGeoURL(location: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }

}

