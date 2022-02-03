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
    @IBOutlet var cityTextLabel: UILabel!
    @IBOutlet var tempTextLabel: UILabel!
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var forecastUIView: UIView!

    @IBOutlet var forecast1TextLabel: UILabel!
    @IBOutlet var forecast2TextLabel: UILabel!
    @IBOutlet var forecast3TextLabel: UILabel!
    @IBOutlet var forecast4TextLabel: UILabel!
    @IBOutlet var forecast5TextLabel: UILabel!

    @IBOutlet var cond1ImageView: UIImageView!
    @IBOutlet var cond2ImageView: UIImageView!
    @IBOutlet var cond3ImageView: UIImageView!
    @IBOutlet var cond4ImageView: UIImageView!
    @IBOutlet var cond5ImageView: UIImageView!

    @IBOutlet var temp1TextLabel: UILabel!
    @IBOutlet var temp2TextLabel: UILabel!
    @IBOutlet var temp3TextLabel: UILabel!
    @IBOutlet var temp4TextLabel: UILabel!
    @IBOutlet var temp5TextLabel: UILabel!


    var weatherOperator = WeatherOperator()

    //Jesse: here or in view did load
    var locationManager: CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        cityTextField.delegate = self

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()

        weatherOperator.delegate = self

        forecastUIView.layer.cornerRadius = 10
        forecastUIView.backgroundColor = .white
        forecastUIView.layer.opacity = 0.15

        cityTextField.backgroundColor = .white
        cityTextField.layer.opacity = 0.6

        cityTextLabel.text = "Some Location"

    }

    @IBAction func didTapSearch(_ sender: Any) {
        getWeather()
        cityTextField.endEditing(true)
    }


    @IBAction func didTapLocation(_ sender: Any) {
        locationManager?.requestLocation()
    }


    func getWeather() {
        weatherOperator.createCityURL(city: cityTextField.text!)
    }
}


//Mark: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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


//Mark: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {

    //Jesse: pass in location or only lat and lon?
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            //            let latitude = location.coordinate.latitude
            //            let longitude = location.coordinate.longitude
            //            let altidue = location.altitude
            weatherOperator.createGeoURL(location: location)
            print(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
}



//Mark: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {

    func didFetchWeather(with currentWeather: WeatherModel) {

        DispatchQueue.main.async {
            self.cityTextLabel.text = currentWeather.name
            self.tempTextLabel.text = currentWeather.tempString
//            self.weatherImageView.image = UIImage(systemName: "\(currentWeather.conditionString)")
            self.weatherImageView.image = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight))")

            self.forecast1TextLabel.text = "Now" //forecastWeather[0].getDayOfWeek()
            self.cond1ImageView.image = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight))")
            self.temp1TextLabel.text = currentWeather.tempString
        }
    }


    func didFetchForecast(with forecastWeather: [ForecastModel]) {

        DispatchQueue.main.async {

            self.forecast2TextLabel.text = forecastWeather[1].getDayOfWeek()
            self.cond2ImageView.image = UIImage(systemName: "\(forecastWeather[1].conditionString)")
            self.temp2TextLabel.text = forecastWeather[1].tempString

            self.forecast3TextLabel.text = forecastWeather[2].getDayOfWeek()
            self.cond3ImageView.image = UIImage(systemName: "\(forecastWeather[2].conditionString)")
            self.temp3TextLabel.text = forecastWeather[2].tempString

            self.forecast4TextLabel.text = forecastWeather[3].getDayOfWeek()
            self.cond4ImageView.image = UIImage(systemName: "\(forecastWeather[3].conditionString)")
            self.temp4TextLabel.text = forecastWeather[3].tempString

            self.forecast5TextLabel.text = forecastWeather[4].getDayOfWeek()
            self.cond5ImageView.image = UIImage(systemName: "\(forecastWeather[4].conditionString)")
            self.temp5TextLabel.text = forecastWeather[4].tempString
        }
    }


    func didCatchError(error: Error) {
        print("There was an error getting the current weather: \(error).")

        DispatchQueue.main.async {
            self.cityTextLabel.text = "Error"
            self.tempTextLabel.text = "ºC"
            self.weatherImageView.image = UIImage(systemName: "questionmark")
        }
    }
}

