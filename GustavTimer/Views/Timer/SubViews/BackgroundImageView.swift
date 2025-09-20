//
//  BGImageView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 22.10.2023.
//

import SwiftUI
import SwiftData

struct BackgroundImageView: View {
    @AppStorage("bgIndex") var bgIndex: Int = 0
    @Query var customImage: [CustomImageModel]
    
    var body: some View {
        Color.white
            .overlay(alignment: .bottom) {
                getImage()
                    .resizable()
                    .scaledToFill()
                    .clipped()
            }
    }
    
    func getImage() -> Image {
        if AppConfig.backgroundImages.indices.contains(bgIndex) {
            return AppConfig.backgroundImages[bgIndex].getImage()
        } else {
            if let lastImageData = customImage.last?.image, let uiImage = UIImage(data: lastImageData) {
                return Image(uiImage: uiImage)
            }
            return AppConfig.backgroundImages[0].getImage()
        }
    }
}
