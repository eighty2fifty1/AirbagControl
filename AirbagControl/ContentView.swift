//
//  ContentView.swift
//  AirbagControl
//
//  Created by James Ford on 3/19/22.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @EnvironmentObject var bleManager: BLEManager
    @State private var manualMode: Bool = false
    @State private var pumpOn: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                LEDIndicatorView(sensorStatus: bleManager.pumpRelay, positLabel: "Pump")
                Toggle(isOn: $manualMode, label: {
                    Text("Manual Mode")
                }
            )
                .onChange(of: manualMode, perform: { value in
                    var msg: String
                    if manualMode {
                        msg = "1"
                    }
                    
                    else {
                        msg = "0"
                    }
                    bleManager.sendStatusMsg(msg: msg)
                })
            }
            if bleManager.mode == 1 {
                Toggle(isOn: $pumpOn, label: {
                    Text("Air Pump")
                })
                .onChange(of: pumpOn, perform: { value in
                    if pumpOn {
                        bleManager.pumpPower(msg: "1")
                    }
                    else {
                        bleManager.pumpPower(msg: "0")
                    }
                })
            }
            
                HStack{
                    PressGaugeView(press: bleManager.leftPress, posit: "Left", pressSetting: bleManager.leftSetting, topLed: bleManager.leftFillSolenoid, bottomLed: bleManager.leftDumpSolenoid)
                    PressGaugeView(press: bleManager.rightPress, posit: "Right", pressSetting: bleManager.rightSetting, topLed: bleManager.rightFillSolenoid, bottomLed: bleManager.rightDumpSolenoid)
                    
                }
            }
            if bleManager.isConnected {
            Text(String("Bluetooth Connected"))
                .background(Color.green)
            }
        }
    }
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(BLEManager())
        
        ContentView()
            .environmentObject(BLEManager())
            .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
    }
}
