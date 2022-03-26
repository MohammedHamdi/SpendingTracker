//
//  LargeWidgetView.swift
//  SpendingTrackerSwiftUICoreDataLBTA
//
//  Created by Mohammed Hamdi on 21/09/2021.
//

import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    
    let cards: FetchedResults<Card>?
    
    var body: some View {
        
        VStack(spacing: 0) {
            MediumWidgetView(card: cards?.first)
            
            if let cards = self.cards, cards.count >= 2 {
                MediumWidgetView(card: cards[1])
                    .frame(minHeight: 0, maxHeight: .infinity)
            } else {
                MediumWidgetView(card: nil)
                    .frame(minHeight: 0, maxHeight: .infinity)
            }
        }
        .frame(minHeight: 0, maxHeight: .infinity)
    }
}

struct LargeWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        LargeWidgetView(cards: nil)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
