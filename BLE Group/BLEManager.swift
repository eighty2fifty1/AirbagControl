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
    
    //characteristics
    @Published var modeChar: CBCharacteristic!
    @Published var leftSettingChar: CBCharacteristic!
    @Published var rightSettingChar: CBCharacteristic!
    @Published var leftPressChar: CBCharacteristic!
    @Published var rightPressChar: CBCharacteristic!
    @Published var leftDumpChar: CBCharacteristic!
    @Published var rightDumpChar: CBCharacteristic!
    @Published var leftFillChar: CBCharacteristic!
    @Published var rightFillChar: CBCharacteristic!
    @Published var pumpRelayChar: CBCharacteristic!

    
    //published vars for controller data
    @Published var mode: Int = 0;   //0 for auto mode, 1 for manual
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
    

    
    //characteristics
    private var charUUIDs: [CBUUID] = [ControlUUID.leftSettingCharUUID,
                                                   ControlUUID.rightSettingCharUUID,
                                                   ControlUUID.modeCharUUID,
                                                   ControlUUID.leftPressCharUUID,   //notify
                                                   ControlUUID.rightPressCharUUID,  //notify
                                                   ControlUUID.leftFillUUID,        //notify
                                                   ControlUUID.leftDumpUUID,        //notify
                                                   ControlUUID.rightDumpUUID,       //notify
                                                   ControlUUID.rightFillUUID,       //notify
                                                   ControlUUID.pumpContUUID]        //notify
    
        
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
        
        for service in services {
            peripheral.discoverCharacteristics(charUUIDs, for: service)
        }
        
        customLog.notice("Discovered services: \(services)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        customLog.notice("Found \(characteristics.count) characteristics")
        
        for characteristic in characteristics {
            if characteristic.uuid.isEqual(ControlUUID.leftSettingCharUUID) {
                leftSettingChar = characteristic
                bleController.readValue(for: leftSettingChar)
                print("left setting")
            }
            else if characteristic.uuid.isEqual(ControlUUID.rightSettingCharUUID) {
                rightSettingChar = characteristic
                bleController.readValue(for: rightSettingChar)
                print("right setting")

            }
            else if characteristic.uuid.isEqual(ControlUUID.modeCharUUID) {
                modeChar = characteristic
                print("mode setting")

            }
            else if characteristic.uuid.isEqual(ControlUUID.leftPressCharUUID) {
                leftPressChar = characteristic
                peripheral.setNotifyValue(true, for: leftPressChar)
                print("left press")

            }
            else if characteristic.uuid.isEqual(ControlUUID.rightPressCharUUID) {
                rightPressChar = characteristic
                peripheral.setNotifyValue(true, for: rightPressChar)
                print("right press")

            }
            else if characteristic.uuid.isEqual(ControlUUID.leftDumpUUID) {
                leftDumpChar = characteristic
                peripheral.setNotifyValue(true, for: leftDumpChar)
                print("left dump")

            }
            else if characteristic.uuid.isEqual(ControlUUID.rightDumpUUID) {
                rightDumpChar = characteristic
                peripheral.setNotifyValue(true, for: rightDumpChar)
                print("right dump")

            }
            else if characteristic.uuid.isEqual(ControlUUID.leftFillUUID) {
                leftFillChar = characteristic
                peripheral.setNotifyValue(true, for: leftFillChar)
                print("left fill")

            }
            else if characteristic.uuid.isEqual(ControlUUID.rightFillUUID) {
                rightFillChar = characteristic
                peripheral.setNotifyValue(true, for: rightFillChar)
                print("right fill")

            }
            else if characteristic.uuid.isEqual(ControlUUID.pumpContUUID) {
                pumpRelayChar = characteristic
                peripheral.setNotifyValue(true, for: pumpRelayChar)
                print("pump control")

            }
            
        }
    }
    
    //called when notification sent
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        if let error = error {
            customLog.error("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        let characteristicData = characteristic.value
        if characteristic == leftSettingChar || characteristic == rightSettingChar || characteristic == modeChar{
            if characteristic.isEqual(leftSettingChar) {
                let leftSettingString = String(data: characteristicData!, encoding: .utf8)
                leftSetting = Int(leftSettingString ?? "46") ?? 47
                print("setting val: " + leftSettingString!)
            }
            else if characteristic.isEqual(rightSettingChar) {
                let rightSettingString = String(data: characteristicData!, encoding: .utf8)
                rightSetting = Int(rightSettingString ?? "46") ?? 47
                print("setting val: " + rightSettingString!)

            }
            
            else if characteristic.isEqual(modeChar) {
                let modeString = String(data: characteristicData!, encoding: .utf8)
                mode = Int(modeString ?? "0") ?? 0
            }
        }
        else {
            var dataInt: Int16 = 0
            
            dataInt = characteristicData?.withUnsafeBytes( {
                    (pointer: UnsafeRawBufferPointer) ->
                    Int16 in
                    return pointer.load(as: Int16.self)
            }) ?? 46
            
            
            let dataInt_ = Int(dataInt)
            var dataSource: String = "none "
            
            
            if characteristic.isEqual(leftFillChar) {
                leftFillSolenoid = dataInt_
                dataSource = "left fill "
            }
            else if characteristic.isEqual(leftDumpChar) {
                leftDumpSolenoid = dataInt_
                dataSource = "left dump "
                //print(leftDumpSolenoid)
            }
            else if characteristic.isEqual(rightFillChar) {
                rightFillSolenoid = dataInt_
                dataSource = "right fill "
            }
            else if characteristic.isEqual(rightDumpChar) {
                rightDumpSolenoid = dataInt_
                dataSource = "right dump "
            }
            else if characteristic.isEqual(pumpRelayChar) {
                pumpRelay = dataInt_
                dataSource = "pump relay "
            }
            
            else if characteristic.isEqual(leftPressChar) {
                leftPress = dataInt_
                dataSource = "left press "
            }
            
            else if characteristic.isEqual(rightPressChar) {
                rightPress = dataInt_
                dataSource = "right press "
            }
            
            
            
        //print(dataSource + "notification: " + String(dataInt_))
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
            changePressSetting(newPress: leftSetting, posit: leftSettingChar)

            
        }
        else {
            if rightSetting < 100 {
                rightSetting += 5

            }
            else {
                rightSetting = 100
            }
            changePressSetting(newPress: rightSetting, posit: rightSettingChar)

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
            changePressSetting(newPress: leftSetting, posit: leftSettingChar)
            
            
        }
        else {
            if rightSetting > 5 {
                rightSetting -= 5
            }
            
            else {
                rightSetting = 0
                
            }
            changePressSetting(newPress: rightSetting, posit: rightSettingChar)
        }
    }
    
    func changePressSetting(newPress: Int, posit: CBCharacteristic) {
        let msgString: String = String(newPress)
        let data = Data(msgString.utf8)
        if isConnected {
            if bleController.canSendWriteWithoutResponse {
                print("can send without response")
            }
            else {print("cant send message without response idiot") }
            
            //print(msgChar.descriptors)
            
            bleController.writeValue(data, for: posit, type: .withResponse)
            print(msgString)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.bleController.readValue(for: posit)

            })
            //bleController.readValue(for: posit)
        }
    }
    
    func sendStatusMsg(msg: String) {
        let data = Data(msg.utf8)
        if isConnected {
            if bleController.canSendWriteWithoutResponse {
                print("can send without response")
            }
            else {print("cant send message without response idiot") }
            
            //print(msgChar.descriptors)
            
            bleController.writeValue(data, for: modeChar, type: .withResponse)
            print(msg)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.bleController.readValue(for: self.modeChar)

            })
        }
    }
    
    func pumpPower(msg: String) {
        let data = Data(msg.utf8)
        if isConnected {
            bleController.writeValue(data, for: pumpRelayChar, type: .withResponse)
            print(msg)
        }
    }
    
    func manualSolenoidControl(posit: CBCharacteristic, value: Int) {
        var data: Data
        if isConnected {
            if bleController.canSendWriteWithoutResponse {
                print("can send without response")
            }
            else {print("cant send message without response idiot") }
            
            //print(msgChar.descriptors)
            
            if value == 1 {
                data = Data(String("0").utf8)
            }
            else {
                data = Data(String("1").utf8)
            }
            
            bleController.writeValue(data, for: posit, type: .withResponse)
            print(posit.properties)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.bleController.readValue(for: posit)

            })
        }
    }
}
