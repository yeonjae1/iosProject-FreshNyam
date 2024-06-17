import SwiftUI
import UserNotifications

struct ContentView: View {
    @ObservedObject var itemManager = ItemManager()
    @AppStorage("appAppearance") var appAppearance: AppAppearance = .system
    @State private var showAddItemView = false
    @State private var showSearchBar = false
    @State private var searchText = ""
    @State private var selectedStorage: StorageType = .fridge
    @State private var sortOrder: SortOrder = .expiryDate
    @State private var showSettingsView = false
    @State private var selectedItem: Item?
    @State private var showEditItemView = false
    @State private var showDeleteAlert = false
    @State private var itemToDelete: Item?

    var body: some View {
        NavigationView {
            VStack {
                if showSearchBar {
                    searchBar
                }
                
                storagePicker
                
                Group {
                    if itemManager.viewMode == .grid {
                        itemListGrid
                    } else {
                        itemListList
                    }
                }
                .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
                .navigationBarTitle("내 냉장고", displayMode: .inline)
                .navigationBarItems(
                    leading: leadingNavigationBarItems,
                    trailing: addButton
                )
                .sheet(isPresented: $showSettingsView) {
                    SettingsView(itemManager: itemManager)
                }
                .sheet(isPresented: $showAddItemView) {
                    AddItemView(itemManager: itemManager)
                }
                .sheet(item: $selectedItem) { item in
                    EditItemView(itemManager: itemManager, item: item)
                }
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("삭제 확인"),
                        message: Text("\(itemToDelete?.name ?? "")을(를) 삭제하시겠습니까?"),
                        primaryButton: .destructive(Text("삭제")) {
                            if let item = itemToDelete {
                                deleteItem(item: item)
                            }
                        },
                        secondaryButton: .cancel(Text("취소"))
                    )
                }
                Button("테스트 아이템 추가") {
                    addItemForTesting()
                }
                .onChange(of: itemManager.viewMode) { newValue in
                    itemManager.saveViewMode()
                }
                .onAppear {
                    requestNotificationAuthorization()
                }
            }
            .preferredColorScheme(appAppearance.colorScheme)
        }
    }

    func addItemForTesting() {
        let itemName = "테스트 아이템"
        let expiryDate = Date().addingTimeInterval(60 * 2) // 현재 시간으로부터 2분 후
        itemManager.addItem(name: itemName, category: "테스트", storage: .fridge, expiryDate: expiryDate)
    }

    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization request error: \(error.localizedDescription)")
            } else if granted {
                print("Notification authorization granted")
            } else {
                print("Notification authorization denied")
            }
        }
    }
    
    var searchBar: some View {
        HStack {
            TextField("검색", text: $searchText)
                .padding(10)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .foregroundColor(Color.primary)
            Button(action: {
                withAnimation {
                    showSearchBar = false
                    searchText = ""
                }
            }) {
                Text("취소")
                    .padding(.leading, 8)
            }
        }
        .padding(.horizontal)
    }
    
    var storagePicker: some View {
        HStack {
            Picker("보관 장소", selection: $selectedStorage) {
                ForEach(StorageType.allCases, id: \.self) { storage in
                    Text(storage.rawValue).tag(storage)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Spacer()
            
            sortMenu
        }
        .padding(.horizontal)
    }
    
    var itemListGrid: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(groupedCategories, id: \.self) { category in
                    Section(header: Text(category)
                                .font(.title3)
                                .bold()
                                .padding(.horizontal)) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                            ForEach(filteredItems(for: category), id: \.id) { item in
                                itemCard(for: item)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    var itemListList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(groupedCategories, id: \.self) { category in
                    Section(header: Text(category)
                                .font(.title3)
                                .bold()
                                .padding(.horizontal)) {
                        ForEach(filteredItems(for: category), id: \.id) { item in
                            itemRow(for: item)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    func itemRow(for item: Item) -> some View {
        HStack {
            if let image = UIImage(named: item.imageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
            }
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(item.name)
                        .font(.system(size:18))
                    Text("D-\(daysUntilExpiry(expiryDate: item.expiryDate))")
                        .font(.caption)
                        .foregroundColor(
                            Color(UIColor { traitCollection in
                                traitCollection.userInterfaceStyle == .dark ? .systemGray3 : .gray
                            })
                        )
                }
                Text("추가된 날짜: \(itemDateFormatter.string(from: item.addedDate))")
                    .font(.caption)
                Text("소비기한: \(itemDateFormatter.string(from: item.expiryDate))")
                    .font(.caption)
                    .foregroundColor(daysUntilExpiry(expiryDate: item.expiryDate) <= 3 ? .red : .primary)
            }
            Spacer()
        }
        .padding()
        .background(
            Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? .systemGray4 : .white
            })
        )
        .cornerRadius(15)
        .contextMenu {
            Button(action: {
                selectedItem = item
                showEditItemView = true
            }) {
                Text("수정하기")
                Image(systemName: "pencil")
            }
            Button(action: {
                itemToDelete = item
                showDeleteAlert = true
            }) {
                Text("삭제하기")
                Image(systemName: "trash")
            }
        }
    }

    var leadingNavigationBarItems: some View {
        Menu {
            Button(action: {
                withAnimation {
                    showSearchBar.toggle()
                }
            }) {
                Label("검색", systemImage: "magnifyingglass")
            }
            Button(action: {
                showSettingsView = true
            }) {
                Label("설정", systemImage: "gearshape")
            }
            Picker("보기 방식", selection: $itemManager.viewMode) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
        } label: {
            Image(systemName: "ellipsis")
        }
    }
    
    var sortMenu: some View {
        Menu {
            Button(action: { sortOrder = .name }) {
                Label("이름순", systemImage: "textformat")
            }
            Button(action: { sortOrder = .expiryDate }) {
                Label("D-Day 순", systemImage: "calendar")
            }
            Button(action: { sortOrder = .category }) {
                Label("카테고리순", systemImage: "folder")
            }
        } label: {
            Label("정렬", systemImage: "arrow.up.arrow.down")
                .labelStyle(IconOnlyLabelStyle())
        }
        .padding(.leading)
    }
    
    var addButton: some View {
        Button(action: {
            showAddItemView.toggle()
        }) {
            Image(systemName: "plus")
        }
    }
    
    func itemCard(for item: Item) -> some View {
        VStack(spacing: 10) {
            if let image = UIImage(named: item.imageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            }
            HStack {
                Text(item.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            
            }
            Text("D-\(daysUntilExpiry(expiryDate: item.expiryDate))")
                .font(.caption)
                .foregroundColor(daysUntilExpiry(expiryDate: item.expiryDate) <= 3 ? .red : .primary)
        }
        .padding()
        .background(
            Color(UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? .systemGray4 : .white
            })
        )
        .cornerRadius(15)
        .contextMenu {
            Button(action: {
                selectedItem = item
                showEditItemView = true
            }) {
                Text("수정하기")
                Image(systemName: "pencil")
            }
            Button(action: {
                itemToDelete = item
                showDeleteAlert = true
            }) {
                Text("삭제하기")
                Image(systemName: "trash")
            }
        }
    }
    
    var groupedCategories: [String] {
        Array(groupedItems.keys).sorted()
    }
    
    var groupedItems: [String: [Item]] {
        Dictionary(grouping: filteredItems(), by: { $0.category })
    }
    
    func filteredItems() -> [Item] {
        let items = itemManager.groupedItems[selectedStorage] ?? []
        return items.filter { item in
            searchText.isEmpty || item.name.contains(searchText)
        }.sorted(by: sortOrder)
    }
    
    func filteredItems(for category: String) -> [Item] {
        groupedItems[category] ?? []
    }
    
    func daysUntilExpiry(expiryDate: Date) -> Int {
        let calendar = Calendar.current
        let currentDate = Date()
        let components = calendar.dateComponents([.day], from: currentDate, to: expiryDate)
        return components.day ?? 0
    }
    
    func expiryDateText(expiryDate: Date) -> String {
        let days = daysUntilExpiry(expiryDate: expiryDate)
        if days >= 0 {
            return "D-\(days)"
        } else {
            return "D+\(-days)"
        }
    }
    
    func deleteItem(item: Item) {
        if let index = itemManager.items.firstIndex(where: { $0.id == item.id }) {
            itemManager.items.remove(at: index)
            itemManager.saveItems()
        }
    }
}

extension Array where Element == Item {
    func sorted(by sortOrder: SortOrder) -> [Item] {
        switch sortOrder {
        case .name:
            return self.sorted { $0.name < $1.name }
        case .expiryDate:
            return self.sorted { $0.expiryDate < $1.expiryDate }
        case .category:
            return self.sorted { $0.category < $1.category }
        }
    }
}

private let itemDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()
