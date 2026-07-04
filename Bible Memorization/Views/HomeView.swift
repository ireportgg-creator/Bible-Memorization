import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .none
    ) private var categories: FetchedResults<Category>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SavedVerse.savedAt, ascending: false)],
        predicate: NSPredicate(format: "translation == %@", "개역한글"),
        animation: .none
    ) private var koreanVerses: FetchedResults<SavedVerse>

    private var verseOfTheDay: SavedVerse? {
        guard !koreanVerses.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return koreanVerses[day % koreanVerses.count]
    }

    private var memorizedCount: Int { koreanVerses.filter { $0.isMemorized }.count }
    private var totalCount: Int { koreanVerses.count }

    private var continueCategory: Category? {
        categories.first { cat in
            let verses = cat.verses as? Set<SavedVerse> ?? []
            return verses.contains { !$0.isMemorized && $0.translation == "개역한글" }
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 18 { return "Good afternoon" }
        return "Good evening"
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        f.locale = Locale(identifier: "en_US")
        return f.string(from: Date()).uppercased()
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formattedDate)
                            .font(.caption).fontWeight(.semibold)
                            .tracking(1).foregroundColor(.mutedBrown)
                        Text(greeting)
                            .font(.largeTitle).fontWeight(.bold)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // Verse of the Day
                    if let verse = verseOfTheDay {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("VERSE OF THE DAY")
                                .font(.caption).fontWeight(.semibold)
                                .tracking(1.5).foregroundColor(.terracotta)
                            Text("\u{201C}\(verse.text ?? "")\u{201D}")
                                .font(.body).lineSpacing(6)
                            Text(verse.reference ?? "")
                                .font(.callout).foregroundColor(.mutedBrown)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .cardStyle()
                        .padding(.horizontal)
                    } else if !categories.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "book.closed")
                                .font(.title2).foregroundColor(.mutedBrown)
                            Text("저장된 말씀이 없습니다")
                                .font(.callout).foregroundColor(.mutedBrown)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(28)
                        .cardStyle()
                        .padding(.horizontal)
                    }

                    // Continue Practicing
                    if let cat = continueCategory {
                        ContinuePracticingCard(category: cat)
                            .padding(.horizontal)
                    }

                    // Stats
                    if totalCount > 0 {
                        HStack(spacing: 12) {
                            StatCard(value: "\(memorizedCount)", label: "Verses mastered")
                            StatCard(value: "\(totalCount)", label: "Total saved")
                        }
                        .padding(.horizontal)
                    }

                    // Collections
                    if !categories.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your collections")
                                .font(.headline).padding(.horizontal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(categories) { cat in
                                        HomeCollectionCard(category: cat)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    Color.clear.frame(height: 16)
                }
            }
            .parchmentBackground()
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Sub-components

private struct ContinuePracticingCard: View {
    let category: Category
    @FetchRequest private var verses: FetchedResults<SavedVerse>

    init(category: Category) {
        self.category = category
        _verses = FetchRequest<SavedVerse>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "category == %@ AND translation == %@", category, "개역한글"),
            animation: .none
        )
    }

    private var memorized: Int { verses.filter { $0.isMemorized }.count }
    private var progress: Double { verses.isEmpty ? 0 : Double(memorized) / Double(verses.count) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CONTINUE PRACTICING")
                .font(.caption).fontWeight(.semibold)
                .tracking(1.5).foregroundColor(.white.opacity(0.6))
            Text(category.name ?? "")
                .font(.title3).fontWeight(.bold).foregroundColor(.white)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2)).frame(height: 4)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.terracotta)
                        .frame(width: geo.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)

            Text("\(memorized) of \(verses.count) verses memorized")
                .font(.caption).foregroundColor(.white.opacity(0.6))
        }
        .padding(20)
        .background(Color.darkSurface)
        .cornerRadius(16)
    }
}

private struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value).font(.title).fontWeight(.bold)
            Text(label).font(.caption).foregroundColor(.mutedBrown)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .cardStyle()
    }
}

private struct HomeCollectionCard: View {
    let category: Category
    @FetchRequest private var verses: FetchedResults<SavedVerse>

    init(category: Category) {
        self.category = category
        _verses = FetchRequest<SavedVerse>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "category == %@ AND translation == %@", category, "개역한글"),
            animation: .none
        )
    }

    private var progress: Double {
        verses.isEmpty ? 0 : Double(verses.filter { $0.isMemorized }.count) / Double(verses.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.name ?? "")
                .font(.subheadline).fontWeight(.semibold)
                .lineLimit(2).foregroundColor(.primary)
            Text("\(verses.count)개")
                .font(.caption).foregroundColor(.mutedBrown)
            Spacer()
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.terracotta.opacity(0.2)).frame(height: 3)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.terracotta)
                        .frame(width: geo.size.width * progress, height: 3)
                }
            }
            .frame(height: 3)
        }
        .padding(16)
        .frame(width: 150, height: 100)
        .cardStyle()
    }
}
