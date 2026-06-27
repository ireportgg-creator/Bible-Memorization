import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "BibleMemo")
        container.loadPersistentStores { _, error in
            if let error { fatalError("Core Data 오류: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        seedDefaultCategories()
    }

    private func seedDefaultCategories() {
        guard !UserDefaults.standard.bool(forKey: "defaultCategoriesSeeded") else { return }

        let context = container.viewContext
        let defaults = [
            "믿음", "구원", "기도", "사랑", "소망",
            "지혜", "하나님의 말씀", "위로", "용기", "감사"
        ]
        for (index, name) in defaults.enumerated() {
            let category = Category(context: context)
            category.id = UUID()
            category.name = name
            category.createdAt = Date().addingTimeInterval(TimeInterval(index))
        }
        try? context.save()
        UserDefaults.standard.set(true, forKey: "defaultCategoriesSeeded")
    }
}
