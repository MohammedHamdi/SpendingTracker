//
//  SmallWidgetView.swift
//  SpendingTrackerSwiftUICoreDataLBTA
//
//  Created by Mohammed Hamdi on 22/09/2021.
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    
    let card: Card?
    
    @State private var progressValue: Float = 0.0
    
    var body: some View {
        
        if let card = card {
            ZStack {
                VStack {
                    if let colorData = card.color,
                       let uiColor = UIColor.color(data: colorData),
                       let actualColor = Color(uiColor) {
                        
                        LinearGradient(gradient: Gradient(colors: [actualColor.opacity(0.6), actualColor]), startPoint: .top, endPoint: .bottom)
                    } else {
                        LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.6), Color.red]), startPoint: .top, endPoint: .bottom)
                    }
                }
                
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(card.name ?? "")
//                    Text("Card Name")
                        .font(.system(size: 14, weight: .semibold))
                    
                    HStack(alignment: .bottom) {
                        Image(card.type ?? "visa")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                        
                        Spacer()
                        /*
                        VStack(alignment: .trailing) {
                            Text("Valid Thru")
//                            Text("\(String(format: "%02d", card.expMonth))/\(String(card.expYear % 2000))")
                            Text("01/22")
                        }*/
                        Text(String(format: "$%.0f", card.limit))
                            .font(.system(size: 16, weight: .regular))
                    }
                    
                    ProgressBar(value: $progressValue)
                        .frame(height: 16)

//                    Text(String(format: "$%.2f", card.limit))
                    Text(String(format: "$%.0f", card.balance))
                        .font(.system(size: 24, weight: .semibold))
                }
                .padding()
            }
            .foregroundColor(Color.white)
            .onAppear {
                progressValue = card.balance / card.limit
            }
          
        } else {
            Text("Please add a card")
        }
        
    }
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidgetView(card: nil)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}


struct ProgressBar: View {
    @Binding var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemGreen))
                    .animation(.linear)
            }.cornerRadius(8.0)
        }
    }
}
