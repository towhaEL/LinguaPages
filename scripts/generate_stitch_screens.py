#!/usr/bin/env python3
"""
Sequential Stitch Screen Generator & Asset Downloader for OpenPages
"""

import os
import sys
import json
import time
import base64
import subprocess
import urllib.request

PROJECT_ID = "8671147000524611054"
OUT_DIR = "design/screens"
SHARED_STYLE = (
    "App: OpenPages, a private offline ebook reader for Android (EPUB, PDF, TXT, Markdown, HTML, FB2). "
    "Mobile 412x915, Material 3 structure with custom editorial design. Visual direction: calm, editorial-first. "
    "Background warm ivory #FAF7F2; elevated surfaces and cards #FFFFFF; hairline dividers #E8E2D9. "
    "Text ink #1C1B1A, secondary slate #6B655D. Single accent deep ink blue #2F4A7A (buttons, progress, active chips). "
    "Serif display Newsreader for headlines and titles; clean sans Inter for UI labels. Shapes: 16px card radius, "
    "pill chips, soft shadows under book covers only. Generous whitespace, 20px side margins, strictly no bottom navigation bar."
)

SCREENS = [
    {
        "id": "02_library",
        "title": "02_Library_Home",
        "prompt": (
            f"{SHARED_STYLE} Screen: 02 Library Home. "
            "Top app bar: serif title 'Library', on the right a search icon and a settings gear icon. "
            "Section 1, 'Continue reading': one large horizontal card with book cover on the left (2:3 aspect ratio, soft shadow), "
            "title in serif 'The Shadow of the Wind', author 'Carlos Ruiz Zafón', reading position 'Chapter 7 · 64%', "
            "thin deep ink blue progress bar, and a 'Resume' pill button in deep ink blue #2F4A7A. "
            "Below it, a horizontally scrolling row of 3 smaller recent-book cards with circular progress rings. "
            "Section 2: horizontally scrolling row of filter chips: All (active filled chip in #2F4A7A), Reading, To read, Finished, Favorites, Collections ▾, then a sort/filter icon button at end. "
            "Section 3: a 3-column grid of realistic varied book covers with titles (serif, max 2 lines), author names below, tiny format tag badge (EPUB, PDF, TXT), "
            "and small progress bars under covers in progress. Bottom-right floating action button: '+ Import' (extended stadium pill FAB in #2F4A7A with white text)."
        )
    },
    {
        "id": "02b_empty_library",
        "title": "02b_Empty_Library",
        "prompt": (
            f"{SHARED_STYLE} Screen: 02b Empty Library State. "
            "Top app bar: serif title 'Library', on the right search icon and settings gear icon. "
            "Center viewport features an editorial, calm empty shelf illustration with delicate line art. "
            "Serif headline: 'Your shelf is quiet', body text in slate #6B655D: 'Import a DRM-free book or a whole folder to start reading.'. "
            "Two distinct action buttons: 'Import files' (primary stadium pill button in deep ink blue #2F4A7A with white text) and "
            "'Import a folder' (outlined stadium pill button with 1.5px border in #2F4A7A). "
            "Pill badge below indicating 'Supports EPUB, PDF, TXT, Markdown, HTML, FB2 · Stored locally'."
        )
    },
    {
        "id": "02c_filter_sort_sheet",
        "title": "02c_Filter_Sort_Sheet",
        "prompt": (
            f"{SHARED_STYLE} Screen: 02c Filter and Sort Sheet. "
            "A tall modal bottom sheet with 24px top rounded corners elevated over a subtly dimmed Library background. Top centered drag handle pill. "
            "Sheet header with serif title 'Filter & Sort' and a 'Reset' text button. "
            "Section 1: 'Sort by' with radio options (Recently read, Title, Author, Date added, Progress) in clean cards with radio buttons. "
            "Section 2: 'Format' as multi-select filter chips (EPUB, PDF, TXT, Markdown, HTML, FB2) in pill shapes with selected ones active in #2F4A7A. "
            "Section 3: 'Browse by' list rows with outlined icons and counts: Authors (14), Series (4), Collections (3), All annotations (42), Trash (2). "
            "View toggle: Grid / List segmented control. Bottom sticky action bar with primary button 'Apply' in deep ink blue #2F4A7A."
        )
    },
    {
        "id": "02d_book_details",
        "title": "02d_Book_Details_Sheet",
        "prompt": (
            f"{SHARED_STYLE} Screen: 02d Book Details Sheet. "
            "A tall bottom sheet opened by long-pressing a book in the library, 24px top rounded corners, drag handle pill. "
            "Top section: large book cover on left (2:3, elegant shadow), on right: serif title 'Dune', author 'Frank Herbert', "
            "series 'Dune Chronicles · Book 1', format pill 'EPUB · 2.4 MB', date added 'Added Oct 14, 2026', reading progress 'Chapter 12 · 48%'. "
            "Action buttons row: 'Read' (primary pill button in #2F4A7A), 'Add to collection' (outlined pill), 'Edit details' (outlined pill), 'Share' icon button. "
            "Bottom section: metadata grid (publisher, language, encoding, file path) and a destructive text action at bottom 'Move to Trash' in coral red #BA1A1A."
        )
    },
    {
        "id": "03_settings",
        "title": "03_Settings",
        "prompt": (
            f"{SHARED_STYLE} Screen: 03 Settings. "
            "Top app bar with back navigation arrow and serif title 'Settings'. "
            "Grouped inset rounded cards with section headers: "
            "Group 1 'Appearance': App Theme (Light / Dark / System segmented control), App text size slider. "
            "Group 2 'Reading defaults': Default theme swatch preview, Default font (Newsreader / Inter / Literata), Page turning (tap zones, volume keys switch), Keep screen on switch. "
            "Group 3 'Read aloud': Default voice selector 'English (US) - Natural', Speed slider '1.0x', Skip page numbers switch. "
            "Group 4 'Library & Backup': Import a folder row, Auto-mark finished at 100% switch, Trash auto-empty '30 days', 'Back up now' and 'Restore backup' buttons. "
            "Group 5 'Premium banner': Highlighting card with ink blue gradient border 'Unlock 12 themes and 8 fonts' with 'Unlock' pill button in #2F4A7A. "
            "Group 6 'About': Dictionary credits (Wiktionary, CC BY-SA 3.0), Open-source licences, Version 'OpenPages v1.0.0'."
        )
    },
    {
        "id": "04_reader_chrome_visible",
        "title": "04_Reader_Chrome_Visible",
        "prompt": (
            f"{SHARED_STYLE} Screen: 04 Book Reader (Chrome Visible). "
            "Reading page fills the viewport with warm digital paper canvas #F6F1E7, elegant justified serif body text 18px (Newsreader), "
            "chapter header 'Chapter Four: The Silent Harbour'. "
            "Top chrome bar (translucent paper with subtle blur and hairline border #E8E2D9): back arrow, book title 'The Shadow of the Wind' in small serif centered, "
            "right action icons: search, bookmark outline, and overflow menu ⋮. "
            "Left screen edge: thin vertical brightness level slider indicator. "
            "Bottom chrome panel (rounded 24px top corners, translucent paper surface): "
            "chapter title 'Chapter Four', reading status 'Page 142 of 380 · 12 min left in chapter', draggable progress slider with chapter tick marks, "
            "bottom row of 4 labeled outlined icon buttons: Contents, Appearance, Listen, Notes."
        )
    },
    {
        "id": "04_reader_chrome_hidden",
        "title": "04_Reader_Chrome_Hidden",
        "prompt": (
            f"{SHARED_STYLE} Screen: 04 Book Reader (Chrome Hidden / Zen Mode). "
            "Pure, distraction-free reading view. No top bar, no bottom panel, no system bars. "
            "The screen is filled entirely with warm digital paper canvas #F6F1E7, generous 24px side margins, "
            "immaculate justified serif typography (Newsreader 18px, 1.5 line height, subtle hyphenation). "
            "Chapter header 'Chapter Four: The Silent Harbour' in semi-bold serif. "
            "At the very bottom edge, a tiny, elegant and unobtrusive page progress indicator in muted slate #6B655D: '142 / 380'."
        )
    },
    {
        "id": "04b_appearance_sheet",
        "title": "04b_Appearance_Sheet",
        "prompt": (
            f"{SHARED_STYLE} Screen: 04b Reader Appearance Bottom Sheet. "
            "Modal bottom sheet elevated over reader text with 24px top rounded corners and drag handle. "
            "Section 1: Reading themes as 6 round circular swatches with color borders: Paper (#F6F1E7), White (#FFFFFF), Sepia (#F4ECD8), Grey (#EAE6DF), Night (#23272A), Black (#121212). Two dark swatches have a tiny gold lock icon indicating premium. "
            "Section 2: Font picker as horizontal scroll cards showing 'Aa' and font name in Newsreader, Inter, Literata, EB Garamond, Source Serif. "
            "Section 3: Sliders for Font size, Line spacing, and Side margins, with A− / A+ icons at ends. "
            "Section 4: Layout segmented controls: Scroll / Pages / Two columns. Toggles: Justify text, Hyphenation, Publisher styles. "
            "Section 5: Brightness slider with a 'Follow system' toggle switch."
        )
    },
    {
        "id": "04c_text_selection_dictionary",
        "title": "04c_Text_Selection_Dictionary",
        "prompt": (
            f"{SHARED_STYLE} Screen: 04c Text Selection & Dictionary Definition. "
            "Reader view on paper canvas #F6F1E7 where the word 'littoral' is selected with deep ink blue #2F4A7A teardrop selection handles. "
            "Floating selection toolbar above the word (white rounded pill card with shadow): "
            "Highlight (with 5 color dot indicators: yellow, green, blue, pink, orange), Note, Define, Copy, Share, ⋯. "
            "Bottom modal dictionary sheet: word title 'littoral' in large serif Newsreader, phonetic pronunciation '/ˈlɪt(ə)rəl/' with speaker audio icon, "
            "part-of-speech pill chips ('adjective', 'noun'), numbered definitions with italic usage examples ('relating to or situated on the shore of the sea or a lake'), "
            "and footer 'From Wiktionary · CC BY-SA 3.0 · Offline'."
        )
    },
    {
        "id": "04d_contents_annotations",
        "title": "04d_Contents_Annotations",
        "prompt": (
            f"{SHARED_STYLE} Screen: 04d Table of Contents and Annotations Panel. "
            "Side modal sheet sliding from the left over the reader page, warm ivory surface #FAF7F2. "
            "Header with tabs: 'Contents', 'Bookmarks', 'Highlights', and top-right 'Export as Markdown' icon button. "
            "Under 'Contents' tab: nested chapter hierarchy tree with page numbers on right, active current chapter highlighted with deep ink blue vertical bar #2F4A7A. "
            "Under 'Highlights' preview: cards with book quote, color strip tag (blue, yellow), page number, creation date, and attached note snippet."
        )
    },
    {
        "id": "04e_search_in_book",
        "title": "04e_Search_in_Book",
        "prompt": (
            f"{SHARED_STYLE} Screen: 04e Search Inside Book. "
            "Reader view with search mode active. Top bar replaced by an input field holding query 'harbour' with '23 results' badge and clear 'X' button. "
            "Right side of search bar has up and down navigation arrows to jump between results. "
            "List below grouped by chapter headers ('Chapter 2', 'Chapter 4', 'Chapter 7'): "
            "each result item is a two-line snippet card with matching word 'harbour' highlighted in bold deep ink blue #2F4A7A and page number 'p. 142' in slate #6B655D."
        )
    },
    {
        "id": "05_read_aloud",
        "title": "05_Read_Aloud_Player",
        "prompt": (
            f"{SHARED_STYLE} Screen: 05 Read Aloud In-App Player. "
            "Reader screen active in read-aloud mode: the currently spoken sentence is highlighted with a soft translucent ink-blue band #D6E2F5 with smooth text auto-scroll. "
            "Elevated expanded player bottom sheet (24px rounded corners): large book cover at top, book title in serif 'The Shadow of the Wind', chapter name 'Chapter 4', "
            "the current spoken sentence rendered large in Newsreader serif with neighboring sentences faded in secondary slate above and below. "
            "Timeline scrubber progress bar for the chapter, playback controls: previous sentence, large circular play/pause button in deep ink blue #2F4A7A with white icon, next sentence. "
            "Bottom controls row of pill chips: Speed '1.25x', Voice 'English (Natural)', Sleep timer '30 min'."
        )
    },
    {
        "id": "06_lock_screen",
        "title": "06_Lock_Screen_Controls",
        "prompt": (
            "Screen: 06 Android 15 System Lock Screen with Read Aloud Media Session. "
            "Android 15 lock screen with soft blurred book art wallpaper. Large clock '9:41' and date 'Thursday, Nov 5'. "
            "Centered Material You dynamic media player card: album art is the book cover (2:3 aspect ratio), title is chapter 'Chapter Four: The Silent Harbour', "
            "subtitle is 'The Shadow of the Wind · OpenPages', chapter progress seek bar showing 14:20 / 32:00, "
            "playback controls: previous sentence, play/pause circular button, next sentence, plus quick action button 'Sleep 30m'. "
            "Small OpenPages quill/book app icon in the media card corner."
        )
    },
    {
        "id": "07_premium_paywall",
        "title": "07_Premium_Paywall",
        "prompt": (
            f"{SHARED_STYLE} Screen: 07 Premium Appearance Paywall. "
            "Full page paywall with top close 'X' button. "
            "Hero visual showing one paragraph of text rendered side-by-side in 3 rich premium themes (Linen, Midnight Blue, Forest) with different serif fonts. "
            "Headline in Newsreader serif 'Make every page yours', body 'Unlock premium reading themes, handcrafted fonts, and visual style presets.'. "
            "Feature checkmark bullets: 12 handcrafted reading themes, 8 editorial book fonts, custom accent colors, reading statistics. "
            "Reassuring note in slate #6B655D: 'Reading, offline storage, dictionary, and search remain free forever.'. "
            "Two subscription plan cards: 'Lifetime' (highlighted card with 'Best Value' badge, $14.99 one-time) and 'Yearly' ($4.99/year). "
            "Full-width primary action button 'Unlock Premium' in deep ink blue #2F4A7A with white text, and 'Restore purchases' text link below."
        )
    },
    {
        "id": "08_all_annotations",
        "title": "08_All_Annotations",
        "prompt": (
            f"{SHARED_STYLE} Screen: 08 All Annotations Screen. "
            "Top app bar with back navigation arrow, serif title 'Annotations', search icon, and overflow menu icon ⋮ with 'Export as Markdown' action. "
            "Search bar below top bar: 'Search highlights & notes...'. Filter chips row: All (42), Highlights (30), Notes (12), Bookmarks (8). "
            "List of annotation cards grouped by book with book cover thumbnail, book title in serif, and author in header. "
            "Each annotation card features: vertical color indicator strip (yellow, green, blue, pink), quoted book passage in serif italics, "
            "attached user note in sans Inter with calendar date 'Oct 28' and page reference 'Page 84'. Long press action to share or copy."
        )
    }
]

