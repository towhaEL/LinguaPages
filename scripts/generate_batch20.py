#!/usr/bin/env python3
"""
Generate Batch 20 UI component PNGs for LinguaPages using Headless Chrome.
Components:
1. 07_premium_paywall_action_footer.png (824x220)
2. 08_all_annotations_top_bar.png (824x200)
3. 08_all_annotations_book_group_header.png (824x200)
4. 08_all_annotations_export_dialog_sheet.png (800x600)
"""

import os
import subprocess
import shutil

BASE_DIR = "/Users/uswer/StudioProjects/linguaPages"
CHROME_BIN = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
BRAIN_DIR = "/Users/uswer/.gemini/antigravity/brain/ce1b0551-65e6-4a79-98c3-0d36eb800487"

# 1. 07_premium_paywall_action_footer.html
HTML_07_FOOTER = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 824px;
    height: 220px;
    background-color: #FAF7F2;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    font-family: "Inter", -apple-system, sans-serif;
    padding: 0 48px;
    overflow: hidden;
  }
  .cta-button {
    width: 100%;
    max-width: 728px;
    height: 52px;
    background-color: #2F4A7A;
    border: none;
    border-radius: 9999px;
    color: #FFFFFF;
    font-size: 16px;
    font-weight: 600;
    letter-spacing: 0.2px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(47, 74, 122, 0.22);
  }
  .restore-link {
    margin-top: 16px;
    color: #6B655D;
    font-size: 14px;
    font-weight: 500;
    text-decoration: none;
    cursor: pointer;
    letter-spacing: 0.1px;
    transition: color 0.2s;
  }
</style>
</head>
<body>
  <button class="cta-button">Unlock LinguaPages Premium</button>
  <a class="restore-link" href="#">Restore purchase</a>
</body>
</html>
"""

# 2. 08_all_annotations_top_bar.html
HTML_08_TOP_BAR = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Newsreader:opsz,wght@6..72,600;6..72,700&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 824px;
    height: 200px;
    background-color: #FAF7F2;
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    font-family: "Inter", -apple-system, sans-serif;
    overflow: hidden;
  }
  .top-bar-container {
    height: 80px;
    padding: 0 28px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid #E8E2D9;
    background-color: #FAF7F2;
  }
  .left-section {
    display: flex;
    align-items: center;
    gap: 18px;
  }
  .icon-btn {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: transparent;
    border: none;
    cursor: pointer;
  }
  .icon-btn svg {
    stroke: #1C1B1A;
    stroke-width: 1.75;
    fill: none;
    stroke-linecap: round;
    stroke-linejoin: round;
  }
  .title {
    font-family: "Newsreader", serif;
    font-size: 26px;
    font-weight: 700;
    color: #1C1B1A;
    letter-spacing: -0.3px;
  }
  .right-section {
    display: flex;
    align-items: center;
    gap: 8px;
  }
</style>
</head>
<body>
  <div class="top-bar-container">
    <div class="left-section">
      <button class="icon-btn" aria-label="Back">
        <svg width="24" height="24" viewBox="0 0 24 24">
          <line x1="19" y1="12" x2="5" y2="12"></line>
          <polyline points="12 19 5 12 12 5"></polyline>
        </svg>
      </button>
      <h1 class="title">Annotations</h1>
    </div>
    <div class="right-section">
      <button class="icon-btn" aria-label="Search">
        <svg width="22" height="22" viewBox="0 0 24 24">
          <circle cx="11" cy="11" r="8"></circle>
          <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
        </svg>
      </button>
      <button class="icon-btn" aria-label="Export / More options">
        <svg width="22" height="22" viewBox="0 0 24 24">
          <circle cx="12" cy="5" r="1.5" fill="#1C1B1A"></circle>
          <circle cx="12" cy="12" r="1.5" fill="#1C1B1A"></circle>
          <circle cx="12" cy="19" r="1.5" fill="#1C1B1A"></circle>
        </svg>
      </button>
    </div>
  </div>
</body>
</html>
"""

