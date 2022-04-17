//
//  PortfolioWidget.swift
//  PortfolioWidget
//
//  Created by Andrew CP Markham on 26/3/22.
//

import WidgetKit
import SwiftUI

@main
struct PortfolioWidgets: WidgetBundle {
    /// Instantiates up the porfolio widgets available in the app
    var body: some Widget {
        SimplePortfolioWidget()
        ComplexPortfolioWidget()
    }
}

struct PortfolioWidget_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioWidgetEntryView(entry: SimpleEntry(date: Date(), items: [Item.example]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
