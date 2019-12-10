//
//  Photo.swift
//  VirtualTourist
//
//  Created by Ramiz on 10/12/2019.
//  Copyright © 2019 RR Inc. All rights reserved.
//

import Foundation
struct Image: Codable {
    let id: String
    let title: String
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url = "url_m"
    }
}
