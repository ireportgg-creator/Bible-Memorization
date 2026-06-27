import Foundation

actor KoreanBibleService {
    static let shared = KoreanBibleService()

    private var bible: [String: [[String]]]?

    func fetchVerse(bookId: String, chapter: Int, verse: Int) throws -> VerseData {
        if bible == nil {
            guard let url = Bundle.main.url(forResource: "korean_bible", withExtension: "json") else {
                throw APIError.notConfigured
            }
            bible = try JSONDecoder().decode([String: [[String]]].self, from: Data(contentsOf: url))
        }
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
}
