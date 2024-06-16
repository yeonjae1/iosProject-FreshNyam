import Foundation

class Item: ObservableObject, Identifiable, Codable {
    var id: UUID
    @Published var name: String
    @Published var category: String
    @Published var storage: StorageType
    @Published var expiryDate: Date
    @Published var addedDate: Date
    var imageName: String
    
    init(id: UUID = UUID(), name: String, category: String, storage: StorageType, expiryDate: Date, addedDate: Date, imageName: String = "") {
        self.id = id
        self.name = name
        self.category = category
        self.storage = storage
        self.expiryDate = expiryDate
        self.addedDate = addedDate
        self.imageName = imageName
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, storage, expiryDate, addedDate, imageName
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        storage = try container.decode(StorageType.self, forKey: .storage)
        expiryDate = try container.decode(Date.self, forKey: .expiryDate)
        addedDate = try container.decode(Date.self, forKey: .addedDate)
        imageName = try container.decode(String.self, forKey: .imageName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(storage, forKey: .storage)
        try container.encode(expiryDate, forKey: .expiryDate)
        try container.encode(addedDate, forKey: .addedDate)
        try container.encode(imageName, forKey: .imageName)
    }
}
