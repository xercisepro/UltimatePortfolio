//
//  SimpleWidget.swift
//  PortfolioWidgetExtension
//
//  Created by Andrew CP Markham on 9/4/22.
//

import SwiftUI
import WidgetKit

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

struct SimplePortfolioWidget: Widget {
    /// Example of a very simple widget
    let kind: String = "SimplePortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PortfolioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Up next…")
        .description("Your #1 top-priority item.")
        .supportedFamilies([.systemSmall]) // Limits the Widget size option to small
    }
}

struct SimplePortfolioWidget_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioWidgetEntryView(entry: SimpleEntry(date: Date(), items: [Item.example]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
