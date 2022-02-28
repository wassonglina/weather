//
//  ViewController.swift
//  weather
//
//  Created by Lina on 1/19/22.
//

import UIKit


class WeatherViewController: UIViewController {


    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var cityTextLabel: UILabel!               //back View
    @IBOutlet var tempTextLabel: UILabel!
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var forecastView: UIView!                 //back View
    @IBOutlet var forecastAnimationView: UIView!         //front View
    @IBOutlet var animationLabel: UILabel!

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

    @IBOutlet var searchButton: UIButton!
    @IBOutlet var locationUIButton: UIButton!

    var weatherOperator = WeatherOperator()

    var weatherViewModel = WeatherViewModel()

    let cornerRadius = CGFloat(10)

    let animationView = AnimationView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)

        searchButton?.isUserInteractionEnabled = false
        searchButton?.alpha = 0.4

        cityTextField.delegate = self
        weatherViewModel.delegate = self

        weatherViewModel.getLocationForAuthStatus()

        cityTextField.backgroundColor = .white.withAlphaComponent(0.3)
        cityTextField.keyboardType = .asciiCapable
        cityTextField.enablesReturnKeyAutomatically = true

        cityTextLabel.textColor = .white.withAlphaComponent(0.15)
        cityTextLabel.text = "Loading ..."

        tempTextLabel.isHidden = true
        weatherImageView.isHidden = true

        animationLabel.textColor = .white.withAlphaComponent(0.65)
        animationLabel.text = cityTextLabel.text
        animationLabel.font = cityTextLabel.font
        animationLabel.textAlignment = cityTextLabel.textAlignment

        forecastView.layer.cornerRadius = cornerRadius
        forecastView.backgroundColor = .white.withAlphaComponent(0.15)
        forecastStackView.layer.opacity = 0

        forecastAnimationView.layer.cornerRadius = cornerRadius
        forecastAnimationView.backgroundColor = .white.withAlphaComponent(0.45)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapScreen))
        view.addGestureRecognizer(tap)

        //update weather when app enters foreground
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        animationView.defineForecastGradient()
        animationView.startAnmiationForecast(with: forecastAnimationView)

        animationView.defineLabelGradient()
        animationView.startAnmiationLabel(with: animationLabel)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        forecastAnimationView.frame = forecastView.frame
        animationView.forecastGradientLayer.frame = forecastAnimationView.bounds
        forecastAnimationView.layer.mask = animationView.forecastGradientLayer

        animationLabel.frame = cityTextLabel.frame
        animationView.labelGradientLayer.frame = animationLabel.bounds
        animationLabel.layer.mask = animationView.labelGradientLayer
    }

    @objc func didEnterForeground() {
        weatherViewModel.getLocationForAuthStatus()
    }

    @objc func didTapScreen() {
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

    @IBAction func didTapLocation(_ sender: UIButton) {
        weatherViewModel.handleAuthCase()
        sender.alpha = 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
            self.cityTextField.endEditing(true)
        }
    }

    @IBAction func didTapSearch(_ sender: UIButton) {
        if cityTextField.text?.isEmpty == false {
            handleTextField()
        }
    }

    func handleTextField() {
        weatherViewModel.weatherLocation = .city(cityTextField.text!)
        searchButton?.isUserInteractionEnabled = false
        searchButton?.alpha = 0.3
        cityTextField.text = ""
        cityTextField.endEditing(true)
    }
}

//Mark: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if cityTextField.text?.isEmpty == false  {
            handleTextField()
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !text.isEmpty {
            searchButton.isUserInteractionEnabled = true
            searchButton.alpha = 1
        } else {
            searchButton.isUserInteractionEnabled = false
            searchButton.alpha = 0.3
        }
        return true
    }
}

//Mark: - ViewModelDelegate

extension WeatherViewController: ViewModelDelegate {

    func presentAuthAlert(with title: String, with message: String, with cancel: UIAlertAction, with action: UIAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true)
    }

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

    func updateForecastUI(VCForecast: [(dayOfWeek: String, forecastImage: UIImage, forecastTemp: String)]) {

        DispatchQueue.main.async {
            self.forecast2TextLabel.text = VCForecast[0].dayOfWeek
            self.cond2ImageView.image = VCForecast[0].forecastImage
            self.temp2TextLabel.text = VCForecast[0].forecastTemp

            self.forecast3TextLabel.text = VCForecast[1].dayOfWeek
            self.cond3ImageView.image = VCForecast[1].forecastImage
            self.temp3TextLabel.text = VCForecast[1].forecastTemp

            self.forecast4TextLabel.text = VCForecast[2].dayOfWeek
            self.cond4ImageView.image = VCForecast[2].forecastImage
            self.temp4TextLabel.text = VCForecast[2].forecastTemp

            self.forecast5TextLabel.text = VCForecast[3].dayOfWeek
            self.cond5ImageView.image = VCForecast[3].forecastImage
            self.temp5TextLabel.text = VCForecast[3].forecastTemp

            //TODO: current Weather and Forecast might not load simultaniously > fix
            self.forecastStackView.layer.opacity = 1
            self.cityTextLabel.textColor = .white
            self.tempTextLabel.isHidden = false
            self.weatherImageView.isHidden = false
            self.stopAnimation()

            //if auth .notDetermined start 5s timer then ask permission
            self.weatherViewModel.startAuthTimer()
        }
    }

    func didCatchError() {
        DispatchQueue.main.async {
            self.cityTextLabel.text = "City not found"
            self.tempTextLabel.isHidden = true
            self.weatherImageView.isHidden = true
            self.forecastStackView.layer.opacity = 0
            self.cityTextLabel.textColor = .white
            self.stopAnimation()
        }
    }

    func stopAnimation() {
        //TODO: Stop animation instead of hiding
        self.forecastAnimationView.isHidden = true
        self.animationLabel.isHidden = true

    }
}



