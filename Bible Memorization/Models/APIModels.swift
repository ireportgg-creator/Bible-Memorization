import Foundation

struct BibleAPIResponse<T: Decodable>: Decodable {
    let data: T
}

struct VerseData: Decodable {
    let id: String
    let reference: String
    let content: String

    var cleanedContent: String {
        content
            .replacingOccurrences(of: "\u{00b6}", with: "")  // 단락 기호 제거
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case notConfigured
    case verseNotFound
    case chapterNotFound

    var errorDescription: String? {
        switch self {
        case .invalidURL:     return "잘못된 URL입니다."
        case .notConfigured:  return "korean_bible.json 파일이 앱 번들에 없습니다."
        case .verseNotFound:  return "해당 구절을 찾을 수 없습니다. 장/절 번호를 확인해 주세요."
        case .chapterNotFound: return "해당 장을 찾을 수 없습니다."
        }
    }
}

// MARK: - Chapter reading

struct VerseLine: Identifiable {
    let id: Int
    let number: Int
    let numberLabel: String
    let text: String
}

struct ChapterContent {
    let bookId: String
    let chapterNumber: Int
    let reference: String
    let verses: [VerseLine]
}

struct APIChapterData: Decodable {
    let id: String
    let bibleId: String
    let number: String
    let bookId: String
    let reference: String
    let content: String
}

// MARK: - Search

struct SearchResultItem: Identifiable {
    let id: String
    let bookId: String
    let chapter: Int
    let verse: Int
    let reference: String
    let text: String
}

struct APISearchData: Decodable {
    let query: String
    let total: Int?
    let verses: [APISearchVerse]?
}

struct APISearchVerse: Decodable {
    let id: String
    let bookId: String
    let chapterId: String
    let reference: String
    let text: String
}
