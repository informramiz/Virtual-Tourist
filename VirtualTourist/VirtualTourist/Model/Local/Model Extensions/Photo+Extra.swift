//
//  Photo+Extra.swift
//  VirtualTourist
//
//  Created by Apple on 10/12/2019.
//  Copyright © 2019 RR Inc. All rights reserved.
//

import Foundation
extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
