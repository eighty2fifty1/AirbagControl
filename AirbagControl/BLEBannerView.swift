//
//  BLEBannerView.swift
//  AirbagControl
//
//  Created by James Ford on 4/3/22.
//

import SwiftUI

struct BLEBannerView: View {
    let statusMsg: [String] = ["Unknown",
                               "Connected",
                               "Disconnected",
                               "Scanning",
                               "Connecting"]
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct BLEBannerView_Previews: PreviewProvider {
    static var previews: some View {
        BLEBannerView()
    }
}
