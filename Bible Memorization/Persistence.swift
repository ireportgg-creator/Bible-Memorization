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
    }
}
