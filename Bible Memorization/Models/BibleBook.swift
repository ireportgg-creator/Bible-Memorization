import Foundation

struct BibleBook: Identifiable, Hashable {
    let id: String         // API.Bible 북 코드 (예: "JHN")
    let korean: String
    let english: String
}

extension BibleBook {
    static let all: [BibleBook] = [
        // 구약
        BibleBook(id: "GEN", korean: "창세기",       english: "Genesis"),
        BibleBook(id: "EXO", korean: "출애굽기",     english: "Exodus"),
        BibleBook(id: "LEV", korean: "레위기",       english: "Leviticus"),
        BibleBook(id: "NUM", korean: "민수기",       english: "Numbers"),
        BibleBook(id: "DEU", korean: "신명기",       english: "Deuteronomy"),
        BibleBook(id: "JOS", korean: "여호수아",     english: "Joshua"),
        BibleBook(id: "JDG", korean: "사사기",       english: "Judges"),
        BibleBook(id: "RUT", korean: "룻기",         english: "Ruth"),
        BibleBook(id: "1SA", korean: "사무엘상",     english: "1 Samuel"),
        BibleBook(id: "2SA", korean: "사무엘하",     english: "2 Samuel"),
        BibleBook(id: "1KI", korean: "열왕기상",     english: "1 Kings"),
        BibleBook(id: "2KI", korean: "열왕기하",     english: "2 Kings"),
        BibleBook(id: "1CH", korean: "역대상",       english: "1 Chronicles"),
        BibleBook(id: "2CH", korean: "역대하",       english: "2 Chronicles"),
        BibleBook(id: "EZR", korean: "에스라",       english: "Ezra"),
        BibleBook(id: "NEH", korean: "느헤미야",     english: "Nehemiah"),
        BibleBook(id: "EST", korean: "에스더",       english: "Esther"),
        BibleBook(id: "JOB", korean: "욥기",         english: "Job"),
        BibleBook(id: "PSA", korean: "시편",         english: "Psalms"),
        BibleBook(id: "PRO", korean: "잠언",         english: "Proverbs"),
        BibleBook(id: "ECC", korean: "전도서",       english: "Ecclesiastes"),
        BibleBook(id: "SNG", korean: "아가",         english: "Song of Solomon"),
        BibleBook(id: "ISA", korean: "이사야",       english: "Isaiah"),
        BibleBook(id: "JER", korean: "예레미야",     english: "Jeremiah"),
        BibleBook(id: "LAM", korean: "예레미야애가", english: "Lamentations"),
        BibleBook(id: "EZK", korean: "에스겔",       english: "Ezekiel"),
        BibleBook(id: "DAN", korean: "다니엘",       english: "Daniel"),
        BibleBook(id: "HOS", korean: "호세아",       english: "Hosea"),
        BibleBook(id: "JOL", korean: "요엘",         english: "Joel"),
        BibleBook(id: "AMO", korean: "아모스",       english: "Amos"),
        BibleBook(id: "OBA", korean: "오바댜",       english: "Obadiah"),
        BibleBook(id: "JON", korean: "요나",         english: "Jonah"),
        BibleBook(id: "MIC", korean: "미가",         english: "Micah"),
        BibleBook(id: "NAM", korean: "나훔",         english: "Nahum"),
        BibleBook(id: "HAB", korean: "하박국",       english: "Habakkuk"),
        BibleBook(id: "ZEP", korean: "스바냐",       english: "Zephaniah"),
        BibleBook(id: "HAG", korean: "학개",         english: "Haggai"),
        BibleBook(id: "ZEC", korean: "스가랴",       english: "Zechariah"),
        BibleBook(id: "MAL", korean: "말라기",       english: "Malachi"),
        // 신약
        BibleBook(id: "MAT", korean: "마태복음",       english: "Matthew"),
        BibleBook(id: "MRK", korean: "마가복음",       english: "Mark"),
        BibleBook(id: "LUK", korean: "누가복음",       english: "Luke"),
        BibleBook(id: "JHN", korean: "요한복음",       english: "John"),
        BibleBook(id: "ACT", korean: "사도행전",       english: "Acts"),
        BibleBook(id: "ROM", korean: "로마서",         english: "Romans"),
        BibleBook(id: "1CO", korean: "고린도전서",     english: "1 Corinthians"),
        BibleBook(id: "2CO", korean: "고린도후서",     english: "2 Corinthians"),
        BibleBook(id: "GAL", korean: "갈라디아서",     english: "Galatians"),
        BibleBook(id: "EPH", korean: "에베소서",       english: "Ephesians"),
        BibleBook(id: "PHP", korean: "빌립보서",       english: "Philippians"),
        BibleBook(id: "COL", korean: "골로새서",       english: "Colossians"),
        BibleBook(id: "1TH", korean: "데살로니가전서", english: "1 Thessalonians"),
        BibleBook(id: "2TH", korean: "데살로니가후서", english: "2 Thessalonians"),
        BibleBook(id: "1TI", korean: "디모데전서",     english: "1 Timothy"),
        BibleBook(id: "2TI", korean: "디모데후서",     english: "2 Timothy"),
        BibleBook(id: "TIT", korean: "디도서",         english: "Titus"),
        BibleBook(id: "PHM", korean: "빌레몬서",       english: "Philemon"),
        BibleBook(id: "HEB", korean: "히브리서",       english: "Hebrews"),
        BibleBook(id: "JAS", korean: "야고보서",       english: "James"),
        BibleBook(id: "1PE", korean: "베드로전서",     english: "1 Peter"),
        BibleBook(id: "2PE", korean: "베드로후서",     english: "2 Peter"),
        BibleBook(id: "1JN", korean: "요한일서",       english: "1 John"),
        BibleBook(id: "2JN", korean: "요한이서",       english: "2 John"),
        BibleBook(id: "3JN", korean: "요한삼서",       english: "3 John"),
        BibleBook(id: "JUD", korean: "유다서",         english: "Jude"),
        BibleBook(id: "REV", korean: "요한계시록",     english: "Revelation"),
    ]
}

enum Translation: String, CaseIterable, Identifiable {
    case korean  = "개역한글"
    case niv     = "NIV"
    case message = "Message"

    var id: String { rawValue }

    var bibleId: String {
        switch self {
        case .korean:  return ""
        case .niv:     return APIConfig.nivBibleId
        case .message: return APIConfig.messageBibleId
        }
    }
}
