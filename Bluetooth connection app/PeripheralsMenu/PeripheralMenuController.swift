//
//  PeripheralMenuController.swift
//  Bluetooth connection app
//
//  Created by Павло Сливка on 08.12.2021.
//  Copyright © 2021 Павло Сливка. All rights reserved.
//

import Cocoa
import CoreBluetooth

extension ViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    func setupCollectionView() {
        peripheralsMenuCollectionView.delegate = self
        peripheralsMenuCollectionView.dataSource = self
        peripheralsMenuCollectionView.isSelectable = true
        peripheralsMenuCollectionView.allowsEmptySelection = true
        peripheralsMenuCollectionView.allowsMultipleSelection = false
        peripheralsMenuCollectionView.register(PeripheralMenuItem.self, forItemWithIdentifier: PeripheralMenuItem.reuseIdentfier)
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return foundPeripherals.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let menuItem = collectionView.makeItem(withIdentifier: PeripheralMenuItem.reuseIdentfier, for: indexPath) as! PeripheralMenuItem
        let setIndex = foundPeripherals.index(foundPeripherals.startIndex, offsetBy: indexPath.item)
        
        if foundPeripherals.indices.contains(setIndex) {
            menuItem.peripheralNameLabel.stringValue = foundPeripherals[setIndex].name ?? "unknown"
            if foundPeripherals[setIndex] != peripheral {
                menuItem.peripheralConnectionStatus.isHidden = true
            }
        }
        return menuItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let cellIndex = indexPaths.first?.item else { return }
        if let selectedPeripheral = getFoundPeripheral(index: cellIndex) {
            if selectedPeripheral.state == .disconnected {
                centralManager.connect(selectedPeripheral, options: nil)
            }
            else if selectedPeripheral.state == .connected {
                centralManager.cancelPeripheralConnection(selectedPeripheral)
            }
            
        }
    }
    
    func toggleConnectionIndicator(peripheral: CBPeripheral, isConnected: Bool) {
        let numOfSections = peripheralsMenuCollectionView.numberOfSections
        
        (0..<numOfSections).forEach { aSection in
            (0..<peripheralsMenuCollectionView.numberOfItems(inSection: aSection)).forEach { anItem in
                let indexPath = IndexPath(item: anItem, section: aSection)
                if let item = peripheralsMenuCollectionView.item(at: indexPath), let castedItem = item as? PeripheralMenuItem {
                    castedItem.peripheralConnectionStatus.isHidden = !isConnected
                }
            }
        }
    }
}
