//
//  ProgressBarView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 11.09.2023.
//

import SwiftUI

struct ProgressBarView: View {
    @Binding var progress: Double
    var cornerRadius: CGFloat = 10
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Color.blue
                    .cornerRadius(cornerRadius)
                Color.red
                    .frame(width: proxy.size.width * progress)
                    .cornerRadius(cornerRadius)
                    .animation(.linear(duration: 1.0), value: progress)
            }
        }
    }
}