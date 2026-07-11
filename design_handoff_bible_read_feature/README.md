# Handoff: 성경 암송 앱 — Read 탭 신규 기능 3종

## Overview
"성경 암송" 앱에 추가되는 4번째 탭 **Read**(성경 읽기)와 그에 딸린 3개 신규 화면(책/장 선택 시트, 북마크 목록, 단어·인물 검색)의 디자인입니다. 기존 앱의 "Quiet Parchment" 디자인 시스템(파치먼트 배경 + 테라코타 포인트 + 세리프 타이포)을 그대로 확장했습니다.

## About the Design Files
이 폴더의 `Bible Read Feature.dc.html`은 **HTML로 만든 디자인 레퍼런스(인터랙티브 프로토타입)**이며, 프로덕션 코드가 아닙니다. 브라우저에서 열면 실제로 탭 전환, 시트 열기/닫기, 북마크 추가/삭제, 검색 결과 이동까지 클릭으로 동작합니다. 목표는 이 HTML을 그대로 이식하는 것이 아니라, **기존 SwiftUI 코드베이스의 패턴(NavigationView, TabView, sheet, List 등)을 사용해 동일한 결과물을 재구현**하는 것입니다.

## Fidelity
**High-fidelity.** 색상, 타이포그래피, 간격, radius, 인터랙션 모두 확정 값으로 명시되어 있습니다. 아래 스펙대로 픽셀 단위로 재현해주세요.

## Design Tokens

### Colors
- `parchment` (배경): `#F7F2ED`
- `terracotta` (포인트/선택색): `#B4682D`
- `cardSurface` (카드 배경): `#FFFFFF`
- `darkSurface` (주요 텍스트, 거의 검정): `#1C1917`
- `mutedBrown` (보조 텍스트/아이콘): `#8C7A6B`
- `divider` (구분선): `rgba(140,122,107,0.18)` (더 옅은 리스트 구분선은 `rgba(140,122,107,0.14)`)
- `terracottaTint` (뱃지/버튼 배경): `rgba(180,104,45,0.10)`
- `segmentTrackBg` (세그먼트 피커 트랙): `rgba(140,122,107,0.12)`
- `deleteRed` (스와이프 삭제 배경): `#B4432D`
- `toastBg`: `#1C1917` / `toastText`: `#F7F2ED`
- 하이라이트(검색/북마크에서 이동 시 절 강조): `rgba(180,104,45,0.14)`

### Typography
- 폰트: 세리프. 프로토타입에서는 Google Fonts **Lora**(400/500/600/700)를 사용. SwiftUI 구현 시 New York(SF Serif) 또는 동일 계열 세리프로 대체 권장.
- 대제목(화면 타이틀, 예: "북마크", "단어·인물 검색"): 22px / weight 700 / `#1C1917`
- 장 레퍼런스 헤더(예: "요한복음 3장"): 22px / weight 700 / `#1C1917`
- 절 본문 텍스트: 18px / weight 400 / line-height 1.65 / `#1C1917`
- 절 번호: 12px / weight 700 / `#B4682D`
- 세그먼트 피커 라벨: 14px / 선택 시 weight 600 `#B4682D`, 비선택 weight 500 `#8C7A6B`
- 섹션 헤더(구약/신약 등): 12px / weight 600 / letter-spacing 0.06em / `#8C7A6B`, uppercase 느낌(한글은 그대로)
- 리스트 행 타이틀(책 이름, 북마크 reference): 16–17px / weight 500–600 / `#1C1917`
- 보조 텍스트(날짜, 힌트): 13px / weight 400–500 / `#8C7A6B`
- 뱃지(번역본): 11px / weight 600 / `#B4682D` on `rgba(180,104,45,0.10)`
- 버튼 라벨(검색, 이전/다음 장): 15–16px / weight 600
- 하단 탭 라벨: 10px / weight 600

### Spacing / Radius / Shadow
- 카드(구절 카드, 북마크 행, 검색 결과 카드): radius **16px**, shadow `0 2px 8px rgba(0,0,0,0.07)`
- 작은 pill/뱃지 radius: 20px (완전 라운드)
- 버튼/입력창 radius: 10px
- 챕터 그리드 셀 radius: 10px
- 시트(bottom sheet) 상단 radius: 20px 20px 0 0
- 화면 좌우 여백: 16–20px
- 헤더 내부 요소 간 gap: 12px
- 리스트 행 padding: 13–16px 수직, 16–20px 수평
- 탭바 아이콘-라벨 gap: 3px, 탭바 하단 padding 22px(홈 인디케이터 여백)

## Screens / Views

### 1. Read 탭 — 성경 읽기 (기본 화면)
**Purpose:** 사용자가 책/장/번역본을 선택해 본문을 세로로 읽는다.

