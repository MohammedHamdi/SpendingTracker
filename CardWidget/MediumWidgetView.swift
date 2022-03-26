//
//  MediumWidgetView.swift
//  SpendingTrackerSwiftUICoreDataLBTA
//
//  Created by Mohammed Hamdi on 21/09/2021.
//

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    
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
                
                HStack {
                    VStack(alignment: .leading, spacing: 8/*12*/) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.name ?? "")
    //                        Text("Card Name")
                                .font(.system(size: 16, weight: .semibold))
                            
                            HStack {
                                Spacer()
                                Text(card.number?.modifyCreditCardString() ?? "")
                                    .font(.system(size: 12, weight: .semibold))
                                Spacer()
                            }
                        }
                        
                        
                        HStack(alignment: .bottom) {
                            Image(card.type ?? "visa")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 30)
                            
                            Spacer()
                            
                            
                            
//                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Valid Thru")
//                                Text("01/22")
                                Text("\(String(format: "%02d", card.expMonth))/\(String(card.expYear % 2000))")
                            }
                            .font(.system(size: 12, weight: .regular))
                            
                            
                        }
                        
                        ProgressBar(value: $progressValue)
                            .frame(height: 16)
                        
                        
                        HStack {
                            Text(String(format: "$%.0f", card.balance))
                                .font(.system(size: 24, weight: .semibold))
                            
                            Spacer()
                            
                            Text(String(format: "$%.0f", card.limit))
                                .font(.system(size: 22, weight: .semibold))
                        }
                        }
                        .padding()
                }
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


struct MediumWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        MediumWidgetView(card: nil)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

extension String {
    func modifyCreditCardString() -> String {
         let trimmedString = self.components(separatedBy: .whitespaces).joined()

         let arrOfCharacters = Array(trimmedString)
         var modifiedCreditCardString = ""

         if(arrOfCharacters.count > 0) {
             for i in 0...arrOfCharacters.count-1 {
                 modifiedCreditCardString.append(arrOfCharacters[i])
                 if((i+1) % 4 == 0 && i+1 != arrOfCharacters.count){
                     modifiedCreditCardString.append(" ")
                 }
             }
         }
         return modifiedCreditCardString
     }
}
