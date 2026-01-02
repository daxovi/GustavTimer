//
//  FavouritesItemView.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 06.09.2025.
//

import SwiftUI
import GustavUI

struct FavouriteRowView: View {
    let timer: TimerData
    let selected: Bool
        
    var isMainTimer: Bool {
        timer.order == AppConfig.defaultTimer.order
    }
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 36) {
                GeometryReader { geometry in
                    HStack(alignment: .top, spacing: 5) {
                        ForEach(timer.intervals) { interval in
                            VStack(alignment: .leading) {
                                Capsule()
                                    .fill(isMainTimer ? Color.gustavLight : Color.gustavVolt)
                                    .frame(height: 5)
                                Text(interval.name)
                                    .font(.savedRowIntervalName)
                                    .lineLimit(1)
                                    .padding(.trailing)
                                    .foregroundStyle(Color.gustavLight)
                            }
                            .frame(width: getIntervalWidth(interval: interval, viewWidth: geometry.size.width))
                        }
                    }
                }
                HStack {
                    Text(intervalName)
                        .font(.savedRowTimerName)
                        .foregroundStyle(isMainTimer ? Color.gustavLight : .primary)
                        .lineLimit(1)
                        .padding(.trailing, 4)
                    
                    if timer.rounds == -1 {
                        GustavIcon(.loop, size: 22, color: Color.gustavLight)
                    }
                    
                    if timer.selectedSound != nil {
                        GustavIcon(.sound, size: 22, color: Color.gustavLight)
                    }
                    
                    if timer.isVibrating {
                        GustavIcon(.vibration, size: 22, color: Color.gustavLight)
                    }
                    
                    Spacer()
                }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .padding()
            .background(selected ? Color.gustavVolt.opacity(0.2) : nil)
            .contentShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    var intervalName: LocalizedStringKey {
        if isMainTimer {
            return "CURRENT_TIMER"
        } else {
            return LocalizedStringKey(timer.name)
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
        Section {
            FavouriteRowView(timer: {
                let timer = TimerData(order: 2, name: "My Favourite Timer", rounds: 5, selectedSound: .beep, isVibrating: true)
                timer.intervals = [
                    IntervalData(value: 30, name: "Work"),
                    IntervalData(value: 15, name: "Rest")
                ]
                return timer
            }(), selected: true)
            FavouriteRowView(timer: {
                let timer = TimerData(order: 2, name: "My Favourite Timer", rounds: 5, selectedSound: .whistle, isVibrating: true)
                timer.intervals = [
                    IntervalData(value: 30, name: "Work"),
                    IntervalData(value: 15, name: "Rest")
                ]
                return timer
            }(), selected: false)
        }
        FavouriteRowView(timer: {
            let timer = AppConfig.defaultTimer
            timer.order = 11
            timer.intervals = [
                IntervalData(value: 30, name: "Work"),
                IntervalData(value: 15, name: "Rest")
            ]
            return timer
        }(), selected: false)
    }
}
