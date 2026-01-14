import Foundation

@objc class TestMessageService: NSObject {
    @objc static func fetchGreeting(completion: @escaping (String) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            completion("Hello from Swift!")
        }
    }

    @objc static func fetchGreetingAsync() async -> String {
        try? await Task.sleep(for: .seconds(0.1))
        return "Hello from Swift async!"
    }
}
