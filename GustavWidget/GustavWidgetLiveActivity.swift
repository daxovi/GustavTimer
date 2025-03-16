//
//  GustavWidgetLiveActivity.swift
//  GustavWidget
//
//  Created by Dalibor Janeček on 15.03.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct GustavWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct GustavWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GustavWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension GustavWidgetAttributes {
    fileprivate static var preview: GustavWidgetAttributes {
        GustavWidgetAttributes(name: "World")
    }
}

extension GustavWidgetAttributes.ContentState {
    fileprivate static var smiley: GustavWidgetAttributes.ContentState {
        GustavWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: GustavWidgetAttributes.ContentState {
         GustavWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: GustavWidgetAttributes.preview) {
   GustavWidgetLiveActivity()
} contentStates: {
    GustavWidgetAttributes.ContentState.smiley
    GustavWidgetAttributes.ContentState.starEyes
}
