//
//  FlickerResponse.swift
//  VirtualTourist
//
//  Created by Ramiz on 10/12/2019.
//  Copyright © 2019 RR Inc. All rights reserved.
//

import Foundation

struct FlickerImagesResponse: Decodable {
    let imagesPage: ImagesPage
    
    enum CodingKeys: String, CodingKey {
        case imagesPage = "photos"
    }
}
