import Foundation

@objc protocol TestWeatherServiceDelegate: AnyObject {
    @objc func didUpdateWeather(_ weather: String)
}

@objc class TestWeatherService: NSObject {
    @objc static func fetchWeather(delegate: TestWeatherServiceDelegate) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            delegate.didUpdateWeather("Sunny, 25°C")
        }
    }
}
