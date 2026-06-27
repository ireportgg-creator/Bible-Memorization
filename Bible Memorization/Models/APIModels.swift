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

    var errorDescription: String? {
        switch self {
        case .invalidURL:     return "잘못된 URL입니다."
        case .notConfigured:  return "korean_bible.json 파일이 앱 번들에 없습니다."
        case .verseNotFound:  return "해당 구절을 찾을 수 없습니다. 장/절 번호를 확인해 주세요."
        }
    }
}
