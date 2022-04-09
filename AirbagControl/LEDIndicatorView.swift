//
//  LEDIndicatorView.swift
//  AirbagControl
//
//  Created by James Ford on 3/30/22.
//

import SwiftUI

struct LEDIndicatorView: View {
    //sensor status 0: not connected, 1: normal operation, 2: timed out for unknown reason, 3: sleeping (commanded or inactivity)
    var sensorStatus: Int
    var sensorColor: [Color] = [.red, .green]
    var positLabel: String
    
    var body: some View {
        GeometryReader { geometry in
            let width = min(100, geometry.size.height) 
            //let height = width

            
            HStack {
                Circle()
                    .fill(sensorColor[sensorStatus])
                    .frame(width: width, height: width, alignment: .center)
                Text(positLabel)
                    
            } 
            .frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
        .padding(.leading, 7.0)
        .frame(width: 140.0, height: 30.0, alignment: .center)
    
    }
}

struct LEDIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        LEDIndicatorView(sensorStatus: 1, positLabel: "Yeet")
    }
}
