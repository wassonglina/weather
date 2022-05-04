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
    @IBOutlet var forecastViewBackground: UIView!                 //back View
    @IBOutlet var forecastAnimationView: LoadingView!         //front View
    @IBOutlet var animationLabel: UILabel!
    @IBOutlet var errorImageview: UIImageView!


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

    @IBOutlet var temp1MinTextLabel: UILabel!
    @IBOutlet var temp2MinTextLabel: UILabel!
    @IBOutlet var temp3MinTextLabel: UILabel!
    @IBOutlet var temp4MinTextLabel: UILabel!
    @IBOutlet var temp5MinTextLabel: UILabel!

    @IBOutlet var forecastStackView: UIStackView!

    @IBOutlet var searchButton: UIButton!
    @IBOutlet var locationUIButton: UIButton!

    var weatherViewModel = WeatherViewModel()
    let cornerRadius = CGFloat(10)
    let animationView = AnimationView()
    let animationText = "Loading ..."

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)

        let forecastFont = UIFont.scriptFont(size: 20, style: .medium)

        searchButton?.isUserInteractionEnabled = false
        searchButton?.alpha = 0.4

        cityTextField.delegate = self
        weatherViewModel.delegate = self

        cityTextField.backgroundColor = .white.withAlphaComponent(0.3)
        cityTextField.keyboardType = .asciiCapable
        cityTextField.enablesReturnKeyAutomatically = true

        cityTextLabel.textColor = .white.withAlphaComponent(0.15)
        cityTextLabel.text = animationText

        tempTextLabel.isHidden = true
        weatherImageView.isHidden = true
        errorImageview.isHidden = true
        forecastStackView.isHidden = true

        forecast1TextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        forecast2TextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        forecast3TextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        forecast4TextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        forecast5TextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)

        forecast1TextLabel.adjustsFontForContentSizeCategory = true
        forecast2TextLabel.adjustsFontForContentSizeCategory = true
        forecast3TextLabel.adjustsFontForContentSizeCategory = true
        forecast4TextLabel.adjustsFontForContentSizeCategory = true
        forecast5TextLabel.adjustsFontForContentSizeCategory = true

        temp1TextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        temp2TextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        temp3TextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        temp4TextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        temp5TextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)

        temp1TextLabel.adjustsFontForContentSizeCategory = true
        temp2TextLabel.adjustsFontForContentSizeCategory = true
        temp3TextLabel.adjustsFontForContentSizeCategory = true
        temp4TextLabel.adjustsFontForContentSizeCategory = true
        temp5TextLabel.adjustsFontForContentSizeCategory = true

        temp1MinTextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        temp2MinTextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        temp3MinTextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        temp4MinTextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        temp5MinTextLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)

        temp1MinTextLabel.adjustsFontForContentSizeCategory = true
        temp2MinTextLabel.adjustsFontForContentSizeCategory = true
        temp3MinTextLabel.adjustsFontForContentSizeCategory = true
        temp4MinTextLabel.adjustsFontForContentSizeCategory = true
        temp5MinTextLabel.adjustsFontForContentSizeCategory = true

        forecastViewBackground.backgroundColor = .white.withAlphaComponent(0.15)
        forecastViewBackground.layer.cornerRadius = cornerRadius

        forecastAnimationView.layer.cornerRadius = cornerRadius
        forecastAnimationView.backgroundColor = .white.withAlphaComponent(0.45)

        animationLabel.textColor = .white.withAlphaComponent(0.65)
        animationLabel.text = cityTextLabel.text
        animationLabel.font = cityTextLabel.font
        animationLabel.textAlignment = cityTextLabel.textAlignment

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapScreen))
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func didBecomeActive() {
        print("VC: \(#function)")
        weatherViewModel.didBecomeActive()
    }

    @objc func didTapScreen() {
        cityTextField.endEditing(true)
    }

    func prepareViewForAnimation() {
        tempTextLabel.isHidden = true
        errorImageview.isHidden = true
        weatherImageView.isHidden = true
        forecastStackView.isHidden = true
        animationLabel.isHidden = false
        forecastAnimationView.isHidden = false
        cityTextLabel.text = animationText
        cityTextLabel.textColor = .white.withAlphaComponent(0.15)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        self.view.frame.origin.y = 40 - keyboardSize.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }

    @IBAction func didTapLocation(_ sender: UIButton) {
        prepareViewForAnimation()
        weatherViewModel.didTapLocation()
        sender.alpha = 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
            self.cityTextField.endEditing(true)
        }
    }

    @IBAction func didTapSearch(_ sender: UIButton) {
        print(#function)
        prepareViewForAnimation()
        handleTextField()
    }

    func handleTextField() {
        if cityTextField.text?.isEmpty == false {
            weatherViewModel.didEnterCity(with: cityTextField.text!)
            searchButton?.isUserInteractionEnabled = false
            searchButton?.alpha = 0.3
            cityTextField.text = ""
            cityTextField.endEditing(true)
        }
    }
}

