//
//  PressGaugeView.swift
//  AirbagControl
//
//  Created by James Ford on 3/19/22.
//

import SwiftUI
import TTGaugeView

struct PressGaugeView: View {
    @EnvironmentObject var bleManager: BLEManager
    let gaugeSettings = TTGaugeViewSettings(faceColor: Color.white, needleColor: Color.orange)
    let sections: [TTGaugeViewSection] = [TTGaugeViewSection(color: Color.red, size: 0.05),
                                          TTGaugeViewSection(color: Color.green, size: 0.95)]
    var press: Int
    var posit: String
    var pressSetting: Int
    var topLed: Int
    var bottomLed: Int
    
    var body: some View {
        VStack {
            Spacer()
            Button("INCREASE") {
                bleManager.increasePress(posit: posit)
            }
            LEDIndicatorView(sensorStatus: topLed, positLabel: posit + " Fill")
            TTGaugeView(angle: 260, sections: sections, settings: gaugeSettings, value: Double(press)/100, valueDescription: String(press) + " psi", gaugeDescription: posit)
            Text("Setting: " + String(pressSetting) + " psi")
            LEDIndicatorView(sensorStatus: bottomLed, positLabel: posit + " Dump")
            Button("DECREASE") {
                bleManager.decreasePress(posit: posit)
            }
            Spacer()
        }
    }
}

struct PressGaugeView_Previews: PreviewProvider {
    static var previews: some View {
        PressGaugeView(press: 46, posit: "Left", pressSetting: 50, topLed: 1, bottomLed: 0)
    }
}
