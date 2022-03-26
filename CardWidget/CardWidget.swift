//
//  CardWidget.swift
//  CardWidget
//
//  Created by Mohammed Hamdi on 21/09/2021.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        
        return SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
//    let card: Card?
}

struct CardWidgetEntryView : View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    var cards: FetchedResults<Card>
    
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack {
//        Text("coubt: \(cards.count)")
        
        switch family {
        case .systemSmall:
            SmallWidgetView(card: cards.first)
        case .systemMedium:
            MediumWidgetView(card: cards.first)
        case .systemLarge:
            LargeWidgetView(cards: cards)
        default:
            Text("Widget")
        }
        }
//        .environment(\.managedObjectContext, viewContext)
        
    }
}

@main
struct CardWidget: Widget {
    let persistenceController = PersistenceController.shared
    
    let kind: String = "CardWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CardWidgetEntryView(entry: entry)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct CardWidget_Previews: PreviewProvider {
    static var previews: some View {
//        let fetchRequest: FetchRequest<Card> = FetchRequest<Card>(entity: Card.entity(), sortDescriptors: [.init(key: "timestamp", ascending: false)])
//
//        let card = fetchRequest.wrappedValue.first
        
        CardWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
