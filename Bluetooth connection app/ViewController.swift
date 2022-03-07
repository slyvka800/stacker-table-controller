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

class ViewController: NSViewController, CBPeripheralDelegate, CBCentralManagerDelegate{
    
    enum DirectionCommand {
        case up
        case down
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
    private let timeInterval = 0.5
    
    private var commandsSendingTimer: Timer?
    
    @IBOutlet var leftView: NSView!
    @IBOutlet var rightView: NSView!
    @IBOutlet var topView: NSView!
    @IBOutlet var upButtonOutlet: NSButton!
    @IBOutlet var downButtonOutlet: NSButton!
    @IBOutlet weak var heightAdjustButton: FlatButton!
    private var heightMenuController: HeightMenuController?
    
    @IBOutlet weak var peripheralsMenuCollectionView: NSCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        view.layer?.backgroundColor = NSColor(red: 0.333, green: 0.42, blue: 0.5, alpha: 1).cgColor
        view.layer?.cornerRadius = 15
        
        heightMenuController = HeightMenuController(nextTo: heightAdjustButton)
        heightAdjustButton.target = heightMenuController
        heightAdjustButton.action = #selector(heightMenuController?.togglePopover)
        
        setupCollectionView()
    }
    
    @IBAction func upButton(_ sender: Any) {
        
        command = .up
        
        if upButtonOutlet.state == .on {
            stopSendingCommands = true
            downButtonOutlet.state = .off
            print(upButtonOutlet.state)
        } else {
            stopSendingCommands = false
            print(upButtonOutlet.state)
        }
        
        if commandsSendingTimer == nil {
            commandsSendingTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(sendCommand), userInfo: nil, repeats: true)
            print(upButtonOutlet.state)
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
    
    func printActivity(_ messageStr: String){
//        print(messageStr)
//        displayWithActivity?.stringValue = messageStr
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
//            displayWithActivity.stringValue = "Turn bluetooth on!"
            print("Turn bluetooth on!")
        case .poweredOn:
//            displayWithActivity.stringValue = "Bluetooth is turned on"
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
        
        self.peripheral = peripheral
        self.lastConnectedPeripheral = peripheral
        peripheral.delegate = self
        
//        displayWithActivity.stringValue = "Connected to \(peripheral.name ?? "unknown")!"
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
//        displayWithActivity.stringValue = "Disconnected"
    }
    
//    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
//        print("kek", peripheral.name ?? "nil")
//        nameDidChange = true
//    }
    
}

extension ViewController{
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard peripheral.services != nil else {return}
        guard let services = peripheral.services else {return}
        
        for service in services{
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {return}
        
        for characteristic in characteristics{
            print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
            }
            if characteristic.properties.contains(.write) {
                print("\(characteristic.uuid): properties contains .write")
                characteristicForWriting = characteristic
            }
            if characteristic.uuid.uuidString.contains("FF01") {
                characteristicForWriting = characteristic
                break
            }
        }
//        NSWorkspace.willSleepNotification
        
    }
        
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
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
