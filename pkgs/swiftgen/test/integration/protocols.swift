import Foundation

@objc protocol TestWeatherServiceDelegate: AnyObject {
    @objc func didUpdateWeather(_ weather: String)
}

@objc protocol TestAsyncProtocol: AnyObject {
    @objc func fetchData(param: String) async -> String
}

@objc class TestWeatherService: NSObject {
    @objc static func fetchWeather(delegate: TestWeatherServiceDelegate) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            delegate.didUpdateWeather("Sunny, 25°C")
        }
    }
}

@objc class TestSwiftInvoker: NSObject {
    @objc static func invokeAsyncMethod(protocolInstance: TestAsyncProtocol, param: String) async -> String {
        return await protocolInstance.fetchData(param: param)
    }

    @objc static func invokeAsyncMethodOnBackgroundThread(protocolInstance: TestAsyncProtocol, param: String) async -> String {
        return await Task.detached {
            return await protocolInstance.fetchData(param: param)
        }.value
    }
}
