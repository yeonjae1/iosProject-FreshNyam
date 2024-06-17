import SwiftUI

struct AddItemView: View {
    @ObservedObject var itemManager: ItemManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var category = ""
    @State private var storage: StorageType = .fridge
    @State private var expiryDate = Date()
    @State private var selectedImageName = ""
    @State private var searchQuery = ""
    @State private var showImagePicker = false

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
                    TextField("식품명", text: $name)
                }
                Section(header: Text("카테고리")) {
                    Picker("카테고리", selection: $category) {
                        ForEach(itemManager.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .onAppear {
                        // 처음 화면이 로드될 때 기본값 설정
                        if category.isEmpty, let firstCategory = itemManager.categories.first {
                            category = firstCategory
                        }
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
                    Picker("보관 장소", selection: $storage) {
                        ForEach(StorageType.allCases, id: \.self) { storage in
                            Text(storage.rawValue).tag(storage)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("소비기한")) {
                    DatePicker("소비기한", selection: $expiryDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                }
            }
            .navigationBarTitle("추가하기", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                itemManager.addItem(name: name, category: category, storage: storage, expiryDate: expiryDate, imageName: selectedImageName)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("완료")
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(selectedImageName: $selectedImageName, images: filteredImages, searchQuery: $searchQuery)
            }
        }
    }
}
