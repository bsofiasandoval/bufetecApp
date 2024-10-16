//
//  BufeTecAppWidget.swift
//  BufeTecAppWidget
//
//  Created by Sofia Sandoval on 10/16/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct BufeTecAppWidgetEntryView : View {
    var entry: Provider.Entry
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false // Storing login state

    var body: some View {
        VStack {
            if isLoggedIn {
                // If the user is logged in, show the speech bot link
                Link(destination: URL(string: "myapp://showSpeechBot")!) {
                    VStack {
                        Text("Access BufeBot")
                        Image(systemName: "mic.circle.fill")
                            .font(.largeTitle)
                    }
                }
            } else {
                // If the user is not logged in, show the login redirect link
                Link(destination: URL(string: "myapp://login")!) {
                    VStack {
                        Text("Login to access BufeBot")
                        Image(systemName: "lock.circle.fill")
                            .font(.largeTitle)
                    }
                }
            }
        }
    }
}

struct BufeTecAppWidget: Widget {
    let kind: String = "BufeTecAppWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            BufeTecAppWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    BufeTecAppWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}

