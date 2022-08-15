//
//  ViewController.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 05.04.21.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//

import Cocoa
import CoreBluetooth
import AppKit

let deviceInformationServiceCBUUID = CBUUID(string: "0x180A")
let genericAccessServiceCBUUID = CBUUID(string: "0x1800")
let geneticAttributeServiceCBUUID = CBUUID(string: "0x1801")

struct PeripheralPackage {
    var peripheral: CBPeripheral?
    var advertised_name: String?
    var RSSI: NSNumber?
}

protocol BluetoothServiceDelegate: AnyObject {
    func moveTable(_ direction: ViewController.DirectionCommand)
}

class ViewController: NSViewController, CBPeripheralDelegate, CBCentralManagerDelegate, BluetoothServiceDelegate{

    enum DirectionCommand {
        case up
        case down
    }
    
    enum IntervalType {
        case sittingInterval
        case standingInterval
    }
    
    var centralManager: CBCentralManager!
    private(set) var peripheral: CBPeripheral!
    private var lastConnectedPeripheral: CBPeripheral?
    private var characteristicForWriting: CBCharacteristic!
    private(set) var foundPeripherals: Set<CBPeripheral> = []
    private var foundPeripheralsPackages: PeripheralPackage?
    
    private var command: DirectionCommand = .up
    private var stopSendingCommands = true
    private let commandUpArray: [UInt8] = [0xF1, 0xF1, 0x01, 0x00, 0x01, 0x7E]
    private let commandDownArray: [UInt8] = [0xF1, 0xF1, 0x02, 0x00, 0x02, 0x7E]
    private let commandGetMinMaxHeight: [UInt8] = [0xF1, 0xF1, 0x0C, 0x00, 0x0C, 0x7E]
    private let timeInterval = 0.5
    
    private var commandsSendingTimer: Timer?
    
    @IBOutlet var leftView: NSView!
    @IBOutlet var rightView: NSView!
    @IBOutlet var topView: NSView!
    @IBOutlet var upButtonOutlet: NSButton!
    @IBOutlet var downButtonOutlet: NSButton!
    @IBOutlet weak var heightAdjustButton: FlatButton!
    private var heightMenuController: HeightMenuController?
    @IBOutlet weak var sitModeInterval: NSDatePicker!
    @IBOutlet weak var standModeInterval: NSDatePicker!
    
    @IBOutlet weak var peripheralsMenuCollectionView: NSCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        view.layer?.backgroundColor = NSColor(red: 0.333, green: 0.42, blue: 0.5, alpha: 1).cgColor
        view.layer?.cornerRadius = 15
        
        heightMenuController = HeightMenuController.loadFromNib(nextTo: heightAdjustButton)
        heightAdjustButton.target = heightMenuController
        heightAdjustButton.action = #selector(heightMenuController?.togglePopover)
        
        setupCollectionView()
        
        sitModeInterval.dateValue = TimerService.shared.getDateFromInterval(.sittingInterval)
        standModeInterval.dateValue = TimerService.shared.getDateFromInterval(.standingInterval)
        
