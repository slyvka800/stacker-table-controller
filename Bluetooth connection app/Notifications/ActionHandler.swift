//
//  ActionHandler.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 20.03.2022.
//  Copyright © 2022 Павло Сливка. All rights reserved.
//

import Foundation

final class ActionHandler {
    
    static let shared = ActionHandler()
    
    private init() {}
    
    func skip() {
        print("skip")
    }
    
    func postpone() {
        TimerService.shared.setupTimer(ofType: <#T##TimerService.TimerType#>)
    }
}
