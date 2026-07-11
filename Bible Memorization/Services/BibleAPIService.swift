import Foundation

actor BibleAPIService {
    static let shared = BibleAPIService()

    private let baseURL = "https://api.scripture.api.bible/v1"

    private static let verseQueryItems: [URLQueryItem] = [
        URLQueryItem(name: "content-type", value: "text"),
        URLQueryItem(name: "include-notes", value: "false"),
        URLQueryItem(name: "include-titles", value: "false"),
        URLQueryItem(name: "include-chapter-numbers", value: "false"),
        URLQueryItem(name: "include-verse-numbers", value: "false"),
    ]

    func fetchVerse(bibleId: String, bookId: String, chapter: Int, verse: Int) async throws -> VerseData {
        let path = "/bibles/\(bibleId)/verses/\(bookId).\(chapter).\(verse)"
        return try await fetch(path: path, queryItems: Self.verseQueryItems)
    }

    func fetchPassage(bibleId: String, bookId: String, startChapter: Int, startVerse: Int, endChapter: Int, endVerse: Int) async throws -> VerseData {
        let passageId = "\(bookId).\(startChapter).\(startVerse)-\(bookId).\(endChapter).\(endVerse)"
        let path = "/bibles/\(bibleId)/passages/\(passageId)"
        return try await fetch(path: path, queryItems: Self.verseQueryItems)
    }

    func fetchChapter(bibleId: String, chapterId: String) async throws -> ChapterContent {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "content-type", value: "text"),
            URLQueryItem(name: "include-verse-numbers", value: "true"),
            URLQueryItem(name: "include-notes", value: "false"),
            URLQueryItem(name: "include-titles", value: "false"),
            URLQueryItem(name: "include-chapter-numbers", value: "false"),
        ]
        let raw: APIChapterData = try await fetch(path: "/bibles/\(bibleId)/chapters/\(chapterId)", queryItems: queryItems)
        return Self.parseChapterContent(raw)
    }

    func search(bibleId: String, query: String, limit: Int = 50) async throws -> [SearchResultItem] {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "limit", value: "\(limit)"),
        ]
        let raw: APISearchData = try await fetch(path: "/bibles/\(bibleId)/search", queryItems: queryItems)
        return (raw.verses ?? []).map { v in
            let parts = v.id.split(separator: ".")
            let chapter = parts.count > 1 ? Int(parts[1]) ?? 0 : 0
            let verse   = parts.count > 2 ? Int(parts[2]) ?? 0 : 0
            return SearchResultItem(id: v.id, bookId: v.bookId, chapter: chapter, verse: verse, reference: v.reference, text: v.text)
        }
    }

    private func fetch<T: Decodable>(path: String, queryItems: [URLQueryItem]) async throws -> T {
        guard APIConfig.apiKey != "YOUR_API_KEY_HERE" else { throw APIError.notConfigured }

        var components = URLComponents(string: "\(baseURL)\(path)")!
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.setValue(APIConfig.apiKey, forHTTPHeaderField: "api-key")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(BibleAPIResponse<T>.self, from: data)
        return response.data
    }

    // Splits API.Bible chapter content on "[N]" or "[N-M]" verse markers (the latter appears in
    // paraphrase translations like Message, which group several verses under one marker).
    private static func parseChapterContent(_ raw: APIChapterData) -> ChapterContent {
        let content = raw.content as NSString
        let chapterNumber = Int(raw.number) ?? 0

        guard let regex = try? NSRegularExpression(pattern: "\\[(\\d+)(?:-(\\d+))?\\]") else {
            let text = (content as String).trimmingCharacters(in: .whitespacesAndNewlines)
            return ChapterContent(bookId: raw.bookId, chapterNumber: chapterNumber, reference: raw.reference,
                                   verses: [VerseLine(id: 1, number: 1, numberLabel: "1", text: text)])
        }

        let matches = regex.matches(in: content as String, range: NSRange(location: 0, length: content.length))
        guard !matches.isEmpty else {
            let text = (content as String).trimmingCharacters(in: .whitespacesAndNewlines)
            return ChapterContent(bookId: raw.bookId, chapterNumber: chapterNumber, reference: raw.reference,
                                   verses: [VerseLine(id: 1, number: 1, numberLabel: "1", text: text)])
        }

        var verses: [VerseLine] = []
        for (index, match) in matches.enumerated() {
            let startNumber = Int(content.substring(with: match.range(at: 1))) ?? (index + 1)
            let endRange = match.range(at: 2)
            let numberLabel = endRange.location != NSNotFound
                ? "\(startNumber)-\(content.substring(with: endRange))"
                : "\(startNumber)"

            let textStart = match.range.location + match.range.length
            let textEnd = index + 1 < matches.count ? matches[index + 1].range.location : content.length
            let text = content.substring(with: NSRange(location: textStart, length: textEnd - textStart))
                .trimmingCharacters(in: .whitespacesAndNewlines)

            verses.append(VerseLine(id: startNumber, number: startNumber, numberLabel: numberLabel, text: text))
        }

        return ChapterContent(bookId: raw.bookId, chapterNumber: chapterNumber, reference: raw.reference, verses: verses)
    }
}
