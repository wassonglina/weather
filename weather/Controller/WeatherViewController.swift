//
//  ViewController.swift
//  weather
//
//  Created by Lina on 1/19/22.
//

import UIKit


class WeatherViewController: UIViewController {


    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var cityTextLabel: UILabel!
    @IBOutlet var tempTextLabel: UILabel!
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var forecastView: UIView!                 //backView
    @IBOutlet var forecastAnimationView: UIView!         //frontView

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

    @IBOutlet var forecastStackView: UIStackView!

    @IBOutlet var locationUIButton: UIButton!

    var weatherOperator = WeatherOperator()

    var weatherViewModel = WeatherViewModel()

    let cornerRadius = CGFloat(10)

    let anmiationGradientLayer = CAGradientLayer()
    let animation = CABasicAnimation(keyPath: "transform.translation.x")


    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        cityTextField.delegate = self

        weatherViewModel.delegate = self
        weatherViewModel.getWeatherLocation()

        cityTextField.backgroundColor = .white.withAlphaComponent(0.3)

        cityTextLabel.text = "Loading ..."

        forecastView.layer.cornerRadius = cornerRadius
        forecastView.backgroundColor = .white.withAlphaComponent(0.15)

        forecastAnimationView.layer.cornerRadius = cornerRadius
        forecastAnimationView.backgroundColor = .white.withAlphaComponent(0.5)

        forecastStackView.layer.opacity = 0

        startAnmiation()
        defineAnimationGradient()

        NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(WeatherViewController.didTapScreen))
        view.addGestureRecognizer(tap)
    }


    func startAnmiation(){

        //TODO: test from and to value on different devices (view.frame.width)
        animation.fromValue = -forecastAnimationView.frame.width
        animation.toValue = forecastAnimationView.frame.width
        animation.repeatCount = Float.infinity
        animation.duration = 1.7
        anmiationGradientLayer.add(animation, forKey: "Null")
    }

    override func viewDidLayoutSubviews() {
        forecastAnimationView.frame = forecastView.frame
        anmiationGradientLayer.frame = forecastAnimationView.bounds
        forecastAnimationView.layer.mask = anmiationGradientLayer
    }

    func defineAnimationGradient() {
        anmiationGradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        anmiationGradientLayer.locations = [0, 0.48, 0.52, 1]
        anmiationGradientLayer.startPoint = .init(x: 0.0, y: 0.5)
        anmiationGradientLayer.endPoint = .init(x: 1.0, y: 0.5)
    }

    @objc func didTapScreen() {
        print("@@", #function)
        cityTextField.endEditing(true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
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
            weatherViewModel.getWeatherCity(with: cityTextField.text!)
            cityTextField.text = ""
            sender.alpha = 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                sender.alpha = 1.0
                self.cityTextField.endEditing(true)
            }
        }
    }

    //function to send status to WeatherViewModel
    @IBAction func didTapLocation(_ sender: UIButton) {
        print("@@", #function)
        weatherViewModel.getWeatherLocation()
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
            weatherViewModel.getWeatherCity(with: cityTextField.text!)
            cityTextField.text = ""
            cityTextField.endEditing(true)
        }
        return true
    }
}




extension WeatherViewController: ViewModelDelegate {

    func updateWeatherUI(city: String, temperature: String, image: UIImage, forecastImage: UIImage, forecastTemp: String) {

        DispatchQueue.main.async {
            self.cityTextLabel.text = city
            self.tempTextLabel.text = temperature
            self.weatherImageView.image = image

            self.forecast1TextLabel.text = "Now"
            self.cond1ImageView.image = forecastImage
            self.temp1TextLabel.text = forecastTemp
        }
    }

    func updateForecastUI(dayOfWeek: String, forecastImage: UIImage, forecastTemp: String) {
        DispatchQueue.main.async {

            //           self.forecast2TextLabel.text = info[0].dayName

            self.forecast2TextLabel.text = dayOfWeek
            self.cond2ImageView.image = forecastImage
            self.temp2TextLabel.text = forecastTemp
            
            self.forecast3TextLabel.text = dayOfWeek
            self.cond3ImageView.image = forecastImage
            self.temp3TextLabel.text = forecastTemp

            self.forecast4TextLabel.text = dayOfWeek
            self.cond4ImageView.image = forecastImage
            self.temp4TextLabel.text = forecastTemp

            self.forecast5TextLabel.text = dayOfWeek
            self.cond5ImageView.image = forecastImage
            self.temp5TextLabel.text = forecastTemp

            //Jesse: current Weather and Forecast load at same time but possibility that not. still ok?
            self.forecastStackView.layer.opacity = 1

            self.forecastAnimationView.isHidden = true
        }
    }
}


//Mark: - WeatherManagerDelegate

//extension WeatherViewController: WeatherManagerDelegate {
//
////    func didFetchWeather(with currentWeather: WeatherModel) {
////
////        DispatchQueue.main.async {
////            self.cityTextLabel.text = currentWeather.name
////            self.tempTextLabel.text = currentWeather.tempString
////            self.weatherImageView.image = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast))")
////
////            self.forecast1TextLabel.text = "Now" //forecastWeather[0].getDayOfWeek()
////            self.cond1ImageView.image = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast)).fill")
////            self.temp1TextLabel.text = currentWeather.tempString
////        }
////    }
//
//
//    func didFetchForecast(with forecastWeather: [WeatherModel]) {
//
//        DispatchQueue.main.async {
//            //TODO: Better way to fill in content?
//            //           self.forecast2TextLabel.text = info[0].dayName
//
//            self.forecast2TextLabel.text = forecastWeather[0].getDayOfWeek()
//            self.cond2ImageView.image = UIImage(systemName: "\(forecastWeather[0].symbolName(isNight: forecastWeather[0].isNight!, isForecast: forecastWeather[0].isForecast))")
//            self.temp2TextLabel.text = forecastWeather[0].tempString
//
//            self.forecast3TextLabel.text = forecastWeather[1].getDayOfWeek()
//            self.cond3ImageView.image = UIImage(systemName: "\(forecastWeather[1].symbolName(isNight: forecastWeather[1].isNight!, isForecast: forecastWeather[1].isForecast))")
//            self.temp3TextLabel.text = forecastWeather[1].tempString
//
//            self.forecast4TextLabel.text = forecastWeather[2].getDayOfWeek()
//            self.cond4ImageView.image = UIImage(systemName: "\(forecastWeather[2].symbolName(isNight: forecastWeather[2].isNight!, isForecast: forecastWeather[2].isForecast))")
//            self.temp4TextLabel.text = forecastWeather[2].tempString
//
//            self.forecast5TextLabel.text = forecastWeather[3].getDayOfWeek()
//            self.cond5ImageView.image = UIImage(systemName: "\(forecastWeather[3].symbolName(isNight: forecastWeather[3].isNight!, isForecast: forecastWeather[3].isForecast))")
//            self.temp5TextLabel.text = forecastWeather[3].tempString
//
//            //Jesse: current Weather and Forecast load at same time but possibility that not. still ok?
//            self.forecastStackView.layer.opacity = 1
//
//            self.forecastAnimationView.isHidden = true
//        }
//    }
//
//
//    func didCatchError(error: Error) {
//        print("There was an error getting the current weather: \(error).")
//
//        DispatchQueue.main.async {
//            self.cityTextLabel.text = "City not found"
//            self.tempTextLabel.text = ""
//            self.weatherImageView.image = UIImage(systemName: "globe.europe.africa")
//        }
//    }
//}


