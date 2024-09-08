//
//  BGView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 08.09.2024.
//

import SwiftUI
import PhotosUI
import SwiftData

struct BGView: View {
    
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
                        if customImage.isEmpty {
                            PhotosPicker(selection: $selectedPhoto) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color((viewModel.bgIndex == -1) ? "StartColor" : "ResetColor"))
                                    .frame(width: .infinity, height: UIScreen.main.bounds.width / 2 * 1.635)
                                    .overlay(alignment: .center) {
                                        Image(systemName: "photo")
                                            .foregroundStyle(Color((viewModel.bgIndex == -1) ? "ResetColor" : "StartColor"))
                                            .font(.title)
                                            .padding()
                                    }
                            }
                            .task(id: selectedPhoto) {
                                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                                    try? context.delete(model: CustomImageModel.self)
                                    selectedPhotoData = data
                                    let customPhoto = CustomImageModel(image: data)
                                    context.insert(customPhoto)
                                    viewModel.setBG(index: -1)
                                }
                            }
                        } else {
                            ForEach(customImage, id: \.id) { imageData in
                                if let uiImage = UIImage(data: imageData.image) {
                                    HStack(spacing: 0) {
                                        Image(uiImage: uiImage)
                                            .backgroundThumbnail()
                                            .onTapGesture { viewModel.setBG(index: -1) }
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(style: .init(lineWidth: (viewModel.bgIndex == -1) ? 4 : 0))
                                                    .fill(Color("StartColor"))
                                                    .animation(.easeInOut, value: viewModel.bgIndex)
                                            }
                                            .padding(1)
                                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                            Image(systemName: "photo")
                                                .foregroundStyle(Color((viewModel.bgIndex == -1) ? "ResetColor" : "StartColor"))
                                                .font(.title)
                                                .padding()
                                                .animation(.easeInOut, value: viewModel.bgIndex)
                                        }
                                    }
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color((viewModel.bgIndex == -1) ? "StartColor" : "ResetColor"))
                                            .animation(.easeInOut, value: viewModel.bgIndex)
                                    }
                                }
                            }
                            .task(id: selectedPhoto) {
                                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                                    try? context.delete(model: CustomImageModel.self)
                                    selectedPhotoData = data
                                    let customPhoto = CustomImageModel(image: data)
                                    context.insert(customPhoto)
                                    viewModel.setBG(index: -1)
                                }
                            }
                        }
                    }
                }
                .padding()
        }
    }