**Layout (위→아래, 세로 flex):**
- **헤더 (고정, 배경 parchment, 하단 divider)**
  - Row 1: 좌측 "책 이름 N장" 텍스트 버튼(22px/700, 우측에 작은 셰브론 다운 아이콘, 탭 시 책/장 선택 시트 오픈) + 우측 아이콘 2개(북마크 목록 아이콘, 검색 아이콘 — 각 36×36 원형 버튼, 배경 `rgba(140,122,107,0.1)`)
  - Row 2: 번역본 세그먼트 피커(개역한글/NIV/Message), 트랙 배경 `rgba(140,122,107,0.12)` radius 10, padding 3px, 선택된 세그먼트는 흰 배경 pill + `0 1px 4px rgba(0,0,0,0.1)` shadow
  - Row 3: "이 장 책갈피에 추가" 텍스트 버튼(13px/600, 테라코타, 좌측 북마크 아이콘)
- **본문 (스크롤 영역, flex:1)**: 절 목록. 각 절은 **인라인 행**(카드 아님) — 절번호(폭 22px, 12px/700 테라코타) + 본문(18px/400, line-height 1.65, darkSurface). 탭 또는 480ms 길게 누르면 해당 행 아래에 "책갈피 추가" / "취소" 인라인 액션 노출. 북마크·검색에서 진입 시 해당 절 배경이 `rgba(180,104,45,0.14)`로 하이라이트되었다가 2.5초 후 자동 해제.
- **하단 이전/다음 장 바 (고정, 상단 divider)**: 좌측 "‹ 이전 장", 가운데 "책이름 현재장 / 전체장" (13px, muted), 우측 "다음 장 ›". 첫/마지막 장에서는 opacity 0.3으로 비활성 표시(탭은 막힘).
- **하단 탭바**: Home / Practice / Library / Read 4탭, 각 24px 내외 라인 아이콘 + 10px/600 라벨. 선택색 테라코타, 비선택 mutedBrown. 탭 전환 시 Read 탭 내부 화면은 항상 'main'으로 리셋.

**Content 예시:** 헤더 "요한복음 3장", 절 1~9까지 표시.

### 2. 책/장 선택 시트 (바텀시트, 2단계)
**Purpose:** 읽을 책과 장을 고른다.

**공통:** 화면 하단에서 올라오는 시트, 배경 `#F7F2ED`, 상단 radius 20, 상단에 36×5px 드래그 핸들바(`rgba(140,122,107,0.3)`), 뒤 배경 딤(`rgba(28,25,23,0.45)`) 탭 시 닫힘.

**Step 1 — 책 선택:**
- 헤더: 가운데 "책 선택"(17px/700), 우측 X 닫기 버튼
- 검색바: 흰 배경 카드, radius 10, 돋보기 아이콘 + placeholder "책 이름 검색"
- 리스트: "구약"/"신약" 섹션 헤더 + 책 이름 행(52px 높이, 16px, 우측 셰브론, 하단 구분선). 검색어로 실시간 필터링.
- 책 탭 → Step 2로 전환

**Step 2 — 장 선택:**
- 헤더: 좌측 뒤로가기 셰브론(Step1로), 가운데 "{책이름} · 장 선택", 우측 X 닫기
- 5열 그리드(`grid-template-columns: repeat(5,1fr)`), gap 10px, 각 셀 정사각형 radius 10. 현재 읽고 있는 장(선택된 책과 일치 시)은 테라코타 배경 + 흰 텍스트 + shadow `0 2px 6px rgba(180,104,45,0.3)`, 그 외는 흰 배경 + darkSurface 텍스트 + 옅은 shadow.
- 장 번호 탭 → 시트 닫히고 Read 화면이 해당 책/장으로 갱신.

### 3. 북마크 목록 화면 (Read 탭 내 push)
**Purpose:** 저장된 북마크를 보고, 탭하면 해당 위치로 이동하거나 스와이프로 삭제한다.

**Layout:**
- 헤더: 좌측 back 셰브론(Read 메인으로 복귀) + "북마크"(22px/700)
- 리스트: 각 행은 흰 카드(radius 16, shadow `0 2px 8px rgba(0,0,0,0.07)`), 내부에 reference(17px/600, 예: "요한복음 3:16" 또는 절 없이 "전체장" 저장 시 "요한복음 3장"), 번역본 뱃지(11px/600 테라코타, 배경 tint, radius 20 pill), 저장 날짜("YYYY.MM.DD 저장", 13px muted), 우측 셰브론.
- **스와이프 삭제:** 행을 탭하면 카드가 왼쪽으로 72px 슬라이드(`transform: translateX(-72px)`, transition 0.25s ease)되며 뒤에 있던 빨간 삭제 버튼(`#B4432D`, 폭 72px, "삭제" 흰 텍스트)이 드러남. 실제 구현에서는 좌측 스와이프 제스처(SwiftUI `.swipeActions`)로 대체.
- 빈 상태: "아직 저장된 책갈피가 없어요" (15px, muted, 중앙 정렬, 상하 padding 60px)
- 행 탭(스와이프 상태 아닐 때) → Read 탭·해당 책/장으로 이동, 절이 있으면 하이라이트.

