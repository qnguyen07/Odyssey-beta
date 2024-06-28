//
//  ContentView.swift
//  ToDos
//
//  Created by Quynh Nguyen on 06/06/2023.
//
import SwiftUI
import SwiftData
import SwiftUIImageViewer
enum SortOption: String, CaseIterable {
    case title
    case date
    case category
}
extension SortOption {
    
    var systemImage: String {
        switch self {
        case .title:
            "textformat.size.larger"
        case .date:
            "calendar"
        case .category:
            "folder"
        }
    }
}
struct ContentView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var items: [Item]
    
    @State private var searchQuery = ""
//    @State private var showCreateCategory = false
    @State private var showCreateToDo = false
    @State private var toDoToEdit: Item?
    
    @State private var isImageViewerPresented = false
    @State private var isRankShowed = false
    
    @State private var selectedSortOption = SortOption.allCases.first!
    
    @State var isImagePickerShowing = false
    @State var selectedImage: UIImage?
    
    var filteredItems: [Item] {
        
        if searchQuery.isEmpty {
            return items.sort(on: selectedSortOption)
        }
        
        let filteredItems = items.compactMap { item in
            
            let titleContainsQuery = item.title.range(of: searchQuery,
                                                      options: .caseInsensitive) != nil
            
            let categoryTitleContainsQuery = item.category?.title.range(of: searchQuery,
                                                                        options: .caseInsensitive) != nil
            
            return (titleContainsQuery || categoryTitleContainsQuery) ? item : nil
        }
        
        return filteredItems.sort(on: selectedSortOption)
        
    }
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color(Color(red: 227/255, green: 237/255, blue: 255/255))
                    .ignoresSafeArea()
                    .navigationBarBackButtonHidden(true)
                VStack{
                    HStack {
                        Text("Odyssey")
                            .font(.system(size: 35, weight: .bold, design: .default))
                            .foregroundColor(Color(red: 28/255, green: 57/255, blue: 105/255))
                            .padding(27)
                        Spacer()
                        Button(action:{}) {
                            Menu{
                                NavigationLink(destination: SecondView()) {
                                    Button(action: { }) {
                                        Text("Your Passport")
                                    }
                                }
                                NavigationLink(destination: FourthView()) {
                                    Button(action: { }) {
                                        Text("Your Rankings")
                                    }
                                }
                                NavigationLink(destination: FifthView()) {
                                    Button(action: { }) {
                                        Text("Travel Quiz")
                                    }
                                }
                            }
                        label: {
                            Label(
                                title: {Text("") },
                                icon: {Image(systemName: "line.3.horizontal.decrease.circle")
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 27, height: 27)
                                        .foregroundColor(Color(red: 28/255, green: 57/255, blue: 105/255))
                                    .padding(20)}
                            )
                        }
                        }
                    }
                                    .sheet(item: $toDoToEdit,
                                           onDismiss: {
                                        toDoToEdit = nil
                                    },
                                           content: { editItem in
                                        NavigationStack {
                                            UpdateToDoView(item: editItem)
                                                .interactiveDismissDisabled()
                                        }
                                    })
                    
                    
                                    .sheet(isPresented: $showCreateToDo,
                                           content: {
                                        NavigationStack {
                                            CreateTodoView()
                                            isRankShowed.toggle()
                                        }
                                    })
                                    .sheet(isPresented: $isRankShowed) {
                                        print("Sheet dismissed!")
                                    } content: {
                                        Ranking(item: <#T##Item#>, item2: <#T##Item#>, item3: <#T##Item#>)
                                    }
                    ScrollView(showsIndicators: false){
                        VStack(spacing: 0.1){
                            ForEach(filteredItems) { item in
                                ZStack{
                                    (Rectangle()
                                        .frame(width: 350, height: 275)
                                        .foregroundColor(.white))
                                    .cornerRadius(13)
                                    .padding(10)
                                    VStack {
                                        if let selectedPhotoData = item.image,
                                           let uiImage = UIImage(data: selectedPhotoData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(maxWidth: .infinity, maxHeight: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 10,
                                                                            style: .continuous))
                                                .onTapGesture {
                                                    isImageViewerPresented = true
                                                }
                                                .fullScreenCover(isPresented: $isImageViewerPresented) {
                                                    SwiftUIImageViewer(image: Image(uiImage: uiImage))
                                                        .overlay(alignment: .topTrailing) {
                                                            Button {
                                                                isImageViewerPresented = false
                                                            } label: {
                                                                Image(systemName: "xmark")
                                                                    .font(.headline)
                                                            }
                                                            .buttonStyle(.bordered)
                                                            .clipShape(Circle())
                                                            .tint(.purple)
                                                            .padding()
                                                        }
                                                }
                                        }
                                        HStack {
                                            Text(item.title)
                                                .underline(true, color: .gray)
                                                .font(.system(size: 25, design: .default))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .foregroundColor(.black)
                                                .padding([.leading], 34)
                                                .padding([.bottom], 4)
                                            //Spacer()
                                            Menu {
                                                Button(action: {
                                                    toDoToEdit = item
                                                }) {
                                                    HStack{
                                                        Image(systemName: "pencil")
                                                        Text("Edit")
                                                    }
                                                    
                                                }
                                                Button(action: {
                                                    modelContext.delete(item)
                                                }) {
                                                    HStack{
                                                        Image(systemName: "trash.fill")
                                                        Text("Delete")
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "ellipsis")
                                                    .renderingMode(.original)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 20, height: 20)
                                                    .foregroundColor(.gray)
                                                    .padding([.trailing], 40)
                                            }
                                            
                                            
                                            Spacer()
                                            
                                            //
                                        }
                                        VStack(alignment: .leading) {
                                            
                                            if let category = item.category {
                                                Text(category.title)
                                                    .foregroundStyle(Color.blue)
                                                    .bold()
                                                    .padding(.horizontal)
                                                    .padding(.vertical, 8)
                                                    .background(Color.blue.opacity(0.1),
                                                                in: RoundedRectangle(cornerRadius: 8,
                                                                                     style: .continuous))
                                            }
                                            Text("\(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .shortened))")
                                                .font(.callout)
                                            
                                        }
                                        Text("The quick brown fox jumps over the lazy dog. Sphinx of black quartz judge my vow.")
                                            .padding([.leading], 35)
                                            .padding([.trailing], 35)
                                    }
                                }
                            }
                        }
                    }//scroll
                         Button(action:{showCreateToDo.toggle()}) {
                          Image("Plus")
                           .resizable()
                           .aspectRatio(contentMode: .fit)
                           .frame(width: 80, height: 80)
                           .foregroundColor(Color(red: 28/255, green: 57/255, blue: 105/255))
                           .padding(-17)
                           
                      } // button
                }//vstack
                
            }//zstack
            .overlay {
                if filteredItems.isEmpty {

                    ContentUnavailableView(label: {
                        Image(systemName: "airplane")
                            .foregroundColor(.gray)
                            .padding([.top], 100)
                        Text("Add Your First Destination")
                            .foregroundColor(.gray)
                    })
                    .offset(y: -60)
                }
            }
        }//nav
    }
    
    private func delete(item: Item) {
        withAnimation {
            modelContext.delete(item)
        }
    }
}

private extension [Item] {
    
    func sort(on option: SortOption) -> [Item] {
        switch option {
        case .title:
            self.sorted(by: { $0.title < $1.title })
        case .date:
            self.sorted(by: { $0.timestamp < $1.timestamp })
        case .category:
            self.sorted(by: {
                guard let firstItemTitle = $0.category?.title,
                      let secondItemTitle = $1.category?.title else { return false }
                return firstItemTitle < secondItemTitle
            })
        }
    }
}

// Xcode 15 Beta 2 has a previews bug so this is why we're commenting this out...
// Ref: https://mastodon.social/@denisdepalatis/110561280521551715
//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}
