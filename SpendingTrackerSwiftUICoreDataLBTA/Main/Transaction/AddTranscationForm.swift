//
//  AddTranscationForm.swift
//  SpendingTrackerSwiftUICoreDataLBTA
//
//  Created by Mohammed Hamdi on 14/09/2021.
//

import SwiftUI
import CoreData
import WidgetKit

struct AddTranscationForm: View {
    
    let card: Card
    
    init(card: Card) {
        self.card = card
        
        let context = PersistenceController.shared.container.viewContext
        
        let request: NSFetchRequest<TransactionCategory> = NSFetchRequest(entityName: "TransactionCategory")
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        
        do {
            let result = try context.fetch(request)
            if let first = result.first {
                self._selectedCategories = .init(initialValue: [first])
            }
        } catch {
            print("Failed to preselect categories: ", error)
        }
    }
    
    @State private var name = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var photoData: Data?
    
    @State private var shouldPresentPhotoPicker = false
    
    @State private var selectedCategories = Set<TransactionCategory>()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                
                Section(header: Text("Information")) {
                    TextField("Name", text: $name)
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .accentColor(Color(.label))
                }
                
                Section(header: Text("Categories")) {
                    NavigationLink(
                        destination: CategoriesListView(selectedCategories: $selectedCategories)
                            .navigationTitle("Categories")
                            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext),
                        label: {
                            Text("Select Categories")
                        })
                    
                    let sortedByTimestampCategories = Array(selectedCategories).sorted(by: { $0.timestamp?.compare($1.timestamp ?? Date()) == .orderedDescending })
                    
                    ForEach(sortedByTimestampCategories) { category in
                        
                        HStack(spacing: 12) {
                            if let colorData = category.colorData, let uiColor = UIColor.color(data: colorData) {
                                Spacer()
                                    .frame(width: 30, height: 10)
                                    .background(Color(uiColor))
                            }
                            
                            Text(category.name ?? "")
                        }
                    }
                }
                
                Section(header: Text("Photo/Receipt")) {
                    Button(action: {
                        shouldPresentPhotoPicker.toggle()
                    }, label: {
                        Text("Select Photo")
                    })
                    .fullScreenCover(isPresented: $shouldPresentPhotoPicker, content: {
                        PhotoPickerView(photoData: $photoData)
                    })
                    
                    if let data = photoData, let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                    
                }
                
                
            }
            .navigationTitle("Add Transaction")
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            let context = PersistenceController.shared.container.viewContext
            let transaction = CardTransaction(context: context)
            
            transaction.name = self.name
            transaction.timestamp = self.date
            transaction.amount = Float(self.amount) ?? 0
            transaction.photoData = self.photoData
            
            transaction.card = self.card
            
            transaction.categories = self.selectedCategories as NSSet
            
            // Update card balance
            let floatAmount: Float = Float(self.amount) ?? 0.0
            debugPrint("balance: \(self.card.balance), amount: \(floatAmount)")
            card.balance = self.card.balance - floatAmount
            
            do {
                try context.save()
                WidgetCenter.shared.reloadAllTimelines()
                
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
                
            } catch {
                print("Failed to save transaction: \(error)")
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

struct AddTranscationForm_Previews: PreviewProvider {
    static let firstCard: Card? = {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Card> = NSFetchRequest(entityName: "Card")
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        return try? context.fetch(request).first
    }()
    
    static var previews: some View {
        if let card = firstCard {
            AddTranscationForm(card: card)
        }
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {
    
    @Binding var photoData: Data?
    
    typealias UIViewControllerType = UIImagePickerController
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    //MARK: - Coordinator
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        private let parent: PhotoPickerView
        
        init(parent: PhotoPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            let image = info[.originalImage] as? UIImage
            let resizedImage = image?.resized(to: .init(width: 500, height: 500))
            let imageData = resizedImage?.jpegData(compressionQuality: 0.5)
            
            parent.photoData = imageData
            
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
}


extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            let hScale = newSize.height / size.height
            let vScale = newSize.width / size.width
            let scale = max(hScale, vScale) // scaleToFill
            let resizeSize = CGSize(width: size.width * scale, height: size.height * scale)
            var middle = CGPoint.zero
            if resizeSize.width > newSize.width {
                middle.x -= (resizeSize.width - newSize.width) / 2.0
            }
            if resizeSize.height > newSize.height {
                middle.y -= (resizeSize.height - newSize.height) / 2.0
            }
            
            draw(in: CGRect(origin: middle, size: resizeSize))
        }
    }
}
