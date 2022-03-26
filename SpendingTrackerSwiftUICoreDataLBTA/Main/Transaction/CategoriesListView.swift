//
//  CategoriesListView.swift
//  SpendingTrackerSwiftUICoreDataLBTA
//
//  Created by Mohammed Hamdi on 15/09/2021.
//

import SwiftUI

struct CategoriesListView: View {
    
    @State private var name: String = ""
    @State private var color = Color.red
    
    @Binding var selectedCategories: Set<TransactionCategory>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionCategory.timestamp, ascending: false)],
        animation: .default)
    private var categories: FetchedResults<TransactionCategory>
    
    var body: some View {
        Form {
            Section(header: Text("Select a category")) {
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
                .onDelete(perform: { indexSet in
                    indexSet.forEach { index in
                        let category = categories[index]
                        selectedCategories.remove(category)
                        viewContext.delete(category)
                    }
                    
                    try? viewContext.save()
                })
            }
            
            Section(header: Text("Create a category")) {
                TextField("Name", text: $name)
                
                ColorPicker("Color", selection: $color)
                
                Button(action: handleCreate, label: {
                    HStack {
                        Spacer()
                        Text("Create")
                            .foregroundColor(Color.white)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(5)
                })
                .buttonStyle(PlainButtonStyle())
            }
            
        }
    }
    
    private func handleCreate() {
        let context = PersistenceController.shared.container.viewContext
        
        let category = TransactionCategory(context: context)
        category.name = name
        category.colorData = UIColor(color).encode()
        category.timestamp = Date()
        
        do {
            try context.save()
            self.name = ""
        } catch {
            print("Error saving category: ", error)
        }
    }
}

struct CategoriesListView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesListView(selectedCategories: .constant(.init()))
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
