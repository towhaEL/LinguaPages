import re

with open('design/design.md', 'r') as f:
    design_spec = f.read()

with open('design/ui_generation_plan.md', 'r') as f:
    plan = f.read()

# Define key features from design.md to verify presence in ui_generation_plan.md
features_to_check = {
    "Shared Style Block": [
        "LinguaPages", "412×915", "Material 3", "warm ivory", "#FAF7F2", "#FFFFFF",
        "#E8E2D9", "#1C1B1A", "#6B655D", "#2F4A7A", "Newsreader", "Inter", "16px",
        "pill chips", "20px", "1.5px"
    ],
    "1. Onboarding": [
        "Your books, all in one place", "EPUB, PDF, TXT, Markdown, HTML and FB2",
        "Read the way you like", "Listen when your eyes rest",
        "Private by design", "Skip", "Next", "Import your first book", "Explore first"
    ],
    "2. Library": [
        "Continue reading", "Resume", "Recent", "Filter", "Collections", "+ Import", "3-column grid"
    ],
    "2b. Empty library": [
        "empty shelf", "Import files", "Import a folder", "Your library is empty"
    ],
    "2c. Filter and sort sheet": [
        "Sort by", "Recently read", "Title", "Author", "Date added", "Progress",
        "Format", "EPUB", "PDF", "TXT", "Markdown", "HTML", "FB2",
        "Authors", "Series", "Collections", "Trash", "Reset", "Apply", "grid/list"
    ],
    "2d. Book details sheet": [
        "The Expanse", "Book 2", "Read", "Add to collection", "Edit details", "Share", "Move to Trash"
    ],
    "3. Settings": [
        "Appearance", "Theme", "Light", "Dark", "System", "App text size",
        "Reading defaults", "Page turning", "Keep screen on", "Orientation lock",
        "Read aloud", "Default voice", "Speed", "Skip page numbers",
        "Library", "Auto-mark finished", "Trash auto-empty", "30 days",
        "Backup", "Restore", "Unlock 12 themes and 8 fonts", "Dictionary credits",
        "Wiktionary", "CC BY-SA 3.0", "Open-source licences", "Version"
    ],
    "4. Reader": [
        "The Harbour", "Paper", "#F6F1E7", "back arrow", "bookmark",
        "Page 142 of 380", "12 min left", "slider", "Contents", "Appearance", "Listen", "Notes",
        "vertical brightness indicator", "142 / 380"
    ],
    "4b. Appearance sheet": [
        "Paper", "White", "Sepia", "Grey", "Night", "Black", "lock",
        "font picker", "Aa", "Size", "Line spacing", "Margins", "A−/A+",
        "Justify", "Hyphenation", "Publisher styles", "Scroll", "Pages", "Two columns",
        "Brightness", "Follow system"
    ],
    "4c. Text selection & dictionary": [
        "littoral", "Highlight", "5 colour", "Note", "Define", "Copy", "Share",
        "Search the web", "Send to app", "/ˈlɪt(ə)rəl/", "speaker icon",
        "adjective", "noun", "Wiktionary", "CC BY-SA 3.0"
    ],
    "4d. Contents & annotations": [
        "Contents", "Bookmarks", "Highlights", "nested chapter list",
        "Export as Markdown", "colour strip", "note preview"
    ],
    "4e. Search in book": [
        "harbour", "23 results", "bold ink blue", "Up/down arrows"
    ],
    "5. Read aloud player variants": [
        "soft ink-blue highlight band", "auto-scrolls", "mini player", "rounded 20px",
        "tall bottom sheet", "current sentence", "faded above and below", "Speed", "1.25×",
        "English (UK) · Offline", "Sleep timer", "15, 30, 60 min", "End of chapter", "Off"
    ],
    "6. Lock-screen controls": [
        "Android 15", "blurred book", "9:41", "Material You", "Chapter Seven",
        "The Salt Path", "LinguaPages", "seek bar", "Sleep 30m", "collapsed"
    ],
    "7. Premium appearance": [
        "close X", "Linen", "Midnight Blue", "Forest", "Make every page yours",
        "12 reading themes", "8 book fonts", "stay free", "Lifetime", "Yearly",
        "Restore purchase"
    ],
    "8. All annotations": [
        "Annotations", "search", "grouped by book", "quoted text", "colour strip",
        "Export as Markdown"
    ]
}

print("=== Cross-Reference Verification ===")
all_passed = True
for section, tokens in features_to_check.items():
    missing = []
    for token in tokens:
        # Check case-insensitively
        pattern = re.compile(re.escape(token), re.IGNORECASE)
        if not pattern.search(plan):
            missing.append(token)
    if missing:
        print(f"[FAIL] {section} missing tokens: {missing}")
        all_passed = False
    else:
        print(f"[PASS] {section}: All {len(tokens)} key tokens verified.")

print(f"Overall Feature Check: {'ALL PASSED' if all_passed else 'FAILURES FOUND'}")