        TimerService.shared.bluetoothServiceDelegate = self
    }
    
    override func viewWillAppear() {
//        NotificationService.shared.sendNotification(notificationType: .goingDown)
    }
    
    @IBAction func upButton(_ sender: Any) {
        
        command = .up
        
        if upButtonOutlet.state == .on {
            stopSendingCommands = true
            downButtonOutlet.state = .off
//            print(upButtonOutlet.state)
        } else {
            stopSendingCommands = false
//            print(upButtonOutlet.state)
        }
        
        if commandsSendingTimer == nil {
            commandsSendingTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(sendCommand), userInfo: nil, repeats: true)
//            print(upButtonOutlet.state)
        }
    }
    
    @IBAction func downButton(_ sender: Any) {
        command = .down
        
        if downButtonOutlet.state == .on {
            stopSendingCommands = true
            upButtonOutlet.state = .off
        } else {
            stopSendingCommands = false
        }

        if commandsSendingTimer == nil {
            commandsSendingTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(sendCommand), userInfo: nil, repeats: true)
        }
    }
    
    //MARK: - Sending BLE commands
    @objc func sendCommand() {
        if stopSendingCommands {
            commandsSendingTimer?.invalidate()
            commandsSendingTimer = nil
        }
        var data = NSData()
        if command == .up {
            data = NSData(bytes: commandUpArray, length: 6)
        } else {
            data = NSData(bytes: commandDownArray, length: 6)
        }
        guard characteristicForWriting != nil else {return}
        peripheral?.writeValue(data as Data, for: characteristicForWriting, type: .withResponse)
    }
    
    func askMinMaxHeight() {
        let data = NSData(bytes: commandGetMinMaxHeight, length: 6)
    
        guard characteristicForWriting != nil else {return}
        peripheral?.writeValue(data as Data, for: characteristicForWriting, type: .withoutResponse)
    }
    
    func moveTable(_ direction: DirectionCommand) {
        command = direction
        stopSendingCommands = false
        
        commandsSendingTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(sendCommand), userInfo: nil, repeats: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.stopSendingCommands = true
        }
    }
    
    func getTimeInterval(intervalType: IntervalType) -> TimeInterval {
        let dateValue: Date
        
        switch intervalType {
        case .sittingInterval:
            dateValue = sitModeInterval.dateValue
        case .standingInterval:
            dateValue = standModeInterval.dateValue
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        formatter.timeStyle = .short
        let timeString = formatter.string(from: dateValue)
        let timeComponenetsArray = timeString.components(separatedBy: ":")
        let timeComponenetsArrayInt = timeComponenetsArray.map { Int($0)! }
        let totalSecondsCount = timeComponenetsArrayInt[0] * 3600 + timeComponenetsArrayInt[1] * 60
        let timeInterval = TimeInterval(totalSecondsCount)
        return timeInterval
    }
    
    @IBAction func sitTimeIntervalDidChange(_ sender: Any) {
        TimerService.shared.sittingTime = getTimeInterval(intervalType: .sittingInterval)
    }
    
    @IBAction func standTimeIntervalDidChange(_ sender: Any) {
        TimerService.shared.standingTime = getTimeInterval(intervalType: .standingInterval)
    }
    
    
    //MARK: - Bluetooth stuff
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("Turn bluetooth on!")
        case .poweredOn:
            foundPeripherals = []
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            if let lastConnectedPeripheral = self.lastConnectedPeripheral {
                centralManager.connect(lastConnectedPeripheral, options: nil)
            }

        @unknown default:
            fatalError()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
//        self.peripheral = peripheral
//        peripheral.delegate = self
        
        var peripheralPackage = PeripheralPackage()
        peripheralPackage.peripheral = peripheral
        peripheralPackage.RSSI = RSSI
        
        let peripheralLocalName_advertisement = ((advertisementData as NSDictionary).value(forKey: "kCBAdvDataLocalName")) as? String
        if let advertised_name = peripheralLocalName_advertisement {
            peripheralPackage.advertised_name = advertised_name
        }
        
        guard peripheral.name != nil else {return}
        foundPeripherals.insert(peripheral)
        peripheralsMenuCollectionView.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //print("Connected!")
//        guard !trialConnection else {
//            if nameDidChange {
//                trialConnection = false
//                central.cancelPeripheralConnection(peripheral)
//            }
//            return
//        }
        toggleConnectionIndicator(peripheral: peripheral, isConnected: true)
        TimerService.shared.setupTimer(ofType: TimerService.shared.currentActivityType)
        
        self.peripheral = peripheral
        self.lastConnectedPeripheral = peripheral
        peripheral.delegate = self
        
        peripheral.discoverServices([CBUUID(string: "FF12")])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
    }
    
//    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
//        print("kek", peripheral.name ?? "nil")
//        nameDidChange = true
//    }
    
}

extension ViewController{
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard peripheral.services != nil else {return}
        guard let services = peripheral.services else { return }
        