# 3. 08_all_annotations_book_group_header.html
HTML_08_GROUP_HEADER = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Newsreader:opsz,wght@6..72,600;6..72,700&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 824px;
    height: 200px;
    background-color: #FAF7F2;
    display: flex;
    flex-direction: column;
    justify-content: center;
    font-family: "Inter", -apple-system, sans-serif;
    padding: 0 32px;
    overflow: hidden;
  }
  .divider-top {
    width: 100%;
    height: 1px;
    background-color: #E8E2D9;
    margin-bottom: 24px;
  }
  .header-content {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .book-info {
    display: flex;
    align-items: center;
    gap: 16px;
  }
  .book-cover {
    width: 48px;
    height: 72px;
    border-radius: 4px;
    background: linear-gradient(135deg, #2F4A7A 0%, #1A2840 100%);
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.12);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 6px;
    color: #FFFFFF;
    position: relative;
    overflow: hidden;
  }
  .book-cover::after {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 4px;
    height: 100%;
    background: rgba(255, 255, 255, 0.2);
  }
  .cover-mini-title {
    font-family: "Newsreader", serif;
    font-size: 7px;
    font-weight: 700;
    line-height: 1.1;
    text-transform: uppercase;
    letter-spacing: 0.2px;
  }
  .cover-mini-author {
    font-size: 5px;
    opacity: 0.8;
  }
  .text-details {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }
  .book-title {
    font-family: "Newsreader", serif;
    font-size: 20px;
    font-weight: 700;
    color: #1C1B1A;
    letter-spacing: -0.2px;
  }
  .book-author {
    font-size: 14px;
    font-weight: 500;
    color: #6B655D;
  }
  .badge {
    background-color: #FFFFFF;
    border: 1px solid #E8E2D9;
    border-radius: 9999px;
    padding: 6px 14px;
    font-size: 13px;
    font-weight: 600;
    color: #2F4A7A;
    display: flex;
    align-items: center;
    gap: 6px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.02);
  }
  .badge-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background-color: #2F4A7A;
  }
</style>
</head>
<body>
  <div class="divider-top"></div>
  <div class="header-content">
    <div class="book-info">
      <div class="book-cover">
        <div class="cover-mini-title">The Salt<br>Path</div>
        <div class="cover-mini-author">R. Winn</div>
      </div>
      <div class="text-details">
        <div class="book-title">The Salt Path</div>
        <div class="book-author">Raynor Winn</div>
      </div>
    </div>
    <div class="badge">
      <div class="badge-dot"></div>
      14 highlights · 3 notes
    </div>
  </div>
