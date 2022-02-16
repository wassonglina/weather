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

    let cityAnimationLabel = UILabel()       //front View

    var weatherOperator = WeatherOperator()

    var weatherViewModel = WeatherViewModel()

    let cornerRadius = CGFloat(10)

    let animationView = AnimationView()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        cityTextField.delegate = self
        weatherViewModel.delegate = self

        weatherViewModel.checkAuthStatus()

        cityTextField.backgroundColor = .white.withAlphaComponent(0.3)

        cityTextLabel.textColor = .white.withAlphaComponent(0.15)
        cityTextLabel.text = "Loading ..."

        tempTextLabel.isHidden = true
        weatherImageView.isHidden = true

        cityAnimationLabel.textColor = .white.withAlphaComponent(0.75)
        cityAnimationLabel.text = cityTextLabel.text
        cityAnimationLabel.font = cityTextLabel.font
        cityAnimationLabel.textAlignment = cityTextLabel.textAlignment
        //        cityAnimationLabel.backgroundColor = .red.withAlphaComponent(0.7)

        forecastView.layer.cornerRadius = cornerRadius
        forecastView.backgroundColor = .white.withAlphaComponent(0.15)
        forecastStackView.layer.opacity = 0

        forecastAnimationView.layer.cornerRadius = cornerRadius
        forecastAnimationView.backgroundColor = .white.withAlphaComponent(0.45)

        animationView.defineAnimationGradient()
        animationView.startAnmiation(with: forecastAnimationView)

        //      animationView.defineLabelGradient()
        animationView.startAnmiation2(with: cityAnimationLabel)
        //        print(cityAnimationLabel.frame)

        view.addSubview(cityAnimationLabel)

        NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tap = UITapGestureRecognizer(target: self, action: #selector(WeatherViewController.didTapScreen))
        view.addGestureRecognizer(tap)
    }

    //TODO: where and when call animation func
    
    override func viewWillAppear(_ animated: Bool) {
        animationView.defineAnimationGradient()
        animationView.startAnmiation(with: forecastAnimationView)

        animationView.defineLabelGradient()
        //      animationView.startAnmiation2(with: cityAnimationLabel)

    }




    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        forecastAnimationView.frame = forecastView.frame
        animationView.forecastGradientLayer.frame = forecastAnimationView.bounds
        forecastAnimationView.layer.mask = animationView.forecastGradientLayer

        cityAnimationLabel.frame = cityTextLabel.frame
        animationView.labelGradientLayer.frame = cityAnimationLabel.bounds
        cityAnimationLabel.layer.mask = animationView.labelGradientLayer

        //Jesse: when func called in ViewDidLoad just gradient and no animation
        //        animationView.defineLabelGradient()
        animationView.startAnmiation2(with: cityAnimationLabel)
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
            weatherViewModel.weatherLocation = .city(cityTextField.text!)
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
        weatherViewModel.handleAuthCase()      //check auth status and handle case
        sender.alpha = 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
            self.cityTextField.endEditing(true)
        }
    }
}


//Mark: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("@@", #function)
        if cityTextField.text?.isEmpty == false  {
            weatherViewModel.weatherLocation = .city(cityTextField.text!)
            cityTextField.text = ""
            cityTextField.endEditing(true)
        }
        return true
    }
}

//Mark: - ViewModelDelegate

extension WeatherViewController: ViewModelDelegate {

    func presentAuthAlert(with alert: UIAlertController) {
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

            //Jesse: current Weather and Forecast load at same time but possibility that not. still ok?
            self.forecastStackView.layer.opacity = 1
            self.cityTextLabel.textColor = .white
            self.tempTextLabel.isHidden = false
            self.weatherImageView.isHidden = false


            //TODO: Stop animation instead of hiding
            self.forecastAnimationView.isHidden = true
            self.cityAnimationLabel.isHidden = true

            //if auth .notDetermined start 5s timer then ask permission
            self.weatherViewModel.startAuthTimer()
        }
    }

}



