//
//  ContentView.swift
//  AirbagControl
//
//  Created by James Ford on 3/19/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var bleManager: BLEManager
    //var leftPress: Int
    //var rightPress: Int
    //var leftSetting: Int = 46
    //var rightSetting: Int = 46
    
    var body: some View {
        VStack {
            LEDIndicatorView(sensorStatus: bleManager.pumpRelay, positLabel: "Pump")
            HStack{
                PressGaugeView(press: bleManager.leftPress, posit: "Left", pressSetting: bleManager.leftSetting, topLed: bleManager.leftFillSolenoid, bottomLed: bleManager.leftDumpSolenoid)
                PressGaugeView(press: bleManager.rightPress, posit: "Right", pressSetting: bleManager.rightSetting, topLed: bleManager.rightFillSolenoid, bottomLed: bleManager.rightDumpSolenoid)
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(BLEManager())
    }
}
