#!/usr/bin/env python3
"""
Generate Batch 21 UI component PNGs for LinguaPages using Headless Chrome.
Completes all remaining 10 UI components across Screen 03 (Settings) and Screen 04b (Appearance Sheet).

Components:
1. 03_settings_top_app_bar.png (824x200, 16:9)
2. 03_settings_reading_defaults_card.png (800x600, 4:3)
3. 03_settings_read_aloud_card.png (800x600, 4:3)
4. 03_settings_library_backup_card.png (800x600, 4:3)
5. 03_settings_premium_banner_card.png (824x320, 16:9)
6. 03_settings_about_card.png (800x600, 4:3)
7. 04b_appearance_sheet_font_picker.png (824x200, 16:9)
8. 04b_appearance_sheet_typography_sliders.png (800x600, 4:3)
9. 04b_appearance_sheet_layout_controls.png (800x600, 4:3)
10. 04b_appearance_sheet_brightness_control.png (824x180, 16:9)
"""

import os
import subprocess
import shutil

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CHROME_BIN = "/usr/bin/google-chrome" if os.path.exists("/usr/bin/google-chrome") else "google-chrome"
BRAIN_DIR = "/home/tn-99778/.gemini/antigravity/brain/0ec70963-e889-41b9-a267-b853c15097ca"

# 1. 03_settings_top_app_bar.html
HTML_03_TOP_BAR = """<!DOCTYPE html>
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
  .app-bar-container {
    height: 88px;
    padding: 0 32px;
    display: flex;
    align-items: center;
    gap: 20px;
    background-color: #FAF7F2;
    border-bottom: 1px solid #E8E2D9;
  }
  .back-btn {
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
  .back-btn svg {
    stroke: #1C1B1A;
    stroke-width: 1.75;
    fill: none;
    stroke-linecap: round;
    stroke-linejoin: round;
  }
  .title {
    font-family: "Newsreader", Georgia, serif;
    font-size: 28px;
    font-weight: 700;
    color: #1C1B1A;
    letter-spacing: -0.3px;
  }
</style>
</head>
<body>
  <div class="app-bar-container">
    <button class="back-btn" aria-label="Back">
      <svg width="24" height="24" viewBox="0 0 24 24">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
    </button>
    <h1 class="title">Settings</h1>
  </div>
</body>
</html>
"""