        for service in services{
//            print(service)
            peripheral.discoverCharacteristics([CBUUID(string: "FF01"), CBUUID(string: "FF02")], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        
        for characteristic in characteristics{
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.uuid.uuidString.contains("FF01") {
                characteristicForWriting = characteristic
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
                    self?.askMinMaxHeight()
                })
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("new NotificationsState value ", characteristic, characteristic.isNotifying)
    }
        
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        MARK:  Received commands debug
        
//        var characteristicsValue = characteristic.value
//        withUnsafeBytes(of: &characteristicsValue) { (bytes) in
//            var arr = [String]()
//            for byte in bytes {
//                arr.append(String(format:"%02X", byte))
//                if arr.last == "7E" {
//                    break
//                }
//            }
//            print(arr)
//        }
        
        var characteristicsValue = characteristic.value
        withUnsafeBytes(of: &characteristicsValue) { (bytes) in
            for (index, byte) in bytes.enumerated() {
                let hexByte = String(format:"%02X", byte)
                
                if hexByte == "7E" { return }
                
                switch index {
                case 0...1:
                    if hexByte != "F2" {
                        return
                    }
                case 2:
                    switch hexByte {
                    case "01":
                        let height = getHeightFromCharacteristic(characteristic: characteristic)
                        
                        if let height = height {
                            // should remove magic numbers
                            if (400...2000).contains(height) {
                                HeightService.shared.currentHeight = height
                            }
                        }
                    case "07":
                        let minMaxHeight = getMinMaxHeight(characteristic: characteristic)
                        print("min — \(String(describing: minMaxHeight?.min)), max — \(String(describing: minMaxHeight?.max))")
                        HeightService.shared.tableHeightRange = minMaxHeight
                    default:
                        return
                    }
                default:
                    return
                }
            }
        }

        
    }
    
    private func getHeightFromCharacteristic(characteristic: CBCharacteristic) -> Int? {
        let value = characteristic.value?.withUnsafeBytes { (bytes) -> Int? in
            
            var heightHighBite: Int?
            var heightLowBite: Int?

            for (index, byte) in bytes.enumerated() {
                if index == 4 {
                    heightHighBite = Int(byte)
                }
                else if index == 5 {
                    heightLowBite = Int(byte)
                }
            }
            guard let heightLowBite = heightLowBite, let heightHighBite = heightHighBite else {
                return nil
            }
            let heightInMM = heightHighBite * 256 + heightLowBite

            return heightInMM
        }
        
        return value
    }
    
    private func getMinMaxHeight(characteristic: CBCharacteristic) -> (min: Int, max: Int)? {
        let value = characteristic.value?.withUnsafeBytes { (bytes) -> (min: Int, max: Int) in
            
            var iterator = bytes.makeIterator()
            var index = 0
            
            var minHeight: Int = 400
            var maxHeight: Int = 1400
            
            while let byte = iterator.next() {
                if index == 4 {
                    maxHeight = Int(byte) * 256 + Int(iterator.next() ?? UInt8(0))
                    index += 1
                }
                if index == 6 {
                    minHeight = Int(byte) * 256 + Int(iterator.next() ?? UInt8(0))
                    index += 1
                }
                index += 1
            }

//            for (index, byte) in bytes.enumerated() {
//                if index == 4 {
//
//                }
//            }
            

            return (minHeight, maxHeight)
        }
        
        return value
    }
}

extension ViewController {
    
    static func freshViewController() -> ViewController {
        
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        
        let identifier = NSStoryboard.SceneIdentifier("ViewController")
        
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? ViewController
            else {
                fatalError("Why can't i find ViewController? - Check Main.storyboard")
        }
                
        return viewController
    }
    
    func getFoundPeripheral(index: Int) -> CBPeripheral? {
        let setIndex = foundPeripherals.index(foundPeripherals.startIndex, offsetBy: index)
        if foundPeripherals.indices.contains(setIndex) { return foundPeripherals[setIndex] }
        return nil
    }
}
