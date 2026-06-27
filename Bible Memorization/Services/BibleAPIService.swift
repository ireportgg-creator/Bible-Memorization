import Foundation

actor BibleAPIService {
    static let shared = BibleAPIService()

    private let baseURL = "https://api.scripture.api.bible/v1"

    func fetchVerse(bibleId: String, bookId: String, chapter: Int, verse: Int) async throws -> VerseData {
        guard APIConfig.apiKey != "YOUR_API_KEY_HERE" else { throw APIError.notConfigured }

        var components = URLComponents(string: "\(baseURL)/bibles/\(bibleId)/verses/\(bookId).\(chapter).\(verse)")!
        components.queryItems = [
            URLQueryItem(name: "content-type", value: "text"),
            URLQueryItem(name: "include-notes", value: "false"),
            URLQueryItem(name: "include-titles", value: "false"),
            URLQueryItem(name: "include-chapter-numbers", value: "false"),
            URLQueryItem(name: "include-verse-numbers", value: "false"),
        ]

        var request = URLRequest(url: components.url!)
        request.setValue(APIConfig.apiKey, forHTTPHeaderField: "api-key")

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(BibleAPIResponse<VerseData>.self, from: data)
        return response.data
    }
}
