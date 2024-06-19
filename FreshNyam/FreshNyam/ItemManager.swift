import Foundation
import UserNotifications

class ItemManager: ObservableObject {
    @Published var items: [Item] = []
    @Published var categories: [String] = ["과일", "채소", "유제품", "고기", "해산물", "음료", "기타"]
    @Published var images: [String: [String]] = [:]
    @Published var viewMode: ViewMode = .grid {
        didSet {
            saveViewMode()
        }
    }
    private let itemsKey = "items"
    private let categoriesKey = "categories"
    private let imagesKey = "images"
    private let viewModeKey = "viewMode"
    
    init() {
        loadItems()
        loadCategories()
        loadImages()
        loadViewMode()
    }
    
    //알림
    func scheduleNotification(for item: Item) {
        let content = UNMutableNotificationContent()
        content.title = "소비기한 알림"
        content.body = "\(item.name)의 소비기한이 다가오고 있습니다."
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                          from: item.expiryDate.addingTimeInterval(-86400)) //1일 전 알림
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 등록 실패: \(error.localizedDescription)")
            } else {
                print("알림 등록 성공: \(item.name) - \(triggerDate)")
            }
        }
    }
    
    func removeNotification(for item: Item) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
    }
    
    //아이템 내보내기 -> JSON
    func exportItems(withFileName fileName: String? = nil) -> URL? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(items)
            let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let dateString = dateFormatter.string(from: Date())
            let defaultFileName = "items_\(dateString).json"
            let exportFileName = fileName ?? defaultFileName
            let fileURL = temporaryDirectoryURL.appendingPathComponent(exportFileName)
            
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to export items: \(error.localizedDescription)")
            return nil
        }
    }
    
    func importItems(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let importedItems = try decoder.decode([Item].self, from: data)
            self.items = importedItems
            saveItems()
        } catch {
            print("Failed to import items: \(error.localizedDescription)")
        }
    }

    func addItem(name: String, category: String, storage: StorageType, expiryDate: Date, imageName: String = "") {
        let newItem = Item(name: name, category: category, storage: storage, expiryDate: expiryDate, addedDate: Date(), imageName: imageName)
        items.append(newItem)
        saveItems()
        scheduleNotification(for: newItem)
    }

    func deleteItem(at offsets: IndexSet) {
        offsets.forEach { index in
            let item = items[index]
            removeNotification(for: item)
        }
        items.remove(atOffsets: offsets)
        saveItems()
    }
    
    func updateItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveItems()
            scheduleNotification(for: item)
        }
    }
    
    //카테고리 이동 및 삭제
    func addCategory(_ category: String) {
        categories.append(category)
        saveCategories()
    }

    func deleteCategory(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
        saveCategories()
    }

    func updateCategory(oldCategory: String, newCategory: String) {
        if let index = categories.firstIndex(of: oldCategory) {
            categories[index] = newCategory
            saveCategories()
        }
    }

    func moveCategory(from source: IndexSet, to destination: Int) {
        categories.move(fromOffsets: source, toOffset: destination)
        saveCategories()
    }
    
    internal func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }

    private func loadItems() {
        if let savedItems = UserDefaults.standard.data(forKey: itemsKey),
           let decodedItems = try? JSONDecoder().decode([Item].self, from: savedItems) {
            items = decodedItems
        }
    }

    //카테고리 저장
    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: categoriesKey)
        }
    }

    private func loadCategories() {
        if let savedCategories = UserDefaults.standard.data(forKey: categoriesKey),
           let decodedCategories = try? JSONDecoder().decode([String].self, from: savedCategories) {
            categories = decodedCategories
        }
    }

    private func saveImages() {
        if let encoded = try? JSONEncoder().encode(images) {
            UserDefaults.standard.set(encoded, forKey: imagesKey)
        }
    }
    
    //이미지 Asset에 저장되어있는거 불러오기(파일명으로 불러와야함)
    private func loadImages() {
        images = [
            "간식": ["감자칩","곰젤리","과자", "과자류", "나초","마시멜로우", "사탕", "사탕 2","젤리","초콜릿","초콜릿2", "크래커", "팝콘"],
            "고기": ["고기 1", "고기", "닭", "닭가슴살", "베이컨", "소세지 1", "소세지","티본스테이크","프로슈토", "햄"],
            "곡물, 견과류": ["땅콩", "마카다미아", "밀가루 1", "밀가루 2", "밀가루","밥", "아몬드", "피스타치오", "호두"],
            "과일": ["감", "딸기", "레몬", "망고", "무화과", "복숭아", "블루베리", "사과", "살구", "석류", "손질한 수박","수박", "오렌지", "자몽", "체리", "키위","파인애플", "포도","청포도", "파인애플"],
            "냉동식품": ["감자튀김 1", "감자튀김 2", "감자튀김", "아이스크림 1", "아이스크림 2","아이스크림 3","아이스크림 4","아이스크림 5","치즈스틱", "컵아이스크림", "콘아이스크림"],
            "면류": ["라면","뇨끼","라비올리","리가토니","스파게티","파르팔레" ],
            "빈려동물":["강아지 간식","반려동물 음식", "고양이 밥" ,"고양이모래","애완동물 사료"],
            "빵": ["도넛2", "무스케이크", "빵 1", "빵 2", "빵", "샌드위치 1", "샌드위치", "식빵", "진저브레드맨", "케이크 1", "케이크", "크루아상", "조각 케이크", "케이크2", "토르티아", "티라미수", "호밀빵"],
            "소스": ["고추장", "꿀 1",  "꿀", "마요네즈", "머스타드", "사과잼", "소스 1", "소스", "시럽 1", "시럽", "식초", "일회용 소스", "잼 1", "잼", "칠리소스", "피넛버터"],
            "약": ["알약", "약 1", "약","비타민C"],
            "유제품": ["달걀 1", "달걀 2",  "버터","부라타 치즈","요거트", "우유 1", "우유 2", "우유 3", "우유", "치즈","휘핑크림"],
            "음료": ["라떼", "말차", "맥주", "물",  "샴페인", "소다", "소주", "수박주스", "식혜", "아몬드밀크", "에너지드링크", "오렌지주스", "와인 1", "와인", "우린 차", "원두", "카페 음료", "캡슐커피", "콜라", "탄산수", "티백 1", "티백", "프로틴음료", "핫초코","캔 음료",],
            "음식": ["계란말이 1", "계란말이", "계란후라이", "김밥", "김치 1", "김치", "달걀", "도넛", "떡볶이", "만두", "보쌈", "부리또", "삼계탕", "비빔밥", "삼각김밥", "샐러드", "샐러드 2", "송편(떡)", "에너지바", "오무라이스", "찌개류", "초밥 1", "초밥 2", "초밥 3", "초밥 4", "초밥 5", "초밥 6", "치킨", "카레", "콩국수", "타코", "타코야끼", "튀김", "팬케이크", "피자 1", "피자", "핫도그 1", "핫도그", "햄버거", "호박죽"],
            "채소": ["가지", "감자", "감자2", "고수", "고추", "고추2", "근대", "당근 1", "당근", "딜", "두부", "마늘 1", "마늘", "무", "민트", "바질", "방울토마토", "배추", "버섯 1", "버섯", "브로콜리", "상추","샐러리", "순무", "시금치", "아보카도", "아스파라거스", "애호박", "양배추", "양파", "엔다이브", "오이 1", "오이", "옥수수", "적양배추", "케일", "콜리플라워", "콩", "토마토", "파 1", "파", "파프리카", "팥", "파슬리", "호박"],
            "통조림": ["캔","캔 1", "캔 생선",],
            "해산물": ["게", "새우","생선 1", "생선","소라", "손질된 생선", "어묵","연어","연어2", "오징어", "장어", "조개", "회","회2"],
            "향신료,조미료": ["고추냉이", "시나몬","시나몬 1",  "바닐라","발사믹 식초", "오일","올리브오일",  "조리유", "조미료", "코코넛오일",  "msg", "식용색소", ]
        ]
    }
    
    internal func saveViewMode() {
        UserDefaults.standard.set(viewMode.rawValue, forKey: viewModeKey)
    }
    
    private func loadViewMode() {
        if let savedViewMode = UserDefaults.standard.string(forKey: viewModeKey),
           let decodedViewMode = ViewMode(rawValue: savedViewMode) {
            viewMode = decodedViewMode
        }
    }

    var groupedItems: [StorageType: [Item]] {
        Dictionary(grouping: items, by: { $0.storage })
    }

    func sortedItems(by sortOrder: SortOrder) -> [Item] {
        switch sortOrder {
        case .name:
            return items.sorted { $0.name < $1.name }
        case .expiryDate:
            return items.sorted { $0.expiryDate < $1.expiryDate }
        case .category:
            return items.sorted { $0.category < $1.category }
        }
    }
}

enum StorageType: String, Codable, CaseIterable {
    case fridge = "냉장실"
    case freezer = "냉동실"
    case roomTemp = "실온보관"
}

enum ViewMode: String, Codable, CaseIterable {
    case grid = "그리드뷰"
    case list = "리스트뷰"
}

enum SortOrder {
    case name
    case expiryDate
    case category
}
