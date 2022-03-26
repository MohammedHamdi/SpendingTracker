//
//  AddCardForm.swift
//  SpendingTrackerSwiftUICoreDataLBTA
//
//  Created by Mohammed Hamdi on 09/09/2021.
//

import SwiftUI
import WidgetKit

struct AddCardForm: View {
    
    let card: Card?
    var didAddCard: ((Card) -> ())? = nil
    
    init(card: Card? = nil, didAddCard: ((Card) -> ())? = nil) {
        self.card = card
        self.didAddCard = didAddCard
        
        _name = State(initialValue: self.card?.name ?? "")
        _cardNumber = State(initialValue: self.card?.number ?? "")
        
        if let limit = card?.limit {
            _limit = State(initialValue: String(limit))
        }
        
        _cardType = State(initialValue: self.card?.type ?? "Visa")
        
        _month = State(initialValue: Int(self.card?.expMonth ?? 1))
        _year = State(initialValue: Int(self.card?.expYear ?? Int16(currentYear)))
        
        if let colorData = self.card?.color,
           let uiColor = UIColor.color(data: colorData) {
            _color = State(initialValue: Color(uiColor))
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var cardNumber: String = ""
    @State private var limit: String = ""
    
    @State private var cardType = "Visa"
    
    @State private var month = 1
    @State private var year = Calendar.current.component(.year, from: Date())
    let currentYear = Calendar.current.component(.year, from: Date())
    
    @State private var color = Color.blue
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card  Information")) {
                    
                    TextField("Name", text: $name)
                    
                    TextField("Credit Card Number", text: $cardNumber)
                        .keyboardType(.asciiCapableNumberPad)
                    
                    TextField("Card Limit", text: $limit)
                        .keyboardType(.decimalPad)
                    
                    Picker("Type", selection: $cardType) {
                        ForEach(["Visa", "Mastercard"], id: \.self) { cardType in
                            Text(String(cardType)).tag(String(cardType))
                        }
                    }
                    
                }
                
                Section(header: Text("Expiration")) {
                    Picker("Month", selection: $month) {
                        ForEach(1...12, id: \.self) { month in
                            Text(String(month)).tag(month)
                            
                        }
                    }
                    
                    Picker("Year", selection: $year) {
                        ForEach(currentYear...currentYear + 20, id: \.self) { year in
                            Text(String(year)).tag(year)
                            
                        }
                    }
                }
                
                Section(header: Text("Color")) {
                    ColorPicker("Color", selection: $color)
                }
            }
            .navigationTitle(self.card != nil ? self.card?.name ?? "" : "Add Credit Card")
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            let viewContext = PersistenceController.shared.container.viewContext
            
            let card = self.card != nil ? self.card! : Card(context: viewContext)
            
//            let card = Card(context: viewContext)
            
            card.name = self.name
            card.number = self.cardNumber
            card.limit = Float(self.limit) ?? 0
            card.expMonth = Int16(self.month)
            card.expYear = Int16(self.year)
            card.timestamp = Date()
            card.color = UIColor(self.color).encode()
            card.type = cardType
            card.balance = self.card != nil ? self.card!.balance : Float(self.limit) ?? 0
            
            do {
                try viewContext.save()
                
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                    didAddCard?(card)
                }
                
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                print("Error saving card: ", error)
            }
            
        }, label: {
            Text("Save")
        })
    }
    
    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
    }
}

struct AddCardForm_Previews: PreviewProvider {
    static var previews: some View {
//        AddCardForm()
        let viewContext = PersistenceController.shared.container.viewContext
        MainView().environment(\.managedObjectContext, viewContext)
    }
}

extension UIColor {
    class func color(data: Data) -> UIColor? {
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
    }
    
    func encode() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
}
