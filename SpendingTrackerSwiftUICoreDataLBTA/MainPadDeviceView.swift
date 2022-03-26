//
//  MainPadDeviceView.swift
//  SpendingTrackerSwiftUICoreDataLBTA
//
//  Created by Mohammed Hamdi on 19/09/2021.
//

import SwiftUI

struct MainPadDeviceView: View {
    
    @State private var shouldShowAddCardForm = false
    
    @State private var selectedCard: Card?
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>
    
    var body: some View {
        NavigationView {
            ScrollView {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .frame(width: 350)
                                .onTapGesture {
                                    withAnimation {
                                        self.selectedCard = card
                                    }
                                }
                                .scaleEffect(self.selectedCard == card ? 1.1 : 1)
                        }
                    }
                    .frame(height: 280)
                    .padding(.horizontal)
                    .onAppear(perform: {
                        self.selectedCard = cards.first
                    })
                }
                
                
                if let card = self.selectedCard {
                    TransactionsGrid(card: card)
                }
            }
            .navigationTitle("Money Tracker")
            .navigationBarItems(trailing: addCardButton)
            .sheet(isPresented: $shouldShowAddCardForm, content: {
                AddCardForm(card: nil, didAddCard: nil)
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var addCardButton: some View {
        Button(action: {
            shouldShowAddCardForm.toggle()
        }, label: {
            Text("+ Card")
        })
            .foregroundColor(Color(.systemBackground))
            .padding(EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 10))
            .background(Color(.label))
            .cornerRadius(5)
            .font(.headline)
    }
}

struct TransactionsGrid: View {
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        
        fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [.init(key: "timestamp", ascending: false)], predicate: .init(format: "card == %@", self.card))
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var fetchRequest: FetchRequest<CardTransaction>
    
    @State private var shouldShowAddTransactionForm = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Transactions")
                
                Spacer()
                
                Button(action: {
                    shouldShowAddTransactionForm.toggle()
                }, label: {
                    Text("+ Transaction")
                })
                .defaultButtonStyle()
            }
            .sheet(isPresented: $shouldShowAddTransactionForm, content: {
                AddTranscationForm(card: card)
            })
            
            let columns: [GridItem] = [
                .init(.fixed(120), spacing: 16, alignment: .leading),
                .init(.fixed(200), spacing: 16),
                .init(.adaptive(minimum: 300, maximum: 800), spacing: 16, alignment: .leading),
                .init(.flexible(minimum: 100, maximum: 450), spacing: 16, alignment: .trailing)
            ]
            
            LazyVGrid(columns: columns, content: {
                HStack {
                    Text("Date")
                    Image(systemName: "arrow.up.arrow.down")
                }
                
                Text("Photo / Receipt")
                
                HStack {
                    Text("Name")
                    Image(systemName: "arrow.up.arrow.down")
                }
                
                HStack {
                    Text("Amount")
                    Image(systemName: "arrow.up.arrow.down")
                }
            })
            .foregroundColor(Color(.darkGray))
            
            LazyVGrid(columns: columns, content: {
                ForEach(fetchRequest.wrappedValue) { transaction in
                    
                    Group {
                        Text(dateFormatter.string(from: transaction.timestamp ?? Date() ))
                        
                        if let data = transaction.photoData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .cornerRadius(8)
                        } else {
                            Text("No photo available")
                        }
                        
                        
                        HStack {
                            Text(transaction.name ?? "")
                            Spacer()
                        }
                        
                        Text(String(format: "$%.02f", transaction.amount))
                    }
                    .multilineTextAlignment(.leading)
                    
                    
                }
            })
            
            
            
            
        }
        .font(.system(size: 20))
        .padding()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

struct MainPadDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        
        MainPadDeviceView()
            .environment(\.managedObjectContext, viewContext)
            .previewDevice(PreviewDevice(rawValue: "iPad Air (4th generation)"))
            .environment(\.horizontalSizeClass, .regular)
    }
}
