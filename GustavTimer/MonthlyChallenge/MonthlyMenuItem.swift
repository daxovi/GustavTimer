//
//  MonthlyMenuItem.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 21.12.2024.
//
import SwiftUI

struct MonthlyMenuItem: View {
    @Binding var showVideo: Bool
    @State private var monthlyTitle: String = " \n "
    
    let monthlyTitleArray: [String] = [" \n ", "413HL \n390LL", "MNTHL \nCHALLL", "M0NTH \nCHA11", "M0NTHL7 \nCHA11EN", "M04THL7 \nCHA11ENG3", "M0NTHLY \nCHA1L3NGE", "MONTHLY \nCHALLENGE"]
    
    var body: some View {
        Section {
            Button {
                showVideo = true
            } label: {
                Text("START")
                    .font(Font.custom(AppConfig.appFontName, size: 23))
                    .padding(.vertical, 10)
                    .foregroundStyle(Color("ResetColor"))
            }
                .listRowBackground(Color("StartColor"))

        } header: {
            VStack {
                Text(monthlyTitle)
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 0)
                    .font(Font.custom(AppConfig.counterFontName, size: 33))
                    .foregroundStyle(Color("StartColor"))
                    .onAppear {
                        animateMonthlyTitle(titleArray: monthlyTitleArray)
                    }
            }
            .padding(.top, 200)
        }
    }
    
    func animateMonthlyTitle(titleArray: [String]) {
        for (index, title) in titleArray.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 * Double(index)) {
                withAnimation {
                    monthlyTitle = title
                }
            }
        }
    }
}
