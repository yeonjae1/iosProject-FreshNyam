import SwiftUI

struct SettingsView: View {
    @ObservedObject var itemManager: ItemManager
    @State private var newCategory = ""
    @AppStorage("appAppearance") var appAppearance: AppAppearance = .system

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("카테고리 목록")) {
                    List {
                        ForEach(itemManager.categories, id: \.self) { category in
                            Text(category)
                        }
                        .onDelete(perform: deleteCategory) //카테고리 삭제
                        .onMove(perform: moveCategory)  // 카테고리 순서 변경
                    }
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
                Section(header: Text("보기 설정")) {
                    Picker("모드 선택", selection: $appAppearance) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.rawValue).tag(appearance)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationBarTitle("설정", displayMode: .inline)
            //.navigationBarItems(trailing: EditButton())
        }
    }

    private func deleteCategory(at offsets: IndexSet) {
        itemManager.deleteCategory(at: offsets)
    }

    private func moveCategory(from source: IndexSet, to destination: Int) {
        itemManager.moveCategory(from: source, to: destination)
    }
}
