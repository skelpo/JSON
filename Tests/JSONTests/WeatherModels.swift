import Foundation

struct WeatherData: Codable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    
    let currently: WeatherDataPoint?
    let minutely: DataBlock?
    let hourly: DataBlock?
    let daily: DataBlock?
    
    let flags: WeatherFlags?
}

struct DataBlock: Codable {
    let data: [WeatherDataPoint]
    let summary: String?
    let icon: String?
}

struct WeatherFlags: Codable {
    let darkskyUnavailable: Bool?
    let sources: [String]
    let units: String
    
    enum CodingKeys: String, CodingKey {
        case darkskyUnavailable = "darksky-unavailable"
        case sources = "sources"
        case units = "units"
    }
}

struct WeatherDataPoint: Codable {
    let apparentTemperature: Float?
    let apparentTemperatureHigh: Float?
    let apparentTemperatureHighTime: Date?
    let apparentTemperatureLow: Float?
    let apparentTemperatureLowTime: Date?
    let cloudCover: Double?
    let dewPoint: Float?
    let humidity: Double?
    let icon: String?
    let moonPhase: Double?
    let nearestStormBearing: Float?
    let nearestStormDistance: Float?
    let ozone: Float?
    let precipAccumulation: Float?
    let precipIntensity: Float?
    let precipIntensityMax: Float?
    let precipIntensityMaxTime: Date?
    let precipProbability: Double?
    let precipType: String?
    let pressure: Double?
    let summary: String?
    let sunriseTime: Date?
    let sunsetTime: Date?
    let temperature: Float?
    let temperatureHigh: Float?
    let temperatureHighTime: Date?
    let temperatureLow: Float?
    let temperatureLowTime: Date?
    let time: Date
    let uvIndex: Double?
    let uvIndexTime: Date?
    let visibility: Double?
    let windBearing: Double?
    let windGust: Float?
    let windSpeed: Float?
}
