//
//  FavouritesItemView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 06.09.2025.
//

import SwiftUI

struct FavouriteRowView: View {
    let timer: TimerData
    
    @Environment(\.theme) var theme
    
    var isMainTimer: Bool {
        timer.id == AppConfig.defaultTimer.id
    }
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 36) {
                GeometryReader { geometry in
                    HStack(alignment: .top, spacing: 5) {
                        ForEach(timer.intervals) { interval in
                            VStack(alignment: .leading) {
                                Capsule()
                                    .fill(isMainTimer ? theme.colors.light : theme.colors.volt)
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
                    Text(getTimerName())
                        .font(theme.fonts.settingsLabelLarge)
                        .foregroundStyle(isMainTimer ? theme.colors.light : .black)
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
                }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .padding()
            .contentShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    func getTimerName() -> LocalizedStringKey {
        if isMainTimer {
            "CURRENT_TIMER"
        } else {
            LocalizedStringKey(timer.name)
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
        FavouriteRowView(timer: {
            let timer = AppConfig.defaultTimer
            timer.intervals = [
                IntervalData(value: 30, name: "Work"),
                IntervalData(value: 15, name: "Rest")
            ]
            return timer
        }())
    }
}
