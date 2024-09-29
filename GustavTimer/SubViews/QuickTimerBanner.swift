//
//  BannerView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 22.09.2024.
//

import SwiftUI

struct QuickTimerBanner: View {
    var action: () -> Void
    var titleLabel: LocalizedStringKey
    var buttonLabel: LocalizedStringKey
    var image: Image

    var body: some View {
        image
            .resizable()
            .aspectRatio(1.8, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay {
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text(titleLabel)
                            .textCase(.uppercase)
                            .font(Font.custom(AppConfig.counterFontName, size: 23))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        Spacer()
                        Spacer()
                        HStack(spacing: 0) {
                            Text("SET_TIMER: ")
                            Text(buttonLabel)
                        }
                        .foregroundStyle(Color.black)
                        
                            .padding()
                            .background{
                                Color("StartColor")
                                    .cornerRadius(10)
                            }
                            .shadow(radius: 15)
                            .padding(.bottom, 25)
                    }
                    .padding(20)
                    Spacer()
                }
            }
            .onTapGesture {
                action()
            }
            .buttonStyle(PlainButtonStyle())
    }
}
