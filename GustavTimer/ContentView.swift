//
//  ContentView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import SwiftUI
import StoreKit
import SwiftData

struct ContentView: View {
    @StateObject var viewModel = GustavViewModel.shared
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Query var customImage: [CustomImageModel]
    
    @State var landingPage: Bool = false
    
    var body: some View {
        ZStack {
            background
            
            VStack {
                ProgressArrayView()
                    .padding(.top)
                HStack {
                    rounds
                    Spacer()
                    editButton
                }
                Spacer()
                
                counter
                
                Spacer()
                
                ControlButtonsView()
            }
            .font(Font.custom("MartianMono-Regular", size: 15))
            .ignoresSafeArea(edges: .bottom)
            .statusBar(hidden: true)
            .persistentSystemOverlays(.hidden)
            
            if landingPage {
                Color.red
                    .overlay(content: {
                        Text("Landing page")
                    })
                    .padding(100)
                    .onTapGesture {
                        landingPage.toggle()
                    }
            }
            
        }
        .onAppear {
            viewModel.showWhatsNew()
        }
        .sheet(isPresented: $viewModel.showingWhatsNew) {
            WhatsNewView(buttonLabel: "enter challenge", tags: ["#whatsnew", "V1.4"], action: {
                viewModel.showingWhatsNew = false
                viewModel.showingSheet.toggle()
            })
            
        }
        // depplink
        .onOpenURL { URL in
            viewModel.handleDeepLink(url: URL)
        }
    }
    
    enum DeviceType {
        case smalliPhone
        case largeiPhone
    }

    func deviceType() -> DeviceType {
        let screenWidth = UIScreen.main.bounds.width
        
        if screenWidth <= 385 {
            // iPhone SE, SE2, iPhone 8
            return .smalliPhone
        } else {
            // iPhone X, 11, 12, a další větší modely
            return .largeiPhone
        }
    }
    
    var background: some View {
        if viewModel.bgIndex == -1 {
            if let lastImageData = customImage.last?.image, let uiImage = UIImage(data: lastImageData) {
                BGImageView(image: Image(uiImage: uiImage))
            } else {
                BGImageView(image: viewModel.getImage())
            }
        } else {
            BGImageView(image: viewModel.getImage())
        }
    }
    
    var rounds: some View {
        Text( "\(viewModel.timers[viewModel.activeTimerIndex].name) (\(viewModel.round))")
            .safeAreaPadding(.horizontal)
            .foregroundColor(Color("StartColor").opacity((viewModel.round == 0) ? 0.0 : 1.0))
            .animation(.easeInOut(duration: 0.2), value: viewModel.round)
    }
    
    var counter: some View {
        Text("\(viewModel.count)")
            .font(Font.custom(AppConfig.counterFontName, size: 800))
            .minimumScaleFactor(0.01)
            .foregroundColor(Color("StartColor"))
    }
    
    var editButton: some View {
            Button {
                viewModel.toggleSheet()
            } label: {
                HStack {
                    HStack{
                            Image(systemName: "infinity.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(viewModel.isLooping ? .start : .reset))
                        Image(systemName: viewModel.isSoundOn ? "speaker.wave.2.circle.fill" : "speaker.slash.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color(viewModel.isSoundOn ? .start : .reset))
                    }
                    .frame(height: 20)

                    Text("EDIT")
                }
                .foregroundColor(Color("StartColor"))

        }
        .safeAreaPadding(.horizontal)
        .sheet(isPresented: $viewModel.showingSheet, content: {
            EditSheetView()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
