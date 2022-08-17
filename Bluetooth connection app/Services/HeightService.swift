//
//  HeightService.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 13.08.2022.
//  Copyright © 2022 Павло Сливка. All rights reserved.
//

import Foundation

struct HeightRange: Decodable, Encodable {
    var min: Int
    var max: Int
}

class HeightService {
    
    static let shared = HeightService()
    
    @StorageCodable(key: "userHeightRange")
    var userHeightRangeStored: HeightRange?
    
    var userHeightRange: (min: Int, max: Int)? {
        get {
            if let userHeightRangeStored = userHeightRangeStored {
                return (userHeightRangeStored.min, userHeightRangeStored.max)
            }
            
            return nil
        }
        set {
            if let newValue = newValue {
                let newHeightRange = HeightRange(min: newValue.min, max: newValue.max)
                userHeightRangeStored = newHeightRange
            } else {
                userHeightRangeStored = nil
            }
        }
    }
    
    var currentHeight: Int?
    var tableHeightRange: (min: Int, max: Int)?
    
    private init() {}
    
    func isCurrentHeightInTablesRange() -> Bool {
        guard let currentHeight = currentHeight else {
            return true
        }
        
        let minHeight = tableHeightRange?.min ?? Constants.defaultHeightRange.min
        let maxHeight = tableHeightRange?.max ?? Constants.defaultHeightRange.max
        
        return ((minHeight + 1)..<maxHeight) ~= currentHeight
    }
}
