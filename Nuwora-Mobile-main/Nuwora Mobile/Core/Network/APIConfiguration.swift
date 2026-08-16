import Foundation

struct APIConfiguration: Equatable {
    static let defaultLocalBaseURL = URL(string: "http://127.0.0.1:3000/v1")!
    static let unconfiguredProductionBaseURL = URL(string: "https://api.nuwora.invalid/v1")!

    let baseURL: URL
    let requestTimeout: TimeInterval

    init(baseURL: URL, requestTimeout: TimeInterval = 30) {
        self.baseURL = baseURL
        self.requestTimeout = requestTimeout
    }

    static func fromProcess() -> APIConfiguration {
        let processValue = ProcessInfo.processInfo.environment["NUWORA_API_BASE_URL"]
        let bundleValue = Bundle.main.object(forInfoDictionaryKey: "NuworaAPIBaseURL") as? String
        let rawValue = processValue ?? bundleValue

        guard let rawValue,
              rawValue.isEmpty == false,
              let url = URL(string: rawValue),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https"
        else {
            #if DEBUG
            return APIConfiguration(baseURL: defaultLocalBaseURL)
            #else
            return APIConfiguration(baseURL: unconfiguredProductionBaseURL)
            #endif
        }

        return APIConfiguration(baseURL: url)
    }
}
