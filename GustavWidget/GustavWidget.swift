//
//  GustavWidget.swift
//  GustavWidget
//
//  Created by Dalibor Janeček on 15.03.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimerActivityView : View {
    let context: ActivityViewContext<TimerAtributes>
        
    var body: some View {
        VStack {
            Text(context.state.timerName)
                .foregroundColor(Color("StartColor"))
                .font(.custom("MartianMono-Bold", size: 26))
        }
        .padding(.horizontal)
    }
}

struct GustavWidget: Widget {
    let kind: String = "GustavWidget"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerAtributes.self) { context in
            TimerActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text("\(context.state.timerName)")
                            .font(.custom("MartianMono-Bold", size: 26))
                        
                        Spacer()
                    }
                }
            } compactLeading: {
                Text("\(context.state.timerName.first ?? " ")")
                    .foregroundColor(Color("StartColor"))
                    .font(.custom("MartianMono-Bold", size: 16))

            } compactTrailing: {
//                Text("\(context.state.endTime.timeIntervalSince(.now))")
//                    .foregroundColor(Color("StartColor"))
//                    .font(.custom("MartianMono-Bold", size: 16))
                Text("Gustav timer")
                    .foregroundColor(Color("StartColor"))
                    .font(.custom("MartianMono-Bold", size: 8))
            } minimal: {
                Text("\(context.state.timerName.first ?? " ")")
                    .font(.custom("MartianMono-Bold", size: 16))
                    .foregroundColor(Color("StartColor"))
            }
        }
    }
}

extension TimerAtributes {
    fileprivate static var preview: TimerAtributes {
        TimerAtributes(appName: "Gustav Timer App")
    }
}

extension TimerAtributes.ContentState {
    fileprivate static var rest: TimerAtributes.ContentState {
        TimerAtributes.ContentState(timerName: "Rest")
     }
     
     fileprivate static var workout: TimerAtributes.ContentState {
         TimerAtributes.ContentState(timerName: "Workout")
     }
}

#Preview("Notification", as: .content, using: TimerAtributes.preview) {
    GustavWidget()
} contentStates: {
    TimerAtributes.ContentState.rest
    TimerAtributes.ContentState.workout
}
