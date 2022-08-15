//
//  TimerService.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 20.03.2022.
//  Copyright © 2022 Павло Сливка. All rights reserved.
//

import Foundation

final class TimerService {
    
    enum TimerType: Int {
        case sitting
        case standing
    }
    
    @RawRepresentableStorage("currentActivityTimer", defaultValue: TimerType.sitting)
    var currentActivityType: TimerType
    
    @Storage(key: "standingTime", defaultValue: TimeInterval(180))
    var standingTime: TimeInterval {
        didSet {
            if currentActivityType == .standing {
                oldTimeInterval = oldValue
                setupTimer(ofType: .standing)
            }
        }
    }
    
    @Storage(key: "sittingTime", defaultValue: TimeInterval(60))
    var sittingTime: TimeInterval {
        didSet {
            if currentActivityType == .sitting {
                oldTimeInterval = oldValue
                setupTimer(ofType: .sitting)
            }
        }
    }
    
    //used to get TimeInterval of non-repeating timer after its TimeInterval was
    //changed during it was active
    private var oldTimeInterval: TimeInterval?
    
    static let shared = TimerService()
    
    private var timer = Timer()
        
    weak var bluetoothServiceDelegate: BluetoothServiceDelegate?
    
    private init() {}
    
    func setupTimer(ofType timerType: TimerType) {
        var newInterval: TimeInterval = 0
        
        switch timerType {
        case .sitting:
            newInterval = sittingTime
        case .standing:
            newInterval = standingTime
        }

        if currentActivityType == timerType {
            let timeElapsed: TimeInterval
            if timer.isValid {
                timeElapsed = oldTimeInterval ?? newInterval - timer.fireDate.timeIntervalSinceNow
                print("timer is set to - ", timer.timeInterval, "\nfrom now to fire date - ", timer.fireDate.timeIntervalSinceNow)
            } else {
                timeElapsed = oldTimeInterval ?? newInterval
            }
            print(timeElapsed)
            
            let timeRemainingForNewTimer = newInterval - timeElapsed
            print(timeRemainingForNewTimer)
            let timeToNotification = timeRemainingForNewTimer - Constants.notiifcationBeforeMovementInterval
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: timeToNotification, target: self, selector: #selector(endInterval), userInfo: nil, repeats: false)
            print("time is set to \(timeToNotification) in line 54")
        } else {
            timer.invalidate()
            let timeToNotification = newInterval - Constants.notiifcationBeforeMovementInterval
            timer = Timer.scheduledTimer(timeInterval: timeToNotification, target: self, selector: #selector(endInterval), userInfo: nil, repeats: false)
            print("time is set to \(timeToNotification) in line 58")
        }
        
        currentActivityType = timerType
    }
    
    @objc private func endInterval() {
        let currentModeWillBe = (self.currentActivityType == TimerType.sitting) ? TimerType.standing : TimerType.sitting
        let notificationType: NotificationService.NotificationType =
        (currentModeWillBe == .sitting) ? .goingDown : .goingUp
        
        NotificationService.shared.sendNotification(notificationType: notificationType)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.notiifcationBeforeMovementInterval) { [weak self] in
            guard let self = self else { return }
            print("there should be table moving")
            self.bluetoothServiceDelegate?.moveTable(notificationType == .goingUp ? ViewController.DirectionCommand.up : ViewController.DirectionCommand.down)
            self.setupTimer(ofType: self.currentActivityType == .sitting ? .standing : .sitting)
        }
    }
    
    func getDateFromInterval(_ intervalType: ViewController.IntervalType) -> Date {
        let intervalValue: TimeInterval
        
        switch intervalType {
        case .standingInterval:
            intervalValue = standingTime
        case .sittingInterval:
            intervalValue = sittingTime
        }
        var components = DateComponents()
        components.minute = Int( ( Int(intervalValue) % 3600 ) / 60)
        components.hour = Int( Int(intervalValue) / 3600 )
        
        let date = Calendar.current.date(from: components)
                
        return date ?? Date()
    }
    
    func prolongCurrentInterval() {
        switch currentActivityType {
        case .sitting:
            sittingTime += Constants.postponeInterval
        case .standing:
            standingTime += Constants.postponeInterval
        }
    }
    
}
