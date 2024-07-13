//
//  HideKeyboardExtension.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 13.07.2024.
//

import Foundation
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
