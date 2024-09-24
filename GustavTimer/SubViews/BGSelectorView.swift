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
    private let flexibleColumn = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    @StateObject var viewModel = GustavViewModel.shared
    @Environment(\.modelContext) var context
    @Query var customImage: [CustomImageModel]
    
    @State var selectedPhoto: PhotosPickerItem?
    @State var selectedPhotoData: Data?
    
    var body: some View {
        ScrollView() {
            LazyVGrid(columns: flexibleColumn, spacing: 15) {
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
                            GeometryReader { geometry in
                                            Image(uiImage: uiImage)
                                    .backgroundThumbnail()
                                                .aspectRatio(contentMode: .fill) // Vyplní celý čtverec
                                                .frame(width: geometry.size.width, height: geometry.size.width) // Zajistí čtvercovou velikost
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .onTapGesture { viewModel.setBG(index: -1) }
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(style: .init(lineWidth: (viewModel.bgIndex == -1) ? 4 : 0))
                                                        .fill(Color("StartColor"))
                                                        .animation(.easeInOut, value: viewModel.bgIndex)
                                                }
                                        }
                                        .aspectRatio(1, contentMode: .fit) // Zachová poměr 1:1, takže bude čtverec
                        }
                    }
                    
                }
                PhotosPicker(selection: $selectedPhoto) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("ResetColor"))
                        .aspectRatio(1, contentMode: .fill)
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
