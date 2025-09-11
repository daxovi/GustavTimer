//
//  FavouritesItemView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 06.09.2025.
//

import SwiftUI

struct FavouritesItemView: View {
    let timer: TimerData
    @Binding var isSelected: Bool
    let onDelete: (() -> Void)
    let onSelect: (() -> Void)
    
    @Environment(\.theme) var theme
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 36) {
                GeometryReader { geometry in
                    HStack(alignment: .top, spacing: 5) {
                        ForEach(timer.intervals) { interval in
                            VStack(alignment: .leading) {
                                Capsule()
                                    .fill(theme.colors.volt)
                                    .frame(height: 5)
                                Text(interval.name)
                                    .font(theme.fonts.settingsCaption)
                                    .lineLimit(1)
                                    .padding(.trailing)
                                    .foregroundStyle(theme.colors.light)
                            }
                            .frame(width: getIntervalWidth(interval: interval, viewWidth: geometry.size.width))
                        }
                    }
                }
                HStack {
                    Text(timer.name)
                        .font(theme.fonts.settingsLabelLarge)
                        .lineLimit(1)
                        .padding(.trailing, 4)
                    
                    if timer.rounds == -1 {
                        theme.icons.loop
                            .frame(width: 22, height: 22)
                            .foregroundStyle(theme.colors.light)
                    }
                    
                    if timer.selectedSound != nil {
                        Image(systemName: "speaker.wave.2.fill")
                            .frame(width: 22, height: 22)
                            .foregroundStyle(theme.colors.light)
                    }
                    
                    if timer.isVibrating {
                        theme.icons.vibration
                            .frame(width: 22, height: 22)
                            .foregroundStyle(theme.colors.light)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "bin.xmark")
                        .foregroundStyle(.red)
                        .onTapGesture {
                            onDelete()
                        }
                }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .padding()
            .overlay(alignment: .leading, content: {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 10)
                        .stroke(theme.colors.volt, lineWidth: 5)
                    }
            })
            .animation(.easeInOut, value: isSelected)
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture {
                onSelect()
            }
        }
    }
    
    func getIntervalWidth(interval: IntervalData, viewWidth: CGFloat) -> CGFloat {
        let totalDuration = timer.intervals.reduce(0) { $0 + $1.value }
        let spacing = CGFloat(timer.intervals.count - 1) * 5
        return viewWidth * (CGFloat(interval.value) / CGFloat(totalDuration)) - (spacing / CGFloat(timer.intervals.count))
    }
}

#Preview {
    List {
        FavouritesItemView(timer: {
            let timer = AppConfig.defaultTimer
            timer.intervals = [
                IntervalData(value: 30, name: "Work"),
                IntervalData(value: 15, name: "Rest")
            ]
            return timer
        }(), isSelected: .constant(true), onDelete: {}, onSelect: {})
    }
}
