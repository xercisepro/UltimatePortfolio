//
//  PortfolioWidget.swift
//  PortfolioWidget
//
//  Created by Andrew CP Markham on 26/3/22.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), items: [Item.example])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        // Called to get current status of the widget
        let entry = SimpleEntry(date: Date(), items: loadItems())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        // called to show whats coming up in the future
        let entry = SimpleEntry(date: Date(), items: loadItems())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    func loadItems() -> [Item] {
        // Data loader for widget
        let dataController = DataController()
        let itemRequest = dataController.fetchRequestForTopItems(count: 1)
        return dataController.results(for: itemRequest)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let items: [Item]
}

struct PortfolioWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text("Up next...")
            .font(.title)

        if let item = entry.items.first {
            Text(item.itemTitle)
        } else {
            Text("Nothing!")
        }
    }
}

@main
struct PortfolioWidget: Widget {
    let kind: String = "PortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PortfolioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct PortfolioWidget_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioWidgetEntryView(entry: SimpleEntry(date: Date(), items: [Item.example]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
