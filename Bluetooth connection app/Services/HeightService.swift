//
//  HeightService.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 13.08.2022.
//  Copyright © 2022 Павло Сливка. All rights reserved.
//

import Foundation

class HeightService {
    
    static let shared = HeightService()
    
    var currentHeight: Int?
    var minMaxHeight: (min: Int, max: Int)?
    
    private init() {}
}
