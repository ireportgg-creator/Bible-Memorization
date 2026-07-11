import Foundation

enum BibleContentService {
    static func fetchChapter(bookId: String, chapter: Int, translation: Translation) async throws -> ChapterContent {
        switch translation {
        case .korean:
            return try await KoreanBibleService.shared.fetchChapter(bookId: bookId, chapter: chapter)
        case .niv, .message:
            return try await BibleAPIService.shared.fetchChapter(bibleId: translation.bibleId, chapterId: "\(bookId).\(chapter)")
        }
    }

    static func search(query: String, translation: Translation) async throws -> [SearchResultItem] {
        switch translation {
        case .korean:
            return try await KoreanBibleService.shared.search(query: query)
        case .niv, .message:
            return try await BibleAPIService.shared.search(bibleId: translation.bibleId, query: query)
        }
    }

    static func chapterCount(bookId: String) async throws -> Int {
        try await KoreanBibleService.shared.chapterCount(bookId: bookId)
    }
}
