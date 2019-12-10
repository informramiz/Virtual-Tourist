//
//  ImagesPage.swift
//  VirtualTourist
//
//  Created by Ramiz on 10/12/2019.
//  Copyright © 2019 RR Inc. All rights reserved.
//

import Foundation

struct ImagesPage: Decodable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let images: [Image]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perpage
        case total
        case images = "photo"
    }
}
