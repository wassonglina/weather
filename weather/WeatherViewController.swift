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
        print("got location")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }

}


