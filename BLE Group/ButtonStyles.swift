//
//  ButtonStyles.swift
//  CoolBrakes
//
//  Created by James Ford on 11/1/21.
//

import Foundation
import SwiftUI

struct StandardButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(isEnabled ? Color.blue : Color.clear)
            .foregroundColor(isEnabled ? Color.white : Color.red)
            .clipShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .frame(width: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            //.animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SelectorButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