def get_token():
    raw = subprocess.check_output(['stitch', 'status', '--token', '--json']).decode()
    data = json.loads(raw)
    return data.get('accessToken') or data.get('data', {}).get('accessToken') or raw.strip()

def download_file(token, url, out_path, is_json_wrapped_base64=False, is_json_wrapped_text=False):
    req = urllib.request.Request(url, headers={'Authorization': f'Bearer {token}'})
    with urllib.request.urlopen(req) as resp:
        content = resp.read()
        if is_json_wrapped_base64:
            payload = json.loads(content.decode())
            data = base64.b64decode(payload['dataString'])
            with open(out_path, 'wb') as f:
                f.write(data)
        elif is_json_wrapped_text:
            payload = json.loads(content.decode())
            text = payload.get('dataString', content.decode())
            with open(out_path, 'w', encoding='utf-8') as f:
                f.write(text)
        else:
            with open(out_path, 'wb') as f:
                f.write(content)

def generate_screen(item, token):
    screen_id = item['id']
    screen_title = item['title']
    prompt = item['prompt']
    target_dir = os.path.join(OUT_DIR, screen_id)
    os.makedirs(target_dir, exist_ok=True)
    
    print(f"\n==========================================")
    print(f"Generating: {screen_title}")
    print(f"==========================================")
    
    cmd = [
        'stitch', 'generate', 'screen',
        '--project', PROJECT_ID,
        '--device', 'MOBILE',
        '--prompt', prompt,
        '--json'
    ]
    
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if proc.returncode != 0:
        print(f"ERROR generating {screen_title}: {proc.stderr}")
        return False
        
    try:
        res = json.loads(proc.stdout)
    except Exception as e:
        print(f"Failed to parse JSON output: {e}\nRaw output: {proc.stdout[:500]}")
        return False
        
    if not res.get('success'):
        print(f"Generation unsuccessful: {res}")
        return False
        
    data = res.get('data', {})
    node_id = data.get('id')
    canvas_url = data.get('canvasUrl')
    image_url = data.get('imageUrl')
    html_info = data.get('htmlCode', {})
    html_url = html_info.get('downloadUrl')
    
    print(f"Success! Node ID: {node_id}")
    print(f"Canvas URL: {canvas_url}")
    
    # Save metadata JSON
    meta_path = os.path.join(target_dir, f"{screen_id}_metadata.json")
    with open(meta_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2)
        
    # Download Screen Screenshot PNG
    if image_url:
        png_path = os.path.join(target_dir, f"{screen_id}_screen.png")
        print(f"Downloading screen PNG...")
        try:
            download_file(token, image_url, png_path, is_json_wrapped_base64=True)
            print(f"Saved: {png_path} ({os.path.getsize(png_path)} bytes)")
        except Exception as e:
            print(f"Failed to download screen image: {e}")
            
    # Download HTML
    if html_url:
        html_path = os.path.join(target_dir, f"{screen_id}_screen.html")
        print(f"Downloading HTML code...")
        try:
            download_file(token, html_url, html_path, is_json_wrapped_text=True)
            print(f"Saved: {html_path} ({os.path.getsize(html_path)} bytes)")
        except Exception as e:
            print(f"Failed to download HTML: {e}")
            
    # Download any embedded generated images / illustrations
    images = data.get('images', [])
    for idx, img in enumerate(images):
        dl_url = img.get('screenshot', {}).get('downloadUrl') or img.get('imageUrl')
        if dl_url:
            img_path = os.path.join(target_dir, f"{screen_id}_asset_{idx+1}.png")
            print(f"Downloading asset illustration {idx+1}...")
            try:
                download_file(token, dl_url, img_path, is_json_wrapped_base64=True)
                print(f"Saved: {img_path} ({os.path.getsize(img_path)} bytes)")
            except Exception as e:
                print(f"Failed to download asset {idx+1}: {e}")
                
    return True

def main():
    token = get_token()
    print(f"Starting sequential generation of {len(SCREENS)} screens for OpenPages...")
    
    success_count = 0
    for idx, item in enumerate(SCREENS):
        print(f"\n--- Progress: Screen {idx+1}/{len(SCREENS)} ---")
        ok = generate_screen(item, token)
        if ok:
            success_count += 1
        time.sleep(2)
        
    print(f"\n==========================================")
    print(f"Completed! Successfully generated {success_count}/{len(SCREENS)} screens.")
    print(f"All assets and HTML files saved in: {OUT_DIR}/")
    print(f"==========================================")

if __name__ == '__main__':
    main()

