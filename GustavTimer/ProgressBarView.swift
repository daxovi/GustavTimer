//
//  ProgressBarView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 11.09.2023.
//

import SwiftUI

struct ProgressBarView: View {
    @Binding var progress: Double
    @Binding var duration: Double
    
    var cornerRadius: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Color("ResetColor")
                //    .opacity(0.5)
                    .cornerRadius(cornerRadius)
                Color("StartColor")
                    .frame(width: proxy.size.width * progress)
                    .cornerRadius(cornerRadius)
                    .animation(.linear(duration: duration), value: progress)
            }
        }
    }
}
