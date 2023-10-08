//
//  DotView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 08.10.2023.
//

import SwiftUI

struct DotView: View {
    @ObservedObject var viewModel = GustavViewModel.shared
    
    var columns: [GridItem] {
        switch viewModel.count {
        case 0..<2:
            return  [
                GridItem(.flexible())
            ]
        case 2..<13:
            return  [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        case 13..<18:
            return  [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        case 18..<25:
            return  [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        default:
            return  [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        }
    }
    
    var body: some View {
        Color.gray
            .cornerRadius(15)
            .overlay {
                VStack {
                    LazyVGrid(columns: columns, alignment: .leading, content: {
                        ForEach((0..<viewModel.count), id: \.self) { value in
                            Circle().fill(.green)
                        }
                    })
                    Spacer()
                }
                .padding(5)
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/2*3)
    }
}
