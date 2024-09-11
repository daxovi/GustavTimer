//
//  BGView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 08.09.2024.
//

import SwiftUI
import PhotosUI
import SwiftData

struct BGSelectorView: View {
    
    @StateObject var viewModel: GustavViewModel
    @Environment(\.modelContext) var context
    @Query var customImage: [CustomImageModel]
    
    @State var selectedPhoto: PhotosPickerItem?
    @State var selectedPhotoData: Data?
    
    private let flexibleColumn = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView() {
            LazyVGrid(columns: flexibleColumn, spacing: 10) {
                ForEach(0..<viewModel.bgImages.count, id: \.self) { index in
                    viewModel.bgImages[index].getImage()
                        .backgroundThumbnail()
                        .onTapGesture { viewModel.setBG(index: index) }
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(style: .init(lineWidth: (viewModel.bgIndex == index) ? 4 : 0))
                                .fill(Color("StartColor"))
                                .animation(.easeInOut, value: viewModel.bgIndex)
                        }
                        .padding(1)
                }
                if !customImage.isEmpty {
                    ForEach(customImage, id: \.id) { imageData in
                        if let uiImage = UIImage(data: imageData.image) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color((viewModel.bgIndex == -1) ? "StartColor" : "ResetColor"))
                        //        .frame(width: .infinity, height: UIScreen.main.bounds.width / 2 * 1.635)
                                .overlay(alignment: .center) {
                                    Image(uiImage: uiImage)
                                        .backgroundThumbnail()
                                        .scaledToFit()
                                        .grayscale(1.0)
                                        .onTapGesture { viewModel.setBG(index: -1) }
                                        .padding(4)
                                }
                        }
                    }
                    
                }
                PhotosPicker(selection: $selectedPhoto) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("ResetColor"))
                       .frame(width: .infinity, height: UIScreen.main.bounds.width / 2 * 1.635)
                   //     .frame(minHeight: 100)
                        .overlay(alignment: .center) {
                            Image(systemName: "photo")
                                .foregroundStyle(Color("StartColor"))
                                .font(.title)
                                .padding()
                        }
                }
            }
            .padding()
            .task(id: selectedPhoto) {
                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                    for image in customImage {
                                context.delete(image)
                            }
                    selectedPhotoData = data
                    let customPhoto = CustomImageModel(image: data)
                    context.insert(customPhoto)
                    viewModel.setBG(index: -1)
                }
            }
        }
    }
}
