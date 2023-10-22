//
//  BGImageView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 22.10.2023.
//

import SwiftUI

struct BGImageView: View {
    var image: Image
    
    var body: some View {
        GeometryReader(content: { geometry in
            image
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .frame(width: geometry.size.width, height: geometry.size.height)
        })
    }
}
