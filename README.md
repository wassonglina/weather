# Weather Pal

Weather Pal is a minimalistic weather app available on the [App Store for iOS](https://apps.apple.com/app/weather-pal/id1614726170). With it, you can see the current and forecasted weather for any city or automatically use your current location.

<p align="center">
  <img src="https://user-images.githubusercontent.com/10729156/168211031-b578ffe1-0b75-492e-aa9c-51993f3640e4.png" alt="App Preview" width="400"/>
</p>

### Installation

1. Clone the project: `git clone https://github.com/wassonglina/weather.git`
1. The file located at `Model/Secrets.swift` already contains an API key for the OpenWeather API. Since new keys take upwards of a few hours to become active, I've left a key included. However, if you'd like to create your own, follow this process:
	1. Sign up for [OpenWeather](https://home.openweathermap.org/users/sign_up).
	1. Copy of your default [API key](https://home.openweathermap.org/api_keys).
	1. Set the value of `openWeatherAppID` in `Model/Secrets.swift` to be your API key.

### License

Weather Pal is released under the [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode).
