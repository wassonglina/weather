//
//  ViewController.swift
//  weather
//
//  Created by Lina on 1/19/22.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet var cityTextField: UITextField!

    let weatherOperator = WeatherOperator()

    var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        cityTextField.delegate = self

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
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


