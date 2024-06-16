import Foundation
import UserNotifications



class ItemManager: ObservableObject {
    @Published var items: [Item] = []
    @Published var categories: [String] = ["과일", "채소", "유제품", "고기", "해산물", "음료", "기타"]
    @Published var images: [String: [String]] = [:]
    @Published var viewMode: ViewMode = .grid {
            didSet {
                saveViewModel()
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

    func scheduleNotification(for item: Item) {
        let content = UNMutableNotificationContent()
        content.title = "소비기한 알림"
        content.body = "\(item.name)의 소비기한이 다가오고 있습니다."
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                          from: item.expiryDate.addingTimeInterval(-60)) // 테스트를 위해 1분 전으로 설정
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

    
    func addItem(name: String, category: String, storage: StorageType, expiryDate: Date, imageName: String = "") {
            let newItem = Item(name: name, category: category, storage: storage, expiryDate: expiryDate, addedDate: Date(), imageName: imageName)
            items.append(newItem)
            saveItems()
            scheduleNotification(for: newItem)
        }


    func deleteItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        saveItems()
    }
    
    func updateItem(_ item: Item) {
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index] = item
                saveItems()
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
                scheduleNotification(for: item)
            }
        }
    
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
    
    
   
    private func loadImages() {
//저장된 이미지 불러오기
        images = [
            "간식": ["과자", "과자류", "나초", "사탕", "초콜릿", "크래커", "팝콘"],
            "고기": ["고기 1", "고기", "닭", "베이컨", "소세지 1", "소세지", "햄"],
            "곡물, 견과류": ["땅콩", "밀가루 1", "밀가루 2", "밀가루", "아몬드", "호두"],
            "과일": ["감", "딸기", "레몬", "망고", "무화과", "복숭아", "블루베리", "사과", "살구", "석류", "손질한 수박", "오렌지", "자몽", "체리", "키위", "포도", "파인애플"],
            "냉동식품": ["감자튀김 1", "감자튀김 2", "감자튀김", "아이스크림", "아이스크림 1", "아이스크림 3", "콘아이스크림"],
            "면류": ["라면", "반려동물 음식", ],
            "빈려동물":["강아지 간식"],
            "빵": ["무스케이크", "빵 1", "빵", "샌드위치 1", "샌드위치", "식빵", "진저브레드맨", "케이크 1", "케이크", "크루아상"],
            "소스": ["고추장", "꿀 1", "꿀", "마요네즈", "머스타드", "사과잼", "소스 1","소스", "시럽", "식초", "일회용 소스", "잼", "칠리소스"],
            "약": ["알약", "약 1", "약"],
            "유제품": ["달걀 1", "달걀 2", "달걀", "버터", "우유 1", "우유 2", "우유 3", "우유", "치즈"],
            "음료": ["라떼", "맥주", "물", "상추", "샴페인", "수박주스", "식혜", "아몬드밀크", "에너지드링크", "오렌지주스", "와인", "원두", "카페 음료", "캡슐커피", "콜라", "탄산수","말차","우린 차","티백 1", "티백", ],
            "음식": ["계란말이", "계란후라이", "김밥", "달걀", "도넛", "떡볶이", "만두", "보쌈", "삼계탕", "비빔밥", "샌드위치", "송편(떡)", "에너지바", "찌개류", "콩국수", "튀김", "팬케이크", "피자", "핫도그 1", "햄버거"],
            "채소": ["가지", "고추", "고추2", "근대", "당근 1", "당근", "딜", "마늘 1", "마늘",  "버섯 1", "버섯", "브로콜리", "샐러리", "시금치", "아보카도", "아스파라거스", "애호박", "양배추", "양파", "엔다이브", "오이", "옥수수", "적양배추", "콜리플라워", "콩", "토마토", "파", "파프리카", "팥", "호박","파슬리", "민트",],
            "통조림": ["캔", ],
            "해산물": ["게", "생선 1", "생선", "손질된 생선", "어묵", "오징어", "장어", "조개", "회"],
            "향신료,조미료": ["시나몬",  "바닐라", "오일", "조리유 1", "조리유", "조미료", "코코넛오일",  "msg", "식용색소", ]
        ]
    }
    
    internal func saveViewModel() {
          UserDefaults.standard.set(viewMode.rawValue, forKey: viewModeKey)
      }

      private func loadViewMode() {
          if let savedViewModel = UserDefaults.standard.string(forKey: viewModeKey),
             let decodedViewMode = ViewMode(rawValue: savedViewModel) {
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
