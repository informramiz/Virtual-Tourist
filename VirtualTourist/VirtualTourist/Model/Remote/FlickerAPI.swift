//
//  FlickerAPI.swift
//  VirtualTourist
//
//  Created by Ramiz on 10/12/2019.
//  Copyright © 2019 RR Inc. All rights reserved.
//

import Foundation
import UIKit

class FlickerAPI {
    struct Auth {
        static let API_KEY = "c6124d151ce794dbfb0fdbe6c138b0ce"
    }
    
    static let itemsPerPage = 20
    static let maxPages = 500
    
    enum EndPoint {
        static let baseUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Auth.API_KEY)"
        case base
        case fetchPhotos(Double, Double, Int)
        
        var stringValue: String {
            switch self {
            case .base:
                return EndPoint.baseUrl
            case .fetchPhotos(let latitude, let longitude, let page):
                return EndPoint.baseUrl + "&bbox=\(getBbox(latitude, longitude))&extras=url_m&format=json&nojsoncallback=1&safe_search=1&per_page=\(FlickerAPI.itemsPerPage)&page=\(page)"
            }
        }
        
        func getBbox(_ lat: Double, _ lon: Double) -> String {
            //Remember: Longitude has a range of -180 to 180 , latitude of -90 to 90.
            let minLat = max(lat - 1, -90)
            let maxLat = min(lat + 1, 90)
            let minLon = max(lon - 1, -180)
            let maxLon = min(lon + 1, 180)
            return "\(minLon),\(minLat),\(maxLon),\(maxLat)"
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
    }
    
    class func fetchPhotos(pin: Pin, page: Int, completion: @escaping (FlickerImagesResponse?, Error?) -> Void) {
        let fetchEndPoint = EndPoint.fetchPhotos(pin.latitude, pin.longitude, page)
        let notifyOnMain = {(data: FlickerImagesResponse?, error: Error?) in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        
        let task = URLSession.shared.dataTask(with: fetchEndPoint.url) { (data, response, error) in
            guard let data = data else {
                notifyOnMain(nil, error)
                return
            }
            
            do {
                let flickerImagesResponse = try JSONDecoder().decode(FlickerImagesResponse.self, from: data)
                notifyOnMain(flickerImagesResponse, nil)
            } catch {
                notifyOnMain(nil, error)
            }
        }
        
        task.resume()
    }
    
    @discardableResult
    class func downloadImage(url: String, completion: @escaping (UIImage?, Error?) -> Void) -> URLSessionDataTask{
        let notifyOnMain = {(data: UIImage?, error: Error?) in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                notifyOnMain(nil, error)
                return
            }
            
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                notifyOnMain(image, nil)
            }
        }
        task.resume()
        return task
    }
}
