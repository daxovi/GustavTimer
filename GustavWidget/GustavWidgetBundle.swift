//
//  GustavWidgetBundle.swift
//  GustavWidget
//
//  Created by Dalibor Janeček on 15.03.2025.
//

import WidgetKit
import SwiftUI

@main
struct GustavWidgetBundle: WidgetBundle {
    var body: some Widget {
        GustavWidget()
        GustavWidgetControl()
        GustavWidgetLiveActivity()
    }
}
