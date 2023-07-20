//
//  WeatherManager.swift
//  Clima
//
//  Created by Sneh Tyagi on 12/07/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation
protocol WeatherManagerDelegate {
    func didUpdateWeather(_weatherManager:WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
    }

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=9464b062e3098cc4f865dc55fe217290&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString  = "\(weatherURL)&q=\(cityName)"
        print(urlString)
        performRequest(with:urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest ( with urlString: String){
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error ) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData){
                        self.delegate?.didUpdateWeather(_weatherManager: self, weather:weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            if let json = try? JSONSerialization.jsonObject(with: weatherData, options: .mutableContainers),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                print(String(decoding: jsonData, as: UTF8.self))
            } else {
                print("json data malformed")
            }
        let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
        let id = decodedData.weather[0].id
        let temp = decodedData.main.temp
        let name = decodedData.name
            let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp)
            return weather
            print(weather.temperatureString)
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
}



}
