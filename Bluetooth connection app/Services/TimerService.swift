//
//  TimerService.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 20.03.2022.
//  Copyright © 2022 Павло Сливка. All rights reserved.
//

import Foundation

final class TimerService {
    
    enum TimerType {
        case sitting
        case standing
    }
    
    var standingTime: TimeInterval = 20 {
        didSet {
            setupTimer(ofType: .standing)
        }
    }
    
    var sittingTime: TimeInterval = 5 {
        didSet {
            setupTimer(ofType: .sitting)
        }
    }
    
    static let shared = TimerService()
    
    private var timer = Timer()
    
    private var currentMode: TimerType? = .sitting
    
    private init() {}
    
    private func setupTimer(ofType timerType: TimerType) {
        var newInterval: TimeInterval = 0
        
        switch timerType {
        case .sitting:
            newInterval = sittingTime
        case .standing:
            newInterval = standingTime
        }
        
        if currentMode == timerType {
            let timeElapsed = timer.timeInterval - timer.fireDate.timeIntervalSinceNow
            let timeRemainingForNewTimer = newInterval - timeElapsed
            let timeToNotification = timeRemainingForNewTimer - Constants.notiifcationBeforeMovementInterval
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: timeToNotification, target: self, selector: #selector(endInterval), userInfo: nil, repeats: false)
        } else {
            let timeToNotification = newInterval - Constants.notiifcationBeforeMovementInterval
            timer = Timer.scheduledTimer(timeInterval: timeToNotification, target: self, selector: #selector(endInterval), userInfo: nil, repeats: false)
        }
    }
    
    @objc private func endInterval() {
        currentMode = (currentMode == .sitting) ? .standing : .sitting
        let notificationType: NotificationService.NotificationType =
        (currentMode == .sitting) ? .goingDown : .goingUp
        
        NotificationService.shared.sendNotification(notificationType: notificationType)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.notiifcationBeforeMovementInterval) { [weak self] in
            print("there should be table moving")
            self?.setupTimer(ofType: self?.currentMode ?? .sitting)
        }
    }
    
}