//MARK: - Extension WeatherViewController: UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        prepareViewForAnimation()
        handleTextField()
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

//MARK: - Extension WeatherViewController: ViewModelDelegate

extension WeatherViewController: ViewModelDelegate {


    func presentAuthAlert(with title: String, with message: String, with cancel: UIAlertAction, with action: UIAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true)
    }

    func updateCurrentUI(city: String, temperature: String, image: UIImage, forecastImage: UIImage, forecastMinTemp: String, forecastMaxTemp: String) {
        DispatchQueue.main.async {
            self.cityTextLabel.text = city
            self.tempTextLabel.text = temperature
            self.weatherImageView.image = image
            self.errorImageview.isHidden = true

            self.forecast1TextLabel.text = "Today"
            self.cond1ImageView.image = forecastImage
            self.temp1TextLabel.text = forecastMaxTemp
            self.temp1MinTextLabel.text = forecastMinTemp

            self.cityTextLabel.textColor = .white
            self.tempTextLabel.isHidden = false
            self.weatherImageView.isHidden = false
            self.animationLabel.isHidden = true
        }
    }

    func updateForecastUI(with forecastUIModels: [ForecastUIModel]) {
        DispatchQueue.main.async {
            self.forecast2TextLabel.text = forecastUIModels[0].forecastDay
            self.cond2ImageView.image = forecastUIModels[0].forecastImage
            self.temp2MinTextLabel.text = forecastUIModels[0].forecastTempMin
            self.temp2TextLabel.text = forecastUIModels[0].forecastTempMax

            self.forecast3TextLabel.text = forecastUIModels[1].forecastDay
            self.cond3ImageView.image = forecastUIModels[1].forecastImage
            self.temp3MinTextLabel.text = forecastUIModels[1].forecastTempMin
            self.temp3TextLabel.text = forecastUIModels[1].forecastTempMax

            self.forecast4TextLabel.text = forecastUIModels[2].forecastDay
            self.cond4ImageView.image = forecastUIModels[2].forecastImage
            self.temp4MinTextLabel.text = forecastUIModels[2].forecastTempMin
            self.temp4TextLabel.text = forecastUIModels[2].forecastTempMax

            self.forecast5TextLabel.text = forecastUIModels[3].forecastDay
            self.cond5ImageView.image = forecastUIModels[3].forecastImage
            self.temp5MinTextLabel.text = forecastUIModels[3].forecastTempMin
            self.temp5TextLabel.text = forecastUIModels[3].forecastTempMax

            self.forecastStackView.isHidden = false
            self.forecastAnimationView.isHidden = true
        }
    }

    func didCatchError(errorMsg: String, errorImage: UIImage) {
        DispatchQueue.main.async {
            self.cityTextLabel.text = errorMsg
            self.errorImageview.image = errorImage

            self.tempTextLabel.isHidden = true
            self.weatherImageView.isHidden = true
            self.forecastStackView.isHidden = true
            self.cityTextLabel.textColor = .white
            self.errorImageview.isHidden = false

            self.forecastAnimationView.isHidden = true
            self.animationLabel.isHidden = true
        }
    }
}