# 2. 03_settings_reading_defaults_card.html
HTML_03_READING_DEFAULTS = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Newsreader:opsz,wght@6..72,600&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 800px;
    height: 600px;
    background-color: #FAF7F2;
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: "Inter", -apple-system, sans-serif;
    padding: 24px 32px;
    overflow: hidden;
  }
  .card {
    width: 100%;
    background-color: #FFFFFF;
    border: 1px solid #E8E2D9;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  }
  .section-label {
    font-size: 13px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    color: #6B655D;
    margin-bottom: 16px;
  }
  .row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 0;
    border-bottom: 1px solid #E8E2D9;
  }
  .row:last-child {
    border-bottom: none;
    padding-bottom: 4px;
  }
  .row-left {
    display: flex;
    align-items: center;
    gap: 16px;
  }
  .row-icon {
    width: 22px;
    height: 22px;
    stroke: #1C1B1A;
    stroke-width: 1.5;
    fill: none;
    stroke-linecap: round;
    stroke-linejoin: round;
  }
  .row-label {
    font-size: 15px;
    font-weight: 500;
    color: #1C1B1A;
  }
  .row-right {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .row-value {
    font-size: 14px;
    color: #6B655D;
    font-weight: 400;
  }
  .swatch-preview {
    width: 22px;
    height: 22px;
    border-radius: 50%;
    background-color: #F6F1E7;
    border: 1.5px solid #2F4A7A;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  }
  .chevron {
    stroke: #6B655D;
    stroke-width: 1.75;
    fill: none;
    width: 18px;
    height: 18px;
  }
  /* Material 3 Toggle */
  .switch-on {
    width: 44px;
    height: 26px;
    background-color: #2F4A7A;
    border-radius: 9999px;
    position: relative;
    cursor: pointer;
  }
  .switch-on::after {
    content: '';
    position: absolute;
    top: 3px;
    right: 3px;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background-color: #FFFFFF;
    box-shadow: 0 1px 3px rgba(0,0,0,0.2);
  }
</style>
</head>
<body>
  <div class="card">
    <div class="section-label">Reading defaults</div>
    
    <!-- Row 1 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><path d="M12 2a7 7 0 0 0 7 7c0 2-2 3-2 5"></path></svg>
        <span class="row-label">Default reading theme</span>
      </div>
      <div class="row-right">
        <div class="swatch-preview" title="Paper theme"></div>
        <span class="row-value">Paper</span>
        <svg class="chevron" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"></polyline></svg>
      </div>
    </div>

    <!-- Row 2 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><polyline points="4 7 4 4 20 4 20 7"></polyline><line x1="9" y1="20" x2="15" y2="20"></line><line x1="12" y1="4" x2="12" y2="20"></line></svg>
        <span class="row-label">Default font</span>
      </div>
      <div class="row-right">
        <span class="row-value" style="font-family:'Newsreader',serif; font-size:15px; color:#1C1B1A;">Newsreader</span>
        <svg class="chevron" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"></polyline></svg>
      </div>
    </div>

    <!-- Row 3 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"></polygon><path d="M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07"></path></svg>
        <span class="row-label">Page turning with volume keys</span>
      </div>
      <div class="row-right">
        <div class="switch-on"></div>
      </div>
    </div>

    <!-- Row 4 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect><line x1="8" y1="21" x2="16" y2="21"></line><line x1="12" y1="17" x2="12" y2="21"></line></svg>
        <span class="row-label">Keep screen on</span>
      </div>
      <div class="row-right">
        <div class="switch-on"></div>
      </div>
    </div>

    <!-- Row 5 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67"></path></svg>
        <span class="row-label">Orientation lock</span>
      </div>
      <div class="row-right">
        <span class="row-value">Follow sensor</span>
        <svg class="chevron" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"></polyline></svg>
      </div>
    </div>
  </div>
</body>
</html>
"""

# 3. 03_settings_read_aloud_card.html
HTML_03_READ_ALOUD = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 800px;
    height: 600px;
    background-color: #FAF7F2;
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: "Inter", -apple-system, sans-serif;
    padding: 24px 32px;
    overflow: hidden;
  }
  .card {
    width: 100%;
    background-color: #FFFFFF;
    border: 1px solid #E8E2D9;
    border-radius: 16px;
    padding: 28px 24px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  }
  .section-label {
    font-size: 13px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    color: #6B655D;
    margin-bottom: 20px;
  }
  .row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 18px 0;
    border-bottom: 1px solid #E8E2D9;
  }
  .row:last-child {
    border-bottom: none;
    padding-bottom: 4px;
  }
  .row-left {
    display: flex;
    align-items: center;
    gap: 16px;
  }
  .row-icon {
    width: 22px;
    height: 22px;
    stroke: #1C1B1A;
    stroke-width: 1.5;
    fill: none;
    stroke-linecap: round;
    stroke-linejoin: round;
  }
  .row-label {
    font-size: 15px;
    font-weight: 500;
    color: #1C1B1A;
  }
  .row-right {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .row-value {
    font-size: 14px;
    color: #6B655D;
    font-weight: 400;
  }
  .chevron {
    stroke: #6B655D;
    stroke-width: 1.75;
    fill: none;
    width: 18px;
    height: 18px;
  }
  .switch-on {
    width: 44px;
    height: 26px;
    background-color: #2F4A7A;
    border-radius: 9999px;
    position: relative;
    cursor: pointer;
  }
  .switch-on::after {
    content: '';
    position: absolute;
    top: 3px;
    right: 3px;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background-color: #FFFFFF;
    box-shadow: 0 1px 3px rgba(0,0,0,0.2);
  }
</style>
</head>
<body>
  <div class="card">
    <div class="section-label">Read aloud</div>
    
    <!-- Row 1 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z"></path><path d="M19 10v2a7 7 0 0 1-14 0v-2"></path><line x1="12" y1="19" x2="12" y2="23"></line><line x1="8" y1="23" x2="16" y2="23"></line></svg>
        <span class="row-label">Default voice</span>
      </div>
      <div class="row-right">
        <span class="row-value">English (UK) · Offline</span>
        <svg class="chevron" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"></polyline></svg>
      </div>
    </div>

    <!-- Row 2 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
        <span class="row-label">Reading speed</span>
      </div>
      <div class="row-right">
        <span class="row-value">1.0×</span>
        <svg class="chevron" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"></polyline></svg>
      </div>
    </div>

    <!-- Row 3 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><line x1="4" y1="9" x2="20" y2="9"></line><line x1="4" y1="15" x2="20" y2="15"></line><line x1="10" y1="3" x2="8" y2="21"></line><line x1="16" y1="3" x2="14" y2="21"></line></svg>
        <span class="row-label">Skip page numbers and footnotes</span>
      </div>
      <div class="row-right">
        <div class="switch-on"></div>
      </div>
    </div>

    <!-- Row 4 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
        <span class="row-label">Highlight spoken sentence</span>
      </div>
      <div class="row-right">
        <div class="switch-on"></div>
      </div>
    </div>
  </div>
</body>
</html>
"""

# 4. 03_settings_library_backup_card.html
HTML_03_LIBRARY_BACKUP = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 800px;
    height: 600px;
    background-color: #FAF7F2;
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: "Inter", -apple-system, sans-serif;
    padding: 24px 32px;
    overflow: hidden;
  }
  .card {
    width: 100%;
    background-color: #FFFFFF;
    border: 1px solid #E8E2D9;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  }
  .section-label {
    font-size: 13px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    color: #6B655D;
    margin-bottom: 16px;
  }
  .row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 0;
    border-bottom: 1px solid #E8E2D9;
  }
  .row:last-child {
    border-bottom: none;
    padding-bottom: 4px;
  }
  .row-left {
    display: flex;
    align-items: center;
    gap: 16px;
  }
  .row-icon {
    width: 22px;
    height: 22px;
    stroke: #1C1B1A;
    stroke-width: 1.5;
    fill: none;
    stroke-linecap: round;
    stroke-linejoin: round;
  }
  .row-label {
    font-size: 15px;
    font-weight: 500;
    color: #1C1B1A;
  }
  .row-right {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .row-value {
    font-size: 14px;
    color: #6B655D;
    font-weight: 400;
  }
  .chevron {
    stroke: #6B655D;
    stroke-width: 1.75;
    fill: none;
    width: 18px;
    height: 18px;
  }
  .pill-action {
    padding: 6px 14px;
    background-color: #2F4A7A;
    color: #FFFFFF;
    font-size: 13px;
    font-weight: 600;
    border-radius: 9999px;
    border: none;
    cursor: pointer;
  }
  .switch-on {
    width: 44px;
    height: 26px;
    background-color: #2F4A7A;
    border-radius: 9999px;
    position: relative;
    cursor: pointer;
  }
  .switch-on::after {
    content: '';
    position: absolute;
    top: 3px;
    right: 3px;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background-color: #FFFFFF;
    box-shadow: 0 1px 3px rgba(0,0,0,0.2);
  }
</style>
</head>
<body>
  <div class="card">
    <div class="section-label">Library & Backup</div>
    
    <!-- Row 1 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
        <span class="row-label">Import folder</span>
      </div>
      <div class="row-right">
        <span class="row-value">~/Documents/Books</span>
        <svg class="chevron" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"></polyline></svg>
      </div>
    </div>

    <!-- Row 2 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
        <span class="row-label">Auto-mark finished at 100%</span>
      </div>
      <div class="row-right">
        <div class="switch-on"></div>
      </div>
    </div>

    <!-- Row 3 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
        <span class="row-label">Auto-empty Trash</span>
      </div>
      <div class="row-right">
        <span class="row-value">After 30 days</span>
        <svg class="chevron" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"></polyline></svg>
      </div>
    </div>

    <!-- Row 4 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
        <span class="row-label">Back up now</span>
      </div>
      <div class="row-right">
        <button class="pill-action">Export ZIP</button>
      </div>
    </div>

    <!-- Row 5 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="17 8 12 3 7 8"></polyline><line x1="12" y1="3" x2="12" y2="15"></line></svg>
        <span class="row-label">Restore files</span>
      </div>
      <div class="row-right">
        <svg class="chevron" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"></polyline></svg>
      </div>
    </div>
  </div>
</body>
</html>
"""

# 5. 03_settings_premium_banner_card.html
HTML_03_PREMIUM_BANNER = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Newsreader:opsz,wght@6..72,600;6..72,700&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 824px;
    height: 320px;
    background-color: #FAF7F2;
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: "Inter", -apple-system, sans-serif;
    padding: 0 32px;
    overflow: hidden;
  }
  .banner-card {
    width: 100%;
    background-color: #FFFFFF;
    border: 1.5px solid #2F4A7A;
    border-radius: 16px;
    padding: 32px 36px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    box-shadow: 0 4px 16px rgba(47, 74, 122, 0.08);
  }
  .banner-left {
    max-width: 500px;
  }
  .badge-row {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 12px;
  }
  .premium-pill {
    font-size: 11px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    color: #2F4A7A;
    background-color: rgba(47, 74, 122, 0.1);
    padding: 4px 10px;
    border-radius: 9999px;
  }
  .headline {
    font-family: "Newsreader", Georgia, serif;
    font-size: 24px;
    font-weight: 700;
    color: #1C1B1A;
    letter-spacing: -0.2px;
    margin-bottom: 8px;
  }
  .description {
    font-size: 14px;
    color: #6B655D;
    line-height: 1.5;
  }
  .banner-right {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 16px;
  }
  .explore-btn {
    padding: 12px 32px;
    background-color: #2F4A7A;
    color: #FFFFFF;
    font-size: 15px;
    font-weight: 600;
    border-radius: 9999px;
    border: none;
    cursor: pointer;
    box-shadow: 0 3px 10px rgba(47, 74, 122, 0.25);
    white-space: nowrap;
  }
  .swatches-preview {
    display: flex;
    align-items: center;
    gap: 6px;
  }
  .swatch {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    border: 1px solid rgba(0,0,0,0.1);
  }
</style>
</head>
<body>
  <div class="banner-card">
    <div class="banner-left">
      <div class="badge-row">
        <span class="premium-pill">LinguaPages Premium</span>
      </div>
      <h2 class="headline">Unlock 12 themes and 8 fonts</h2>
      <p class="description">Elevate your reading experience with handcrafted editorial palettes and typography.</p>
    </div>
    <div class="banner-right">
      <button class="explore-btn">Explore</button>
      <div class="swatches-preview">
        <div class="swatch" style="background:#FAF0E6;" title="Linen"></div>
        <div class="swatch" style="background:#1C2833;" title="Midnight Blue"></div>
        <div class="swatch" style="background:#1E3F20;" title="Forest"></div>
      </div>
    </div>
  </div>
</body>
</html>
"""

# 6. 03_settings_about_card.html
HTML_03_ABOUT_CARD = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 800px;
    height: 600px;
    background-color: #FAF7F2;
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: "Inter", -apple-system, sans-serif;
    padding: 24px 32px;
    overflow: hidden;
  }
  .card {
    width: 100%;
    background-color: #FFFFFF;
    border: 1px solid #E8E2D9;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  }
  .section-label {
    font-size: 13px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.6px;
    color: #6B655D;
    margin-bottom: 16px;
  }
  .row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 0;
    border-bottom: 1px solid #E8E2D9;
  }
  .row:last-child {
    border-bottom: none;
    padding-bottom: 4px;
  }
  .row-left {
    display: flex;
    align-items: center;
    gap: 16px;
  }
  .row-icon {
    width: 22px;
    height: 22px;
    stroke: #1C1B1A;
    stroke-width: 1.5;
    fill: none;
    stroke-linecap: round;
    stroke-linejoin: round;
  }
  .row-text-group {
    display: flex;
    flex-direction: column;
    gap: 3px;
  }
  .row-label {
    font-size: 15px;
    font-weight: 500;
    color: #1C1B1A;
  }
  .row-subtitle {
    font-size: 13px;
    color: #6B655D;
  }
  .row-right {
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .row-value {
    font-size: 14px;
    color: #6B655D;
    font-variant-numeric: tabular-nums;
  }
  .chevron {
    stroke: #6B655D;
    stroke-width: 1.75;
    fill: none;
    width: 18px;
    height: 18px;
  }
  .privacy-badge {
    display: flex;
    align-items: center;
    gap: 6px;
    background-color: rgba(46, 125, 50, 0.08);
    color: #2E7D32;
    padding: 6px 12px;
    border-radius: 9999px;
    font-size: 12px;
    font-weight: 600;
  }
</style>
</head>
<body>
  <div class="card">
    <div class="section-label">About & Legal</div>
    
    <!-- Row 1 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
        <div class="row-text-group">
          <span class="row-label">Dictionary credits</span>
          <span class="row-subtitle">From Wiktionary · CC BY-SA 3.0</span>
        </div>
      </div>
      <div class="row-right">
        <svg class="chevron" viewBox="0 0 24 24"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
      </div>
    </div>

    <!-- Row 2 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
        <span class="row-label">Open-source licences</span>
      </div>
      <div class="row-right">
        <svg class="chevron" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"></polyline></svg>
      </div>
    </div>

    <!-- Row 3 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
        <span class="row-label">Version</span>
      </div>
      <div class="row-right">
        <span class="row-value">1.0.0</span>
      </div>
    </div>

    <!-- Row 4 -->
    <div class="row">
      <div class="row-left">
        <svg class="row-icon" viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
        <span class="row-label">Privacy guarantee</span>
      </div>
      <div class="row-right">
        <div class="privacy-badge">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#2E7D32" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
          Offline & Private
        </div>
      </div>
    </div>
  </div>
</body>
</html>
"""

# 7. 04b_appearance_sheet_font_picker.html
HTML_04B_FONT_PICKER = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Newsreader:opsz,wght@6..72,600&family=Fraunces:opsz,wght@9..144,600&family=Literata:opsz,wght@7..72,600&family=EB+Garamond:wght@600&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 824px;
    height: 200px;
    background-color: #FFFFFF;
    display: flex;
    flex-direction: column;
    justify-content: center;
    font-family: "Inter", -apple-system, sans-serif;
    padding: 0 32px;
    overflow: hidden;
  }
  .title {
    font-size: 14px;
    font-weight: 700;
    color: #1C1B1A;
    margin-bottom: 16px;
    letter-spacing: -0.1px;
  }
  .chips-row {
    display: flex;
    align-items: center;
    gap: 10px;
    overflow-x: auto;
  }
  .font-chip {
    height: 40px;
    padding: 0 16px;
    border-radius: 9999px;
    border: 1px solid #E8E2D9;
    background-color: #FFFFFF;
    color: #1C1B1A;
    font-size: 14px;
    font-weight: 500;
    display: flex;
    align-items: center;
    gap: 6px;
    white-space: nowrap;
    cursor: pointer;
  }
  .font-chip.active {
    background-color: #2F4A7A;
    border-color: #2F4A7A;
    color: #FFFFFF;
    box-shadow: 0 2px 8px rgba(47, 74, 122, 0.25);
  }
  .font-chip .lock-icon {
    width: 13px;
    height: 13px;
    stroke: #6B655D;
    stroke-width: 2;
    fill: none;
    margin-left: 2px;
  }
</style>
</head>
<body>
  <div class="title">Font</div>
  <div class="chips-row">
    <div class="font-chip">Publisher</div>
    <div class="font-chip active" style="font-family:'Newsreader',serif;">Aa Newsreader</div>
    <div class="font-chip" style="font-family:'Fraunces',serif;">Aa Fraunces</div>
    <div class="font-chip" style="font-family:'Literata',serif;">Aa Literata</div>
    <div class="font-chip" style="font-family:serif;">Aa Source Serif</div>
    <div class="font-chip" style="font-family:'EB Garamond',serif;">
      Aa EB Garamond
      <svg class="lock-icon" viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
    </div>
    <div class="font-chip" style="font-family:'Inter',sans-serif;">Aa Inter</div>
  </div>
</body>
</html>
"""

# 8. 04b_appearance_sheet_typography_sliders.html
HTML_04B_TYPO_SLIDERS = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 800px;
    height: 600px;
    background-color: #FFFFFF;
    display: flex;
    flex-direction: column;
    justify-content: center;
    font-family: "Inter", -apple-system, sans-serif;
    padding: 0 40px;
    overflow: hidden;
  }
  .slider-group {
    display: flex;
    flex-direction: column;
    gap: 12px;
    margin-bottom: 32px;
  }
  .slider-group:last-child {
    margin-bottom: 0;
  }
  .slider-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .slider-label {
    font-size: 15px;
    font-weight: 600;
    color: #1C1B1A;
  }
  .slider-val {
    font-size: 14px;
    font-weight: 500;
    color: #6B655D;
  }
  .slider-control-row {
    display: flex;
    align-items: center;
    gap: 16px;
  }
  .end-icon {
    color: #6B655D;
    font-weight: 600;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 28px;
  }
  .track-wrapper {
    flex: 1;
    height: 32px;
    display: flex;
    align-items: center;
    position: relative;
  }
  .track-bg {
    width: 100%;
    height: 4px;
    background-color: #E8E2D9;
    border-radius: 9999px;
    position: relative;
  }
  .track-fill {
    height: 100%;
    background-color: #2F4A7A;
    border-radius: 9999px;
  }
  .thumb {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background-color: #2F4A7A;
    position: absolute;
    top: 50%;
    transform: translate(-50%, -50%);
    box-shadow: 0 2px 6px rgba(47, 74, 122, 0.4);
  }
</style>
</head>
<body>
  <!-- Slider 1: Size -->
  <div class="slider-group">
    <div class="slider-header">
      <span class="slider-label">Size</span>
      <span class="slider-val">18 px</span>
    </div>
    <div class="slider-control-row">
      <span class="end-icon" style="font-size: 13px;">A−</span>
      <div class="track-wrapper">
        <div class="track-bg">
          <div class="track-fill" style="width: 55%;"></div>
          <div class="thumb" style="left: 55%;"></div>
        </div>
      </div>
      <span class="end-icon" style="font-size: 20px;">A+</span>
    </div>
  </div>

  <!-- Slider 2: Line spacing -->
  <div class="slider-group">
    <div class="slider-header">
      <span class="slider-label">Line spacing</span>
      <span class="slider-val">1.5×</span>
    </div>
    <div class="slider-control-row">
      <span class="end-icon">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6B655D" stroke-width="2"><line x1="4" y1="7" x2="20" y2="7"></line><line x1="4" y1="12" x2="20" y2="12"></line><line x1="4" y1="17" x2="20" y2="17"></line></svg>
      </span>
      <div class="track-wrapper">
        <div class="track-bg">
          <div class="track-fill" style="width: 45%;"></div>
          <div class="thumb" style="left: 45%;"></div>
        </div>
      </div>
      <span class="end-icon">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#6B655D" stroke-width="2"><line x1="4" y1="5" x2="20" y2="5"></line><line x1="4" y1="12" x2="20" y2="12"></line><line x1="4" y1="19" x2="20" y2="19"></line></svg>
      </span>
    </div>
  </div>

  <!-- Slider 3: Margins -->
  <div class="slider-group">
    <div class="slider-header">
      <span class="slider-label">Margins</span>
      <span class="slider-val">20 px</span>
    </div>
    <div class="slider-control-row">
      <span class="end-icon">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6B655D" stroke-width="2"><rect x="5" y="4" width="14" height="16" rx="2"></rect></svg>
      </span>
      <div class="track-wrapper">
        <div class="track-bg">
          <div class="track-fill" style="width: 40%;"></div>
          <div class="thumb" style="left: 40%;"></div>
        </div>
      </div>
      <span class="end-icon">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#6B655D" stroke-width="2"><rect x="3" y="4" width="18" height="16" rx="2"></rect><line x1="7" y1="4" x2="7" y2="20"></line><line x1="17" y1="4" x2="17" y2="20"></line></svg>
      </span>
    </div>
  </div>
</body>
</html>
"""

# 9. 04b_appearance_sheet_layout_controls.html
HTML_04B_LAYOUT_CONTROLS = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 800px;
    height: 600px;
    background-color: #FFFFFF;
    display: flex;
    flex-direction: column;
    justify-content: center;
    font-family: "Inter", -apple-system, sans-serif;
    padding: 0 40px;
    overflow: hidden;
  }
  .segmented-control {
    width: 100%;
    height: 48px;
    background-color: #FAF7F2;
    border: 1px solid #E8E2D9;
    border-radius: 9999px;
    display: flex;
    padding: 4px;
    margin-bottom: 28px;
  }
  .segment-btn {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    font-weight: 500;
    color: #6B655D;
    border-radius: 9999px;
    border: none;
    background: transparent;
    cursor: pointer;
  }
  .segment-btn.active {
    background-color: #2F4A7A;
    color: #FFFFFF;
    font-weight: 600;
    box-shadow: 0 2px 6px rgba(47, 74, 122, 0.25);
  }
  .toggles-list {
    display: flex;
    flex-direction: column;
  }
  .toggle-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 18px 0;
    border-bottom: 1px solid #E8E2D9;
  }
  .toggle-row:last-child {
    border-bottom: none;
  }
  .toggle-label {
    font-size: 15px;
    font-weight: 500;
    color: #1C1B1A;
  }
  .switch-on {
    width: 44px;
    height: 26px;
    background-color: #2F4A7A;
    border-radius: 9999px;
    position: relative;
    cursor: pointer;
  }
  .switch-on::after {
    content: '';
    position: absolute;
    top: 3px;
    right: 3px;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background-color: #FFFFFF;
    box-shadow: 0 1px 3px rgba(0,0,0,0.2);
  }
  .switch-off {
    width: 44px;
    height: 26px;
    background-color: #E8E2D9;
    border-radius: 9999px;
    position: relative;
    cursor: pointer;
  }
  .switch-off::after {
    content: '';
    position: absolute;
    top: 3px;
    left: 3px;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background-color: #FFFFFF;
    box-shadow: 0 1px 3px rgba(0,0,0,0.2);
  }
</style>
</head>
<body>
  <!-- Segmented Control -->
  <div class="segmented-control">
    <button class="segment-btn">Scroll</button>
    <button class="segment-btn active">Pages</button>
    <button class="segment-btn">Two columns</button>
  </div>

  <!-- Toggle Rows -->
  <div class="toggles-list">
    <div class="toggle-row">
      <span class="toggle-label">Justify text</span>
      <div class="switch-on"></div>
    </div>
    <div class="toggle-row">
      <span class="toggle-label">Hyphenation</span>
      <div class="switch-on"></div>
    </div>
    <div class="toggle-row">
      <span class="toggle-label">Publisher styles</span>
      <div class="switch-off"></div>
    </div>
  </div>
</body>
</html>
"""

# 10. 04b_appearance_sheet_brightness_control.html
HTML_04B_BRIGHTNESS = """<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body {
    width: 824px;
    height: 180px;
    background-color: #FFFFFF;
    display: flex;
    align-items: center;
    font-family: "Inter", -apple-system, sans-serif;
    padding: 0 32px;
    overflow: hidden;
  }
  .brightness-row {
    width: 100%;
    display: flex;
    align-items: center;
    gap: 20px;
  }
  .sun-icon {
    width: 20px;
    height: 20px;
    stroke-width: 1.75;
    fill: none;
    stroke-linecap: round;
    stroke-linejoin: round;
  }
  .dim-sun { stroke: #6B655D; }
  .bright-sun { stroke: #1C1B1A; }
  .slider-track-wrap {
    flex: 1;
    height: 32px;
    display: flex;
    align-items: center;
    position: relative;
  }
  .track-bg {
    width: 100%;
    height: 4px;
    background-color: #E8E2D9;
    border-radius: 9999px;
    position: relative;
  }
  .track-fill {
    width: 65%;
    height: 100%;
    background-color: #2F4A7A;
    border-radius: 9999px;
  }
  .thumb {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background-color: #2F4A7A;
    position: absolute;
    top: 50%;
    left: 65%;
    transform: translate(-50%, -50%);
    box-shadow: 0 2px 6px rgba(47, 74, 122, 0.4);
  }
  .system-toggle-group {
    display: flex;
    align-items: center;
    gap: 10px;
    padding-left: 16px;
    border-left: 1px solid #E8E2D9;
  }
  .system-label {
    font-size: 13px;
    color: #6B655D;
    font-weight: 500;
    white-space: nowrap;
  }
  .switch-on {
    width: 40px;
    height: 24px;
    background-color: #2F4A7A;
    border-radius: 9999px;
    position: relative;
    cursor: pointer;
  }
  .switch-on::after {
    content: '';
    position: absolute;
    top: 2px;
    right: 2px;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background-color: #FFFFFF;
    box-shadow: 0 1px 3px rgba(0,0,0,0.2);
  }
</style>
</head>
<body>
  <div class="brightness-row">
    <svg class="sun-icon dim-sun" viewBox="0 0 24 24"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>
    
    <div class="slider-track-wrap">
      <div class="track-bg">
        <div class="track-fill"></div>
        <div class="thumb"></div>
      </div>
    </div>
    
    <svg class="sun-icon bright-sun" viewBox="0 0 24 24"><circle cx="12" cy="12" r="5"></circle><line x1="12" y1="1" x2="12" y2="3"></line><line x1="12" y1="21" x2="12" y2="23"></line><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line><line x1="1" y1="12" x2="3" y2="12"></line><line x1="21" y1="12" x2="23" y2="12"></line><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line></svg>

    <div class="system-toggle-group">
      <span class="system-label">Follow system</span>
      <div class="switch-on"></div>
    </div>
  </div>
</body>
</html>
"""

ITEMS = [
    {
        "filename": "03_settings_top_app_bar.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "03_settings"),
        "width": 824,
        "height": 200,
        "html": HTML_03_TOP_BAR,
    },
    {
        "filename": "03_settings_reading_defaults_card.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "03_settings"),
        "width": 800,
        "height": 600,
        "html": HTML_03_READING_DEFAULTS,
    },
    {
        "filename": "03_settings_read_aloud_card.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "03_settings"),
        "width": 800,
        "height": 600,
        "html": HTML_03_READ_ALOUD,
    },
    {
        "filename": "03_settings_library_backup_card.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "03_settings"),
        "width": 800,
        "height": 600,
        "html": HTML_03_LIBRARY_BACKUP,
    },
    {
        "filename": "03_settings_premium_banner_card.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "03_settings"),
        "width": 824,
        "height": 320,
        "html": HTML_03_PREMIUM_BANNER,
    },
    {
        "filename": "03_settings_about_card.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "03_settings"),
        "width": 800,
        "height": 600,
        "html": HTML_03_ABOUT_CARD,
    },
    {
        "filename": "04b_appearance_sheet_font_picker.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "04b_appearance_sheet"),
        "width": 824,
        "height": 200,
        "html": HTML_04B_FONT_PICKER,
    },
    {
        "filename": "04b_appearance_sheet_typography_sliders.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "04b_appearance_sheet"),
        "width": 800,
        "height": 600,
        "html": HTML_04B_TYPO_SLIDERS,
    },
    {
        "filename": "04b_appearance_sheet_layout_controls.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "04b_appearance_sheet"),
        "width": 800,
        "height": 600,
        "html": HTML_04B_LAYOUT_CONTROLS,
    },
    {
        "filename": "04b_appearance_sheet_brightness_control.png",
        "dest_dir": os.path.join(BASE_DIR, "design", "components", "04b_appearance_sheet"),
        "width": 824,
        "height": 180,
        "html": HTML_04B_BRIGHTNESS,
    },
]

print(f"Starting Batch 21 generation: {len(ITEMS)} components using {CHROME_BIN}...")

for item in ITEMS:
    tmp_html = f"/tmp/{item['filename']}.html"
    tmp_png = f"/tmp/{item['filename']}"
    with open(tmp_html, "w", encoding="utf-8") as f:
        f.write(item["html"])
    
    cmd = [
        CHROME_BIN,
        "--headless",
        "--no-sandbox",
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
    
    if os.path.exists(BRAIN_DIR):
        brain_path = os.path.join(BRAIN_DIR, item["filename"])
        shutil.copyfile(tmp_png, brain_path)
        
    print(f"✓ Generated: {dest_path} ({item['width']}x{item['height']}, {os.path.getsize(dest_path)} bytes)")

print("\n🎉 Batch 21 generation complete! All 10 missing components have been generated.")
