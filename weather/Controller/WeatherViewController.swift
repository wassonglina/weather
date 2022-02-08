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

    @IBOutlet var locationUIButton: UIButton!

    var weatherOperator = WeatherOperator()

    //Jesse: here or in view did load
    var locationManager: CLLocationManager?

    //Equatable: can be compared for equality using the equal-to operator
    enum WeatherLocation: Equatable {
        case currentLocation
        case city(String)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var weatherLocation: WeatherLocation? {
        didSet {
            switch weatherLocation {
            case .currentLocation:
                locationManager?.requestWhenInUseAuthorization()
                locationManager?.requestLocation()
            case .city(let cityname):
                weatherOperator.createCityURL(city: cityname)
            case nil:
                break
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        cityTextField.delegate = self

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        weatherLocation = .currentLocation  //set case .currentLocation

        weatherOperator.delegate = self

        forecastUIView.layer.cornerRadius = 10
        forecastUIView.backgroundColor = .white.withAlphaComponent(0.15)

        cityTextField.backgroundColor = .white
        cityTextField.layer.opacity = 0.6

        cityTextLabel.text = "Loading ..."

        //
        NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(WeatherViewController.didTapScreen))

        view.addGestureRecognizer(tap)
    }

    @objc func didTapScreen() {
        print("@@", #function)
        cityTextField.endEditing(true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            //return if keyboard size not available
            return
        }
        //TODO: if constraints programatically > constraintHeight/2 instead of hard coded number
        self.view.frame.origin.y = 40 - keyboardSize.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }

    @IBAction func didTapSearch(_ sender: UIButton) {

        if cityTextField.text?.isEmpty == false {
            weatherLocation = .city(cityTextField.text!) //set case .city
            cityTextField.text = ""
            sender.alpha = 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                sender.alpha = 1.0
                self.cityTextField.endEditing(true)
            }
        }
    }

    @IBAction func didTapLocation(_ sender: UIButton) {
        print("@@", #function)
        weatherLocation = .currentLocation
        sender.alpha = 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
            self.cityTextField.endEditing(true)
        }
    }
}



//Mark: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {

    //tapped "Enter" key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("@@", #function)
        if cityTextField.text?.isEmpty == false  {
            weatherLocation = .city(cityTextField.text!)
            cityTextField.text = ""
            cityTextField.endEditing(true)
        }
        return true
    }
}


//Mark: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if weatherLocation == .currentLocation, let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            weatherOperator.createGeoURL(latitude: latitude, longitude: longitude)
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
            self.weatherImageView.image = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast))")

            self.forecast1TextLabel.text = "Now" //forecastWeather[0].getDayOfWeek()
            self.cond1ImageView.image = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast)).fill")
            self.temp1TextLabel.text = currentWeather.tempString
        }
    }


    func didFetchForecast(with forecastWeather: [WeatherModel]) {

        DispatchQueue.main.async {

            //TODO: Better way to fill in content?
            self.forecast2TextLabel.text = forecastWeather[0].getDayOfWeek()
            self.cond2ImageView.image = UIImage(systemName: "\(forecastWeather[0].symbolName(isNight: forecastWeather[0].isNight!, isForecast: forecastWeather[0].isForecast))")
            self.temp2TextLabel.text = forecastWeather[0].tempString

            self.forecast3TextLabel.text = forecastWeather[1].getDayOfWeek()
            self.cond3ImageView.image = UIImage(systemName: "\(forecastWeather[1].symbolName(isNight: forecastWeather[1].isNight!, isForecast: forecastWeather[1].isForecast))")
            self.temp3TextLabel.text = forecastWeather[1].tempString

            self.forecast4TextLabel.text = forecastWeather[2].getDayOfWeek()
            self.cond4ImageView.image = UIImage(systemName: "\(forecastWeather[2].symbolName(isNight: forecastWeather[2].isNight!, isForecast: forecastWeather[2].isForecast))")
            self.temp4TextLabel.text = forecastWeather[2].tempString

            self.forecast5TextLabel.text = forecastWeather[3].getDayOfWeek()
            self.cond5ImageView.image = UIImage(systemName: "\(forecastWeather[3].symbolName(isNight: forecastWeather[3].isNight!, isForecast: forecastWeather[3].isForecast))")
            self.temp5TextLabel.text = forecastWeather[3].tempString
        }
    }


    func didCatchError(error: Error) {
        print("There was an error getting the current weather: \(error).")

        DispatchQueue.main.async {
            self.cityTextLabel.text = "City not found"
            self.tempTextLabel.text = ""
            self.weatherImageView.image = UIImage(systemName: "globe.europe.africa")
        }
    }
}

