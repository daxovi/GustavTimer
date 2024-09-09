//
//  CustomImageModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 30.03.2024.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class CustomImageModel {
    var image: Data
    
    init(image: Data) {
        self.image = image
    }
}