### 4. 단어·인물 검색 화면 (Read 탭 내 push)
**Purpose:** 키워드로 성경 본문을 검색하고 결과에서 바로 이동한다.

**Layout:**
- 헤더: back 셰브론 + "단어·인물 검색"(22px/700)
- 입력 영역(고정, 하단 divider):
  - 검색창: 흰 카드 radius 10, 돋보기 아이콘 + placeholder "예: 사랑, 다윗, 믿음"
  - 번역본 세그먼트 피커(개역한글/NIV/Message) — Read 헤더와 동일 스타일
  - "검색" 버튼: 테라코타 배경 풀폭, radius 10, 흰 텍스트 16px/600
- 결과 리스트(스크롤): 각 결과는 흰 카드(radius 16, shadow 동일), reference + 번역본 뱃지 상단, 얇은 구분선(`rgba(140,122,107,0.2)`), 본문 스니펫(15px/400, `#4A4038`) 하단.
- 상태: 검색 전 "검색어를 입력하고 검색 버튼을 눌러보세요", 결과 없음 "'{검색어}'에 대한 결과가 없어요" (둘 다 15px muted 중앙정렬).
- 결과 카드 탭 → Read 탭·해당 절로 이동 + 하이라이트, 검색에서 선택한 번역본이 Read 화면에도 반영됨.

## Interactions & Behavior Summary
- 탭바 전환: Home/Practice/Library는 기존 화면(변경 없음, 이 핸드오프 범위 아님) — Read만 신규.
- Read 헤더의 책/장 버튼 → 책/장 선택 시트 오픈 (state: `sheet = 'book' | 'chapter' | null`)
- 절 롱프레스(≈480ms) 또는 탭 → 인라인 "책갈피 추가" 액션 노출 → 추가 시 토스트("책갈피에 추가되었습니다", 2초 후 자동 사라짐)
- "이 장 책갈피에 추가" → 절 없이 챕터 전체를 참조하는 북마크 추가, 토스트 노출
- 북마크/검색 결과에서 특정 절로 이동 시 Read 화면 상태(책/장/번역본)를 갱신하고 해당 절을 2.5초간 하이라이트
- 이전/다음 장 버튼은 현재 책의 장 범위를 벗어나면 비활성(opacity 0.3, 탭 무시)

## State Management (참고용 — 실제 구현 시 앱 데이터 모델에 맞게 대체)
- `currentBook`, `currentChapter`, `translation` — 현재 읽는 위치
- `readSubScreen`: `'main' | 'bookmarks' | 'search'` — Read 탭 내 네비게이션 스택
- `sheet`: `'book' | 'chapter' | null`, `pickerBook` — 책/장 선택 시트 단계
- `bookmarks: [{ book, chapter, verse?, translation, date }]` — 영속 저장 필요 (Core Data / UserDefaults 등 기존 방식 사용)
- `verseActionTarget` — 길게 누른 절 (인라인 액션 표시용)
- `searchQuery`, `searchTranslation`, `searchResults`
- `highlightedVerse` — 이동 직후 하이라이트 대상, 타이머로 자동 해제

## Assets
아이콘은 전부 인라인 SVG 라인 아이콘(북마크, 검색, 셰브론, 홈/연습/보관함/읽기 탭 아이콘)이며 커스텀 벡터 — 실제 구현 시 SF Symbols로 대체 권장 (예: `bookmark`, `magnifyingglass`, `chevron.left/right/down`, `house`, `square.grid.2x2`, `books.vertical`, `book`).
본문 텍스트는 전부 **임시 샘플 문구**이며 실제 성경 번역 텍스트가 아님 — 실제 구현 시 앱이 보유한 번역 데이터로 교체.

## Files
- `Bible Read Feature.dc.html` — 인터랙티브 프로토타입 (브라우저에서 직접 열람 가능, 모든 화면/전환 포함)
- `screenshots/01-read-tab.png` — Read 탭 기본 화면
- `screenshots/02-book-picker.png` — 책/장 선택 시트 · Step 1 (책 선택)
- `screenshots/03-chapter-picker.png` — 책/장 선택 시트 · Step 2 (장 선택, 그리드)
- `screenshots/04-bookmarks.png` — 북마크 목록 화면
- `screenshots/05-bookmark-swipe-delete.png` — 북마크 스와이프 삭제 상태
- `screenshots/06-search-results.png` — 단어·인물 검색 결과 화면
- `screenshots/07-search-jump-highlight.png` — 검색 결과 탭 → Read 탭으로 이동
- `screenshots/08-verse-bookmark-action.png` — 절 탭/길게 누르기 → 책갈피 추가 인라인 액션
