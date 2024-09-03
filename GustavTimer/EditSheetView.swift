//
//  EditSheetView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 01.10.2023.
//

import SwiftUI
import PhotosUI
import SwiftData

struct EditSheetView: View {
    @StateObject var viewModel: GustavViewModel
    @Environment(\.modelContext) var context
    @Query var customImage: [CustomImageModel]
    
    @State var selectedPhoto: PhotosPickerItem?
    @State var selectedPhotoData: Data?
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationStack {
                List {
                    Section("LAPS", content: {
                        Laps(viewModel: viewModel)
                        if !viewModel.isTimerFull {
                            Button(action: viewModel.addTimer, label: {
                                Text("ADD_LAP")
                                    .foregroundStyle(Color("ResetColor"))
                            })
                        }
                    })
                    
                    Section("TIMER_SETTINGS") {
                        Toggle("LOOP", isOn: $viewModel.isLooping)
                            .tint(Color("StartColor"))
                        Toggle("SOUND", isOn: $viewModel.isSoundOn)
                            .tint(Color("StartColor"))
                        if viewModel.isSoundOn {
                            soundThemes
                        }
                    }
                    
                    Section("BACKGROUND") {
                        bgSelector
                    }
                    
                    Section("ABOUT") {
                        rateButton
                    }
                }
                .navigationTitle("EDIT_TITLE")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarButtons }

                
                /*
                List {
                    HStack {
                        Text("LAPS")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    Laps(viewModel: viewModel)
                    if !viewModel.isTimerFull {
                        Button(action: viewModel.addTimer, label: {
                            Text("ADD_LAP")
                                .onTapGesture {
                                    viewModel.addTimer()
                                }
                                .foregroundStyle(Color("ResetColor"))
                        })
                    }
                    
                    recentTimers
                    settingsToggle.padding(.top, 8)
                    bgSelector.padding(.top, 8)
                    rateButton
                }
                .navigationBarTitleDisplayMode(.inline)
                .listStyle(.plain)
                .toolbar { toolbarButtons }
                .environment(\.editMode, $viewModel.editMode)
                */
            }
            .accentColor(Color("StopColor"))
            .font(.none)
        }
    }
    
    var rateButton: some View {
        Button("RATE") {
            let url = "https://apps.apple.com/app/id6478176431?action=write-review"
            guard let writeReviewURL = URL(string: url)
            else { fatalError("Expected a valid URL") }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
    
    var recentTimers: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.recentTimers, id: \.self) { array in
                    Text(array.map { String($0) }.joined(separator: ":"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(content: {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray.opacity(0.2))
                        })
                        .fixedSize(horizontal: true, vertical: false)
                        .onTapGesture {
                            viewModel.timers = array
                        }
                }
            }
        }
    }
    // MARK: soundThemes
    var soundThemes: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.soundThemeArray, id: \.self) { theme in
                    Text(theme.uppercased())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(content: {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(viewModel.activeSoundTheme == theme ? Color("StartColor") : Color.gray.opacity(0.2))
                        })
                        .fixedSize(horizontal: true, vertical: false)
                        .onTapGesture {
                            viewModel.activeSoundTheme = theme
                            SoundManager.instance.playSound(sound: .final, theme: theme)
                        }
                }
            }
        }
    }
    
    var toolbarButtons: some View {
            Button(action: viewModel.saveSettings) {
                Text("SAVE")
            }
        .foregroundStyle(Color("StopColor"))
    }

    // MARK: bgSelector
    var bgSelector: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("BACKGROUND")
                .fontWeight(.bold)
            ScrollView(.horizontal) {
                HStack {
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
                                .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3 * 1.635)
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
        }
    }
}

extension Image {
    func backgroundThumbnail() -> some View {
        self
            .resizable()
            .scaledToFill()
            .grayscale(1.0)
            .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3 * 1.635)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
