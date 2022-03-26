//
//  MainView.swift
//  SpendingTrackerSwiftUICoreDataLBTA
//
//  Created by Mohammed Hamdi on 09/09/2021.
//

import SwiftUI
import WidgetKit

struct MainView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Card.timestamp, ascending: false)],
        animation: .default)
    private var cards: FetchedResults<Card>
    
    
    @State var shouldPresentAddCardForm = false
    
    @State private var selectedCardHash = -1
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                if !cards.isEmpty {
                    TabView(selection: $selectedCardHash) {
                        ForEach(cards) { card in
                            CreditCardView(card: card)
                                .padding(.bottom, 50)
                                .tag(card.hash)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 280)
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    .onAppear {
                        self.selectedCardHash = cards.first?.hash ?? -1
                    }
                    
                    if let firstIndex = cards.firstIndex(where: {$0.hash == selectedCardHash}) {
                        let card = self.cards[firstIndex]
                        TransactionsListView(card: card)
                    }
                    
                    
                } else {
                    emptyPromptMessage
                }
            }
            .navigationTitle("Credit Cards")
            .navigationBarItems(trailing: addCardButton)
//            .navigationBarItems(leading: HStack {
//                addItemButton
//                deleteAllButton
//            }, trailing: addCardButton)
            .fullScreenCover(isPresented: $shouldPresentAddCardForm, content: {
                AddCardForm(card: nil) { card in
                    self.selectedCardHash = card.hash
                }
            })
        }
    }
    
    private var emptyPromptMessage: some View {
        VStack {
            Text("You currently have no cards in the system")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
                .padding(.vertical)
            
            Button(action: {
                shouldPresentAddCardForm.toggle()
            }, label: {
                Text("+ Add Your First Card")
            })
            .defaultButtonStyle()
        }
        .font(.system(size: 22, weight: .semibold))
    }
    
    var deleteAllButton: some View {
        Button(action: {
            cards.forEach { card in
                viewContext.delete(card)
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Error saving context while deleting cards: ", error)
            }
            
        }, label: {
            Text("Delete All")
        })
    }
    
    var addItemButton: some View {
        Button(action: {
            withAnimation {
                let viewContext = PersistenceController.shared.container.viewContext
                let card = Card(context: viewContext)
                card.timestamp = Date()

                do {
                    try viewContext.save()
                } catch {
                    print("Error adding mock card: ", error)
                }
            }
        }, label: {
            Text("Add Item")
        })
    }
    
    var addCardButton: some View {
        Button(action: {
            shouldPresentAddCardForm.toggle()
        }, label: {
            Text("+ Card")
                .foregroundColor(Color(.systemBackground))
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.label))
                .cornerRadius(5)
        })
    }    
}

struct CreditCardView: View {
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        
        fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [.init(key: "timestamp", ascending: false)], predicate: .init(format: "card == %@", self.card))
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var fetchRequest: FetchRequest<CardTransaction>
    
    @State private var shouldShowActionSheet = false
    @State private var shouldShowEditForm = false
    
    @State var refreshId = UUID()
    
    private func handleDelete() {
        let viewContext = PersistenceController.shared.container.viewContext
        
        viewContext.delete(card)
        
        do {
            try viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Error deleting card: ", error)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                Text(card.name ?? "")
                    .font(.system(size: 24, weight: .semibold))
                
                Spacer()
                
                Button(action: {
                    shouldShowActionSheet.toggle()
                }, label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 28, weight: .bold))
                })
                .actionSheet(isPresented: $shouldShowActionSheet, content: {
                    .init(title: Text(card.name ?? ""), message: Text("Options"), buttons: [
                        .default(Text("Edit"), action: {
                            shouldShowEditForm.toggle()
                        }),
                        .destructive(Text("Delete Card"), action: handleDelete),
                        .cancel()
                    ])
                })
            }
            
            HStack {
                Image(card.type ?? "visa")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 44)
                
                Spacer()
                
//                if let balance = fetchRequest.wrappedValue.reduce(0, {$0 + $1.amount}) {
                    
                Text("Balance: \(String(format: "$%.2f", card.balance))")
                        .font(.system(size: 18, weight: .semibold))
//                }
                
            }
            
            Text(card.number?.modifyCreditCardString() ?? "")
            
            HStack {
                Text("Card Limit: " + String(format: "$%.2f", card.limit))
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Valid Thru")
                    Text("\(String(format: "%02d", card.expMonth))/\(String(card.expYear % 2000))")
                }
            }
            
            HStack { Spacer() }
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        .padding(.top)
        .padding(.bottom, 8)
        .background(
            VStack {
                if let colorData = card.color,
                   let uiColor = UIColor.color(data: colorData),
                   let actualColor = Color(uiColor) {
                    
                    LinearGradient(gradient: Gradient(colors: [actualColor.opacity(0.6), actualColor]), startPoint: .top, endPoint: .bottom)
                } else {
                    Color.purple
                }
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.5), lineWidth: 1)
        )
        .cornerRadius(8)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.top, 8)
        .sheet(isPresented: $shouldShowEditForm, content: {
            AddCardForm(card: card)
        })
//        .fullScreenCover(isPresented: $shouldShowEditForm, content: {
//            AddCardForm(card: card)
//        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        MainView()
            .environment(\.managedObjectContext, viewContext)
    }
}

extension View {
    func defaultButtonStyle() -> some View {
        self.modifier(DefaultButtonStyle())
    }
}

struct DefaultButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(.systemBackground))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.label))
            .cornerRadius(5)
            .font(.headline)
    }
}
