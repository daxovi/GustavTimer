//
//  BackgroundThumbnail.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 11.09.2024.
//

import SwiftUI

extension Image {
    func backgroundThumbnail() -> some View {
        self
            .resizable()
            .scaledToFill()
            .grayscale(1.0)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
