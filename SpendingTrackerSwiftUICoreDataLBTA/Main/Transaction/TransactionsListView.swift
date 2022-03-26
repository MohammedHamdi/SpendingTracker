//
//  TransactionsListView.swift
//  SpendingTrackerSwiftUICoreDataLBTA
//
//  Created by Mohammed Hamdi on 14/09/2021.
//

import SwiftUI
import CoreData

struct TransactionsListView: View {
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        
        fetchRequest = FetchRequest<CardTransaction>(entity: CardTransaction.entity(), sortDescriptors: [.init(key: "timestamp", ascending: false)], predicate: .init(format: "card == %@", self.card))
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var fetchRequest: FetchRequest<CardTransaction>
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \CardTransaction.timestamp, ascending: false)],
//        animation: .default)
//    private var transactions: FetchedResults<CardTransaction>
    
    @State var shouldShowTransactionForm = false
    @State var shouldShowFilterSheet = false
    
    @State var selectedCategories = Set<TransactionCategory>()
    
    var body: some View {
        VStack {
            
            if fetchRequest.wrappedValue.isEmpty {
                Text("Get started by adding your first transaction")
                
                Button(action: {
                    shouldShowTransactionForm.toggle()
                }, label: {
                    Text("+ Transaction")
                })
                .defaultButtonStyle()
                
                
            } else {
                HStack {
                    Spacer()
                    addTransactionButton
                    filterButton
                        .sheet(isPresented: $shouldShowFilterSheet, content: {
                            FilterSheet(selectedCategories: self.selectedCategories, didSaveFilters: { categories in
                                self.selectedCategories = categories
                            })
                            
                        })
                }
                .padding(.horizontal)
                
                ForEach(filterTransactions(selectedCategories: self.selectedCategories), id: \.self) { transaction in
                    CardTransactionView(transaction: transaction)
                }
            }
        }
        .fullScreenCover(isPresented: $shouldShowTransactionForm, content: {
            AddTranscationForm(card: card)
        })
    }
    
    private func filterTransactions(selectedCategories: Set<TransactionCategory>) -> [CardTransaction] {
        if selectedCategories.isEmpty {
            return Array(fetchRequest.wrappedValue)
        }
        
        return fetchRequest.wrappedValue.filter { transaction in
            var shouldKeep = false
            
            if let categories = transaction.categories as? Set<TransactionCategory> {
                
                categories.forEach({ category in
                    if selectedCategories.contains(category) {
                        shouldKeep = true
                    }
                })
            }
            return shouldKeep
        }
    }
    
    private var addTransactionButton: some View {
        Button(action: {
            shouldShowTransactionForm.toggle()
        }, label: {
            Text("+ Transaction")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(.systemBackground))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.label))
                .cornerRadius(5)
        })
    }
    
    private var filterButton: some View {
        Button(action: {
            shouldShowFilterSheet.toggle()
        }, label: {
            HStack {
                Image(systemName: "line.horizontal.3.decrease.circle")
                Text("Filter")
            }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(.systemBackground))
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.label))
                .cornerRadius(5)
        })
    }
}

struct TransactionsListView_Previews: PreviewProvider {
    static let firstCard: Card? = {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        return try? context.fetch(request).first
    }()
    
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        NavigationView {
            ScrollView {
                if let card = firstCard {
                    TransactionsListView(card: card)
                }
            }
        }
        .environment(\.managedObjectContext, viewContext)
        .colorScheme(.dark)
    }
}

struct CardTransactionView: View {
    
    let transaction: CardTransaction
    
    @State private var shouldPresentActionSheet = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(transaction.name ?? "")
                        .font(.headline)
                    
                    if let date = transaction.timestamp {
                        Text(dateFormatter.string(from: date))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Button(action: {
                        shouldPresentActionSheet.toggle()
                    }, label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 24))
                    })
                    .padding(EdgeInsets(top: 6, leading: 8, bottom: 4, trailing: 0))
                    .actionSheet(isPresented: $shouldPresentActionSheet, content: {
                        .init(title: Text(transaction.name ?? ""), message: nil, buttons: [
                            .destructive(Text("Delete"), action: handleDelete),
                            .cancel()
                        ])
                    })
                    
                    Text(String(format: "$%.2f", transaction.amount))
                    
                }
            }
            
            if let categories = transaction.categories as? Set<TransactionCategory>, let sortedByTimestampCategories = Array(categories).sorted(by: { $0.timestamp?.compare($1.timestamp ?? Date()) == .orderedDescending }) {
                
                HStack {
                    ForEach(sortedByTimestampCategories) { category in
                        HStack {
                            if let colorData = category.colorData, let uiColor = UIColor.color(data: colorData) {
                                
                                Text(category.name ?? "")
                                    .font(.system(size: 16, weight: .bold))
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 8)
                                    .background(Color(uiColor))
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                        }
                    }
                    Spacer()
                }
            }
            
            
            if let photoData = transaction.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
            
            HStack{ Spacer() }
        }
        .foregroundColor(Color(.label))
        .padding()
        .background(Color.cardTransactionBackground)
        .cornerRadius(5)
        .shadow(radius: 5)
        .padding()
    }
    
    private func handleDelete() {
        withAnimation {
            let context = PersistenceController.shared.container.viewContext
            
            context.delete(transaction)
            
            do {
                try context.save()
            } catch {
                print("Error deleting transaction: ", error)
            }
        }
        
    }
}


struct FilterSheet: View {
    
    @State var selectedCategories: Set<TransactionCategory>
    let didSaveFilters: (Set<TransactionCategory>) -> ()
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
        animation: .default)
    private var categories: FetchedResults<TransactionCategory>
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(categories) { category in
                    Button(action: {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    }, label: {
                        HStack(spacing: 12) {
                            if let colorData = category.colorData, let uiColor = UIColor.color(data: colorData) {
                                Spacer()
                                    .frame(width: 30, height: 10)
                                    .background(Color(uiColor))
                            }
                            
                            Text(category.name ?? "")
                                .foregroundColor(Color(.label))
                            
                            Spacer()
                            
                            if selectedCategories.contains(category) {
                                Image(systemName: "checkmark")
                            }

                        }
                    })
                    
                }
            }
            .navigationTitle("Select Filters")
            .navigationBarItems(trailing: saveButton)
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    private var saveButton: some View {
        Button(action: {
            didSaveFilters(selectedCategories)
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Save")
        })
    }
}
