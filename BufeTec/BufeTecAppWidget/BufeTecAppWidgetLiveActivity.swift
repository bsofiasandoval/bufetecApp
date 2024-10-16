//
//  BufeTecAppWidgetLiveActivity.swift
//  BufeTecAppWidget
//
//  Created by Sofia Sandoval on 10/16/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BufeTecAppWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BufeTecAppWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BufeTecAppWidgetAttributes.self) { context in
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

extension BufeTecAppWidgetAttributes {
    fileprivate static var preview: BufeTecAppWidgetAttributes {
        BufeTecAppWidgetAttributes(name: "World")
    }
}

extension BufeTecAppWidgetAttributes.ContentState {
    fileprivate static var smiley: BufeTecAppWidgetAttributes.ContentState {
        BufeTecAppWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BufeTecAppWidgetAttributes.ContentState {
         BufeTecAppWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BufeTecAppWidgetAttributes.preview) {
   BufeTecAppWidgetLiveActivity()
} contentStates: {
    BufeTecAppWidgetAttributes.ContentState.smiley
    BufeTecAppWidgetAttributes.ContentState.starEyes
}
