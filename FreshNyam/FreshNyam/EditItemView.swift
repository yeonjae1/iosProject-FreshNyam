import SwiftUI

struct EditItemView: View {
    @ObservedObject var itemManager: ItemManager
    @ObservedObject var item: Item
    @Environment(\.presentationMode) var presentationMode
    @State private var showImagePicker = false
    @State private var searchQuery = ""
    @State private var selectedImageName: String
    
    init(itemManager: ItemManager, item: Item) {
        self.itemManager = itemManager
        self.item = item
        _selectedImageName = State(initialValue: item.imageName)
    }
    
    var filteredImages: [String: [String]] {
        if searchQuery.isEmpty {
            return itemManager.images
        } else {
            var filtered = [String: [String]]()
            for (key, value) in itemManager.images {
                let filteredValues = value.filter { $0.contains(searchQuery) }
                if !filteredValues.isEmpty {
                    filtered[key] = filteredValues
                }
            }
            return filtered
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("식품명")) {
                    TextField("식품명", text: $item.name)
                        .onChange(of: item.name) { _ in
                            itemManager.updateItem(item)
                        }
                }
                Section(header: Text("카테고리")) {
                    Picker("카테고리", selection: $item.category) {
                        ForEach(itemManager.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .onChange(of: item.category) { _ in
                        itemManager.updateItem(item)
                    }
                }
                Section(header: Text("아이콘 선택")) {
                    Button(action: {
                        showImagePicker.toggle()
                    }) {
                        HStack {
                            Text(selectedImageName.isEmpty ? "아이콘 선택" : selectedImageName)
                                .foregroundColor(selectedImageName.isEmpty ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                Section(header: Text("보관 장소")) {
                    Picker("보관 장소", selection: $item.storage) {
                        ForEach(StorageType.allCases, id: \.self) { storage in
                            Text(storage.rawValue).tag(storage)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: item.storage) { _ in
                        itemManager.updateItem(item)
                    }
                }
                Section(header: Text("소비기한")) {
                    DatePicker("소비기한", selection: $item.expiryDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .onChange(of: item.expiryDate) { _ in
                            itemManager.updateItem(item)
                        }
                }
                Section(header: Text("추가된 날짜")) {
                    DatePicker("추가된 날짜", selection: $item.addedDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .onChange(of: item.addedDate) { _ in
                            itemManager.updateItem(item)
                        }
                }
            }
            .navigationBarTitle("수정하기", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                item.imageName = selectedImageName
                itemManager.updateItem(item)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("저장")
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(selectedImageName: $selectedImageName, images: filteredImages, searchQuery: $searchQuery)
                    .onDisappear {
                        item.imageName = selectedImageName
                        itemManager.updateItem(item)
                    }
            }
        }
    }
}
