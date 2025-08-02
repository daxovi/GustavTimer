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
    var monthlyActionText: LocalizedStringKey
    @Binding var monthlyCounter: Int
    @Environment(\.theme) private var theme
    
    let monthlyTitleArray: [String] = [" \n ", " \nG5TV", " \n6U5TAV", " \nGUSTAV", "413HL \n695LL", "MNTHL \nCHALLL", "M0NTH \nCHA11", "M0NTHL7 \nCHA11EN", "M04THL7 \nCHA11ENG3", "M0NTHLY \nCHA1L3NGE", "MONTHLY \nCHALLENGE"]
    
    var body: some View {
        Section {
            Button {
                showVideo = true
            } label: {
                HStack {
                    Text(monthlyActionText)
                        .font(theme.fonts.body)
                        .textCase(.uppercase)
                    Spacer()
                    if monthlyCounter > 0 {
                        theme.colors.neutral
                            .frame(width: 25, height: 25)
                            .clipShape(Circle())
                            .overlay {
                                Text("\(monthlyCounter)")
                                    .font(theme.fonts.settingsCaption)
                                    .foregroundStyle(theme.colors.volt)
                            }
                    } else {
                        Image(systemName: "play.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                }
                .padding(.vertical, 10)
                .foregroundStyle(theme.colors.neutral)
            }
                .listRowBackground(theme.colors.volt)

        } header: {
            VStack {
                Text(monthlyTitle)
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 0)
                    .font(theme.fonts.settingsButtonBold)
                    .foregroundStyle(theme.colors.volt)
                    .onAppear {
                        animateMonthlyTitle(titleArray: monthlyTitleArray)
                    }
                    .padding(.leading, -5)
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
