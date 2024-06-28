//
//  ModifyTodoView.swift
//  ToDos
//
//  Created by Tunde Adegoroye on 06/06/2023.
//

import SwiftUI
import SwiftData
import PhotosUI
struct CreateTodoView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
        
    @Query private var categories: [Category]
    
    @State var item = Item()
    @State var selectedCategory: Category?
    @State var selectedPhoto: PhotosPickerItem?
    
    @State var isImagePickerShowing = false
    @State var selectedImage: UIImage?
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        List {
            
            Section("Destination Title") {
                TextField("Name", text: $item.title)
            }
            
            Section("General") {
                DatePicker("Choose a date",
                           selection: $item.timestamp)
                
            }
            
            Section("Select A Category") {
                
                
                if categories.isEmpty {
                    
                    ContentUnavailableView("No Categories",
                                           systemImage: "archivebox")
                    
                } else {
                    Picker("", selection: $selectedCategory) {
                        
                        ForEach(categories) { category in
                            Text(category.title)
                                .tag(category as Category?)
                        }
                        
                        Text("None")
                            .tag(nil as Category?)
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                }
                
            }
            
            Section {
                
                if let selectedPhotoData = item.image,
                   let uiImage = UIImage(data: selectedPhotoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                }
                
                PhotosPicker(selection: $selectedPhoto,
                             matching: .images,
                             photoLibrary: .shared()) {
                    Label("Add Image", systemImage: "photo")
                }
                
                Button("Take a picture"){
                    self.sourceType = .camera
                    self.isImagePickerShowing.toggle()
                }
                
                
                
                
                if item.image != nil {
                    
                    Button(role: .destructive) {
                        withAnimation {
                            selectedPhoto = nil
                            item.image = nil
                        }
                    } label: {
                        Label("Remove Image", systemImage: "xmark")
                            .foregroundStyle(.red)
                    }
                }
 
            }
            
            Section {
                Button("Create") {
                    save()
                    dismiss()
                }
            }
        }
        .navigationTitle("Create Destination")
        .toolbar {
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Dismiss") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button("Done") {
                    save()
                    dismiss()
                }
                .disabled(item.title.isEmpty)
            }
        }
        .task(id: selectedPhoto) {
            if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                item.image = data
            }
        }
    }
}

private extension CreateTodoView {
    
    func save() {
        modelContext.insert(item)
        item.category = selectedCategory
        selectedCategory?.items?.append(item)
    }
}

///
///
///

struct Ranking: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @State var isFirstSelectionDone = false
    @State var isSecondSelectionDone = false
    
    @Bindable var item: Item
    @Bindable var item2: Item
    @Bindable var item3: Item
   
    var body: some View {
        if !isFirstSelectionDone && !isSecondSelectionDone{
            VStack{
                Text("Which destination did you like better?")
                HStack{
                    Button {
                        calcAndUpdateElo(itemA: item, itemB: item2, didAWins: true)
                    } label: {
                        Text(item.title)
                    }
                    Button{
                        calcAndUpdateElo(itemA: item2, itemB: item, didAWins: true)
                    } label: {
                        Text(item2.title)
                    }
                    
                    TextField("Name", text: $item.title)
                }
            }
        }
        else if isFirstSelectionDone && !isSecondSelectionDone{
            VStack{
                Text("Which destination did you like better?")
                HStack{
                    Button {
                        calcAndUpdateElo(itemA: item, itemB: item3, didAWins: true)
                    } label: {
                        Text(item.title)
                    }
                    Button{
                        calcAndUpdateElo(itemA: item3, itemB: item, didAWins: true)
                    } label: {
                        Text(item3.title)
                    }
                    
                    TextField("Name", text: $item.title)
                }
            }
        }
        else if isFirstSelectionDone && isSecondSelectionDone{
            Button {
                dismiss()
            } label: {
                Text("Back to Home")
            }

        }
//        .navigationTitle("Create Destination")
//        .toolbar {
//            
//            ToolbarItem(placement: .cancellationAction) {
//                Button("Dismiss") {
//                    dismiss()
//                }
//            }
//            
//            ToolbarItem(placement: .primaryAction) {
//                Button("Done") {
//                    save()
//                    dismiss()
//                }
//                .disabled(item.title.isEmpty)
//            }
//        }
    }
}

private extension Ranking {
    
    func calcAndUpdateElo(@Binding itemA: Item, @Binding itemB: Item, didAWins: Bool) {
        let K: Double = 32
        let eloDiff = Double(itemB.elo - itemA.elo)
        let exp = pow(10, eloDiff / 400)
        let expectedA = 1 / (1 + exp)
        let resultA = didAWins ? 1.0 : 0.0
        let changeA = K * (resultA - expectedA)
        
        itemA.elo += Int(changeA)
        itemB.elo -= Int(changeA)
    }

}


// Xcode 15 Beta 2 has a previews bug so this is why we're commenting this out...
// Ref: https://mastodon.social/@denisdepalatis/110561280521551715
#Preview {
    NavigationStack {
        CreateTodoView()
            .modelContainer(for: Item.self)
    }
}

//
//  UpdateToDoView.swift
//  ToDos
//
//  Created by Tunde Adegoroye on 08/06/2023.
//



import SwiftUI
import SwiftData
import PhotosUI
class OriginalToDo {
    var title: String
    var timestamp: Date
    var isCritical: Bool
    
    init(item: Item) {
        self.title = item.title
        self.timestamp = item.timestamp
        self.isCritical = item.isCritical
    }
}
struct UpdateToDoView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Query private var categories: [Category]
    
    @State var selectedCategory: Category?
    @State var selectedPhoto: PhotosPickerItem?
    @Bindable var item: Item
    var body: some View {
        List {
            
            Section("To do title") {
                TextField("Name", text: $item.title)
            }
            
            Section("General") {
                DatePicker("Choose a date",
                           selection: $item.timestamp)
            }
            
            
            
            Section("Select A Category") {
                
                
                if categories.isEmpty {
                    
                    ContentUnavailableView("No Categories",
                                           systemImage: "archivebox")
                    
                } else {
                    
                    Picker("", selection: $selectedCategory) {
                        
                        ForEach(categories) { category in
                            Text(category.title)
                                .tag(category as Category?)
                        }
                        
                        Text("None")
                            .tag(nil as Category?)
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                }
                
            }
            
            Section {
                
                if let selectedPhotoData = item.image,
                   let uiImage = UIImage(data: selectedPhotoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                }
                
                PhotosPicker(selection: $selectedPhoto,
                             matching: .images,
                             photoLibrary: .shared()) {
                    Label("Add Image", systemImage: "photo")
                }
                
                if item.image != nil {
                    
                    Button(role: .destructive) {
                        withAnimation {
                            selectedPhoto = nil
                            item.image = nil
                        }
                    } label: {
                        Label("Remove Image", systemImage: "xmark")
                            .foregroundStyle(.red)
                    }
                }
 
            }
            
            Section {
                Button("Update") {
                    item.category = selectedCategory
                    dismiss()
                }
            }
        }
        .navigationTitle("Update Item")
        .onAppear(perform: {
            selectedCategory = item.category
        })
        .task(id: selectedPhoto) {
            if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                item.image = data
            }
        }
    }
}

// Xcode 15 Beta 2 has a previews bug so this is why we're commenting this out...
// Ref: https://mastodon.social/@denisdepalatis/110561280521551715
//#Preview {
//    UpdateToDoView(item: Item.dummy)
//        .modelContainer(for: Item.self)
//
//}
