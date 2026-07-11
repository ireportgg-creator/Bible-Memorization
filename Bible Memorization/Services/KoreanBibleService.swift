import Foundation

actor KoreanBibleService {
    static let shared = KoreanBibleService()

    private var bible: [String: [[String]]]?

    func fetchVerse(bookId: String, chapter: Int, verse: Int) throws -> VerseData {
        try loadBible()
        guard let chapters = bible?[bookId],
              chapter >= 1, chapter <= chapters.count,
              verse >= 1, verse <= chapters[chapter - 1].count else {
            throw APIError.verseNotFound
        }
        let bookName = BibleBook.all.first(where: { $0.id == bookId })?.korean ?? bookId
        return VerseData(
            id: "\(bookId).\(chapter).\(verse)",
            reference: "\(bookName) \(chapter):\(verse)",
            content: chapters[chapter - 1][verse - 1]
        )
    }

    func fetchVerseRange(bookId: String, startChapter: Int, startVerse: Int, endChapter: Int, endVerse: Int) throws -> VerseData {
        try loadBible()
        guard let chapters = bible?[bookId] else { throw APIError.verseNotFound }

        var texts: [String] = []
        for ch in startChapter...endChapter {
            guard ch >= 1, ch <= chapters.count else { throw APIError.verseNotFound }
            let vsStart = ch == startChapter ? startVerse : 1
            let vsEnd   = ch == endChapter   ? endVerse   : chapters[ch - 1].count
            guard vsStart >= 1, vsEnd <= chapters[ch - 1].count else { throw APIError.verseNotFound }
            for vs in vsStart...vsEnd {
                texts.append(chapters[ch - 1][vs - 1])
            }
        }

        let bookName = BibleBook.all.first(where: { $0.id == bookId })?.korean ?? bookId
        let ref = startChapter == endChapter
            ? "\(bookName) \(startChapter):\(startVerse)-\(endVerse)"
            : "\(bookName) \(startChapter):\(startVerse)-\(endChapter):\(endVerse)"

        return VerseData(
            id: "\(bookId).\(startChapter).\(startVerse)-\(bookId).\(endChapter).\(endVerse)",
            reference: ref,
            content: texts.joined(separator: " ")
        )
    }

    func fetchChapter(bookId: String, chapter: Int) throws -> ChapterContent {
        try loadBible()
        guard let chapters = bible?[bookId], chapter >= 1, chapter <= chapters.count else {
            throw APIError.chapterNotFound
        }
        let bookName = BibleBook.all.first(where: { $0.id == bookId })?.korean ?? bookId
        let verses = chapters[chapter - 1].enumerated().map { index, text in
            VerseLine(id: index + 1, number: index + 1, numberLabel: "\(index + 1)", text: text)
        }
        return ChapterContent(bookId: bookId, chapterNumber: chapter, reference: "\(bookName) \(chapter)장", verses: verses)
    }

    func chapterCount(bookId: String) throws -> Int {
        try loadBible()
        guard let chapters = bible?[bookId] else { throw APIError.chapterNotFound }
        return chapters.count
    }

    func search(query: String) throws -> [SearchResultItem] {
        try loadBible()
        guard let bible else { throw APIError.notConfigured }

        var results: [SearchResultItem] = []
        for (bookId, chapters) in bible {
            let bookName = BibleBook.all.first(where: { $0.id == bookId })?.korean ?? bookId
            for (chapterIndex, verses) in chapters.enumerated() {
                for (verseIndex, text) in verses.enumerated() where text.localizedCaseInsensitiveContains(query) {
                    let chapter = chapterIndex + 1
                    let verse = verseIndex + 1
                    results.append(SearchResultItem(
                        id: "\(bookId).\(chapter).\(verse)",
                        bookId: bookId,
                        chapter: chapter,
                        verse: verse,
                        reference: "\(bookName) \(chapter):\(verse)",
                        text: text
                    ))
                }
            }
        }

        let order = Dictionary(uniqueKeysWithValues: BibleBook.all.enumerated().map { ($1.id, $0) })
        return results.sorted {
            (order[$0.bookId] ?? 0, $0.chapter, $0.verse) < (order[$1.bookId] ?? 0, $1.chapter, $1.verse)
        }
    }

    private func loadBible() throws {
        guard bible == nil else { return }
        guard let url = Bundle.main.url(forResource: "korean_bible", withExtension: "json") else {
            throw APIError.notConfigured
        }
        bible = try JSONDecoder().decode([String: [[String]]].self, from: Data(contentsOf: url))
    }
}