</body>
</html>
"""

# 4. 08_all_annotations_export_dialog_sheet.html
HTML_08_EXPORT_DIALOG = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Newsreader:opsz,wght@6..72,600;6..72,700&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 800px;
    height: 600px;
    background-color: #FAF7F2;
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    font-family: "Inter", -apple-system, sans-serif;
    overflow: hidden;
  }
  .modal-sheet {
    background: #FFFFFF;
    border-top-left-radius: 24px;
    border-top-right-radius: 24px;
    border-top: 1px solid #E8E2D9;
    border-left: 1px solid #E8E2D9;
    border-right: 1px solid #E8E2D9;
    padding: 16px 36px 36px 36px;
    display: flex;
    flex-direction: column;
    box-shadow: 0 -8px 30px rgba(0, 0, 0, 0.05);
  }
  .drag-handle {
    width: 36px;
    height: 4px;
    background-color: #E8E2D9;
    border-radius: 9999px;
    margin: 0 auto 20px auto;
  }
  .sheet-title {
    font-family: "Newsreader", serif;
    font-size: 24px;
    font-weight: 700;
    color: #1C1B1A;
    margin-bottom: 4px;
  }
  .sheet-subtitle {
    font-size: 14px;
    color: #6B655D;
    margin-bottom: 24px;
  }
  .options-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
    margin-bottom: 28px;
  }
  .option-card {
    display: flex;
    align-items: center;
    padding: 16px 20px;
    border: 1px solid #E8E2D9;
    border-radius: 14px;
    background: #FFFFFF;
    gap: 16px;
    cursor: pointer;
  }
  .option-card.selected {
    border: 2px solid #2F4A7A;
    background: #F8FAFD;
  }
  .icon-box {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    background: #FAF7F2;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .option-card.selected .icon-box {
    background: rgba(47, 74, 122, 0.08);
  }
  .icon-box svg {
    stroke: #2F4A7A;
    stroke-width: 1.75;
    fill: none;
    stroke-linecap: round;
    stroke-linejoin: round;
  }
  .option-texts {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 2px;
  }
  .option-title {
    font-size: 15px;
    font-weight: 600;
    color: #1C1B1A;
  }
  .option-desc {
    font-size: 13px;
    color: #6B655D;
  }
  .radio-check {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    border: 2px solid #2F4A7A;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .radio-check-inner {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background-color: #2F4A7A;
  }
  .radio-unselected {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    border: 1.5px solid #D1C9BE;
  }
  .primary-btn {
    width: 100%;
    height: 50px;
    background-color: #2F4A7A;
    border: none;
    border-radius: 9999px;
    color: #FFFFFF;
    font-size: 16px;
    font-weight: 600;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    box-shadow: 0 4px 12px rgba(47, 74, 122, 0.2);
  }
</style>
</head>
<body>
  <div class="modal-sheet">
    <div class="drag-handle"></div>
    <div class="sheet-title">Export Annotations</div>
    <div class="sheet-subtitle">Choose format and destination for your reading highlights.</div>
    
    <div class="options-list">
      <!-- Option 1: Markdown -->
      <div class="option-card selected">
        <div class="icon-box">
          <svg width="22" height="22" viewBox="0 0 24 24">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
            <polyline points="14 2 14 8 20 8"></polyline>
            <line x1="16" y1="13" x2="8" y2="13"></line>
            <line x1="16" y1="17" x2="8" y2="17"></line>
            <polyline points="10 9 9 9 8 9"></polyline>
          </svg>
        </div>
        <div class="option-texts">
          <div class="option-title">Save as Markdown (.md)</div>
          <div class="option-desc">Formatted with quotes, page numbers and custom notes</div>
        </div>
        <div class="radio-check"><div class="radio-check-inner"></div></div>
      </div>
      
      <!-- Option 2: Clipboard -->
      <div class="option-card">
        <div class="icon-box">
          <svg width="22" height="22" viewBox="0 0 24 24">
            <path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"></path>
            <rect x="8" y="2" width="8" height="4" rx="1" ry="1"></rect>
          </svg>
        </div>
        <div class="option-texts">
          <div class="option-title">Copy all to clipboard</div>
          <div class="option-desc">Ready to paste directly into Obsidian, Notion or notes</div>
        </div>
        <div class="radio-unselected"></div>
      </div>

      <!-- Option 3: Share -->
      <div class="option-card">
        <div class="icon-box">
          <svg width="22" height="22" viewBox="0 0 24 24">
            <circle cx="18" cy="5" r="3"></circle>
            <circle cx="6" cy="12" r="3"></circle>
            <circle cx="18" cy="19" r="3"></circle>
            <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"></line>
            <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"></line>
          </svg>
        </div>
        <div class="option-texts">
          <div class="option-title">Share via app</div>
          <div class="option-desc">Send to Google Drive, email, or messaging apps</div>
        </div>
        <div class="radio-unselected"></div>
      </div>
    </div>
    
    <button class="primary-btn">Export 64 Annotations</button>
  </div>
</body>
</html>
"""

ITEMS = [
    {
        "filename": "07_premium_paywall_action_footer.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "07_premium_paywall"),
        "width": 824,
        "height": 220,
        "html": HTML_07_FOOTER,
    },
    {
        "filename": "08_all_annotations_top_bar.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "08_all_annotations"),
        "width": 824,
        "height": 200,
        "html": HTML_08_TOP_BAR,
    },
    {
        "filename": "08_all_annotations_book_group_header.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "08_all_annotations"),
        "width": 824,
        "height": 200,
        "html": HTML_08_GROUP_HEADER,
    },
    {
        "filename": "08_all_annotations_export_dialog_sheet.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "08_all_annotations"),
        "width": 800,
        "height": 600,
        "html": HTML_08_EXPORT_DIALOG,
    },
]

for item in ITEMS:
    tmp_html = f"/tmp/{item['filename']}.html"
    tmp_png = f"/tmp/{item['filename']}"
    with open(tmp_html, "w") as f:
        f.write(item["html"])
    
    cmd = [
        CHROME_BIN,
        "--headless",
        "--disable-gpu",
        f"--screenshot={tmp_png}",
        f"--window-size={item['width']},{item['height']}",
        "--hide-scrollbars",
        f"file://{tmp_html}"
    ]
    subprocess.run(cmd, check=True)
    
    os.makedirs(item["dest_dir"], exist_ok=True)
    dest_path = os.path.join(item["dest_dir"], item["filename"])
    shutil.copyfile(tmp_png, dest_path)
    brain_path = os.path.join(BRAIN_DIR, item["filename"])
    shutil.copyfile(tmp_png, brain_path)
    print(f"Generated and copied: {dest_path}")

print("Batch 20 generation complete!")

