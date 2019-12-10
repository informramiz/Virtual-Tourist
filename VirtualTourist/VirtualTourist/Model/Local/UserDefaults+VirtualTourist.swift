//
//  UserDefaults+VirtualTourist.swift
//  VirtualTourist
//
//  Created by Apple on 11/12/2019.
//  Copyright © 2019 RR Inc. All rights reserved.
//

import Foundation
extension UserDefaults {
    enum Keys: String {
        case latitude
        case longitude
        case latitudeDelta
        case longitudeDelta
        case hasData
    }
    
    func setLatitude(latitude: Double) {
        UserDefaults.standard.set(latitude, forKey: Keys.latitude.rawValue)
    }
    
    func getLatitude() -> Double {
        return UserDefaults.standard.double(forKey: Keys.latitude.rawValue)
    }
    
    func setLongitude(longitude: Double) {
        UserDefaults.standard.set(longitude, forKey: Keys.longitude.rawValue)
    }
    
    func getLongitude() -> Double {
        return UserDefaults.standard.double(forKey: Keys.longitude.rawValue)
    }
    
    func setLatitudeDelta(delta: Double) {
        UserDefaults.standard.set(delta, forKey: Keys.latitudeDelta.rawValue)
    }
    
    func getLatitudeDelta() -> Double {
        return UserDefaults.standard.double(forKey: Keys.latitudeDelta.rawValue)
    }
    
    func setLongitudeDelta(delta: Double) {
        UserDefaults.standard.set(delta, forKey: Keys.longitudeDelta.rawValue)
    }
    
    func getLongitudeDelta() -> Double {
        return UserDefaults.standard.double(forKey: Keys.longitudeDelta.rawValue)
    }
    
    func hasData() -> Bool {
        UserDefaults.standard.object(forKey: Keys.latitude.rawValue) != nil
    }
}
