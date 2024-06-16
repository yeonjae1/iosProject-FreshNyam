import SwiftUI

struct SettingsView: View {
    @ObservedObject var itemManager: ItemManager
    @State private var newCategory = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("카테고리 목록")) {
                    ForEach(itemManager.categories, id: \.self) { category in
                        HStack {
                            Text(category)
                        }
                    }
                    .onDelete(perform: deleteCategory)
                }
                Section(header: Text("새 카테고리 추가")) {
                    HStack {
                        TextField("카테고리명", text: $newCategory)
                        Button(action: {
                            itemManager.addCategory(newCategory)
                            newCategory = ""
                        }) {
                            Text("추가")
                        }
                    }
                }
                Section(header: Text("보기 방식")) { // 추가된 부분
                    Picker("보기 방식", selection: $itemManager.viewMode) {
                        ForEach(ViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationBarTitle("설정", displayMode: .inline)
        }
    }

    private func deleteCategory(at offsets: IndexSet) {
        itemManager.deleteCategory(at: offsets)
    }
}
