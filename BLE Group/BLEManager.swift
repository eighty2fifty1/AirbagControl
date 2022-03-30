//
//  CoreBLEDelegate.swift
//  BrakeSensor
//
//  Created by James Ford on 9/7/21.
//

import Foundation
import CoreBluetooth
import OSLog

struct Peripheral: Identifiable {
    let id: Int
    let name:  String
    let rssi: Int
}

class BLEManager: NSObject, ObservableObject, CBPeripheralDelegate, CBCentralManagerDelegate{

    private var bleController: CBPeripheral!
    
    //published vars for bluetooth stuff
    @Published var centralManager: CBCentralManager!
    @Published var isSwitchedOn = false
    @Published var isScanning = false
    @Published var isConnected = false
    @Published var didDisconnect = false
    @Published var bleStatusMessage = "Unknown"
    
    //published vars for controller data
    @Published var leftDumpSolenoid: Int = 0
    @Published var leftFillSolenoid: Int = 0
    @Published var rightDumpSolenoid: Int = 0
    @Published var rightFillSolenoid: Int = 0
    @Published var pumpRelay: Int = 0
    @Published var leftPress: Int = 46
    @Published var rightPress: Int = 46
    @Published var leftSetting: Int = 50
    @Published var rightSetting: Int = 50
    
    //@Published var repeaterRSSI: String!
        
    //services
    private var serviceUUIDs: [CBUUID] = [ControlUUID.pressServiceUUID,
                                      ControlUUID.settingServiceUUID,
                                      ControlUUID.statusServiceUUID]
    
    //characteristics that read and write
    private var readWriteCharacteristicUUIDs: [CBUUID] = [
                                             ControlUUID.leftSettingCharUUID,
                                             ControlUUID.rightSettingCharUUID,
                                             ControlUUID.modeCharUUID]
    
    //characteristics that subscribe to notifications
    private var notificationCharUUIDs: [CBUUID] = [ControlUUID.leftPressCharUUID,
                                                   ControlUUID.rightPressCharUUID,
                                                   ControlUUID.leftFillUUID,
                                                   ControlUUID.leftDumpUUID,
                                                   ControlUUID.rightDumpUUID,
                                                   ControlUUID.rightFillUUID,
                                                   ControlUUID.pumpContUUID]
    
        
    let customLog = Logger()
    
    override init() {
        
        super.init()
            
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isSwitchedOn = true
            isScanning = false
            startScanning()
        } else {
            isSwitchedOn = false
        }
    }
    
    func startScanning() -> Void {
        centralManager.scanForPeripherals(withServices: serviceUUIDs)
        isScanning = true
        print("scanning")
        bleStatusMessage = "Scanning..."
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        bleController = peripheral
        bleController.delegate = self
        centralManager?.stopScan()
        isScanning = false
        bleStatusMessage = "Found Airbag Controller"
        customLog.notice("Found the device: \(self.bleController.name!)")
        centralManager?.connect(bleController!, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        print("connected to \(peripheral)")
        bleStatusMessage = "Connected"
        didDisconnect = false
        bleController.discoverServices(serviceUUIDs)
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        bleStatusMessage = "Unable to connect"
        print("unable to connect")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        didDisconnect = true
        print("disconnected, attempting to reconnect...")
        bleStatusMessage = "Disconnected, attempting to reconnect"
        startScanning()
    }
    
    /*
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        repeaterRSSI = RSSI.stringValue
    }
 */
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if ((error) != nil){
            bleStatusMessage = "Error discovering services: \(error!.localizedDescription)"
            return
        }
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {peripheral.discoverCharacteristics(readWriteCharacteristicUUIDs, for: service)
        }
        
        customLog.notice("Discovered services: \(services)")
        
        for service in services {peripheral.discoverCharacteristics(notificationCharUUIDs, for: service)
        }
        
        customLog.notice("Discovered notify services: \(services)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        customLog.notice("Found \(characteristics.count) characteristics")
        
        for characteristic in characteristics {
            if notificationCharUUIDs.contains(characteristic.uuid) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("enable notification for \(characteristic)")
            }
        }
    }
    
    //called when notification sent
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        if let error = error {
            customLog.error("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        guard let characteristicData = characteristic.value,
              let stringFromData = String(data: characteristicData, encoding: .utf8) else {
            return
        }
        
        if characteristic.uuid.isEqual(ControlUUID.leftFillUUID) {
            leftFillSolenoid = Int(stringFromData) ?? 0
        }
        else if characteristic.uuid.isEqual(ControlUUID.leftDumpUUID) {
            leftDumpSolenoid = Int(stringFromData) ?? 0
        }
        else if characteristic.uuid.isEqual(ControlUUID.rightFillUUID) {
            rightFillSolenoid = Int(stringFromData) ?? 0
        }
        else if characteristic.uuid.isEqual(ControlUUID.rightDumpUUID) {
            rightDumpSolenoid = Int(stringFromData) ?? 0
        }
        else if characteristic.uuid.isEqual(ControlUUID.pumpContUUID) {
            pumpRelay = Int(stringFromData) ?? 0
        }

    }
    
    func increasePress(posit: String) {
        if posit == "Left" {
            if leftSetting < 100 {
                leftSetting += 5
            }
            else {
                leftSetting = 100
            }
            
            
        }
        else {
            if rightSetting < 100 {
                rightSetting += 5

            }
            else {
                rightSetting = 100
            }
        }
    }
    
    func decreasePress(posit: String) {
        if posit == "Left" {
            if leftSetting > 5{
                leftSetting -= 5
            }
            else {
                leftSetting = 0
                
            }
        }
        else {
            if rightSetting > 5 {
                rightSetting -= 5
            }
            
            else {
                rightSetting = 0
                
            }
        }
    }
}
