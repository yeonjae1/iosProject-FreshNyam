import SwiftUI

struct ImagePickerView: View {
    @Binding var selectedImageName: String
    var images: [String: [String]]
    @Binding var searchQuery: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                TextField("검색", text: $searchQuery)
                    .padding(10)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                ScrollView {
                    ForEach(images.keys.sorted(), id: \.self) { category in
                        Section(header: Text(category)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 15)
                                    .frame(maxWidth: .infinity, alignment: .leading)) {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                                ForEach(images[category]!, id: \.self) { imageName in
                                    VStack {
                                        Image(imageName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 50)
                                            .padding()
                                            .background(self.selectedImageName == imageName ? Color.primary.opacity(0.15) : Color.clear)
                                            .cornerRadius(8)
                                            .onTapGesture {
                                                self.selectedImageName = imageName
                                        
                                            }
                                        Text(imageName)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                        }
                    }
                    .padding()
                }
                .navigationBarTitle("아이콘 선택", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("취소")
                    },
                    trailing: Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("확인")
                    }
                )
            }
        }
    }
}
