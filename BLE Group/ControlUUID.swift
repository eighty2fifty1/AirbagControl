//
//  RepeaterUUID.swift
//  BrakeSensor
//
//  Created by James Ford on 9/11/21.
//

import Foundation
import CoreBluetooth

struct ControlUUID {
    static let PRESSURE_SERVICE_UUID = "e4a838e1-5307-424d-a288-e1c66365a215"
    static let LEFT_PRESS_CHAR_UUID = "64a4c480-1910-4059-a642-44515115ebc1"
    static let RIGHT_PRESS_CHAR_UUID = "384b9e03-ad97-4549-98a2-c4479318263c"

    static let SETTING_SERVICE_UUID = "b01d4b71-6794-415f-aee8-7edd21ce4eec"
    static let LEFT_SETTING_CHAR_UUID = "c017926e-77ec-4286-8f40-af49b0d63ff8"
    static let RIGHT_SETTING_CHAR_UUID = "27b67d88-8da0-4bc5-a689-6fe3c6cb9133"
    static let MODE_CHAR_UUID = "8bd8c597-f228-4f52-a6ee-194a76d0bd01"

    static let STATUS_SERVICE_UUID = "ef4462fb-996b-416b-b7db-d753f99a712b"
    static let PUMP_CONT_UUID = "ee0a9c1a-6326-4e12-9158-f95726fbf3f1"
    static let LEFT_DUMP_UUID = "99bb0d87-5285-4e9d-b892-ece4c6b4cc09"
    static let LEFT_FILL_UUID = "6bf9c462-afe7-4635-aed4-f3015ac1b285"
    static let RIGHT_DUMP_UUID = "c30450fa-45ad-4a16-96a4-d49dbb17e47c"
    static let RIGHT_FILL_UUID = "621d4344-380a-4f88-badd-584fee712f1b"
    
    static let pressServiceUUID = CBUUID(string: PRESSURE_SERVICE_UUID)
    static let leftPressCharUUID = CBUUID(string: LEFT_PRESS_CHAR_UUID)
    static let rightPressCharUUID = CBUUID(string: RIGHT_PRESS_CHAR_UUID)
    
    static let settingServiceUUID = CBUUID(string: SETTING_SERVICE_UUID)
    static let leftSettingCharUUID = CBUUID(string: LEFT_SETTING_CHAR_UUID)
    static let rightSettingCharUUID = CBUUID(string: RIGHT_SETTING_CHAR_UUID)
    static let modeCharUUID = CBUUID(string: MODE_CHAR_UUID)
    
    static let statusServiceUUID = CBUUID(string: STATUS_SERVICE_UUID)
    static let pumpContUUID = CBUUID(string: PUMP_CONT_UUID)
    static let leftDumpUUID = CBUUID(string: LEFT_DUMP_UUID)
    static let leftFillUUID = CBUUID(string: LEFT_FILL_UUID)
    static let rightDumpUUID = CBUUID(string: RIGHT_DUMP_UUID)
    static let rightFillUUID = CBUUID(string: RIGHT_FILL_UUID)
    
    // from android app.  not sure if needed yet
    // public static final UUID CONFIG_DESCRIPTOR = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")
}
