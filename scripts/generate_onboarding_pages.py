#!/usr/bin/env python3
"""
Generate Onboarding Carousel Pages 2, 3, 4 on Stitch Canvas
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

ONBOARDING_SCREENS = [
    {
        "id": "01b_onboarding_page2",
        "title": "01b_Onboarding_Page2_Reading_Styles",
        "prompt": (
            f"{SHARED_STYLE} Screen: 01b Onboarding Carousel - Page 2 of 4. "
            "Top utility bar with 'Skip' text button on top right. "
            "Upper 55%: soft, serene editorial illustration celebrating reading comfort and typography: an open book surrounded by delicate font choice swatches (Newsreader, Inter), gentle margin guides, and subtle colorful bookmark ribbons in tranquil ink linework and watercolor washes. "
            "Below the illustration: headline in Newsreader serif 'Read the way you like', followed by a two-line body in slate #6B655D: 'Themes, fonts, line spacing and margins. Highlights, notes and bookmarks that stay with the page.'. "
            "Carousel page dots indicator with Page 2 of 4 active in deep ink blue #2F4A7A. "
            "Bottom full-width primary pill action button 'Next' in deep ink blue #2F4A7A with white text."
        )
    },
    {
        "id": "01c_onboarding_page3",
        "title": "01c_Onboarding_Page3_Read_Aloud",
        "prompt": (
            f"{SHARED_STYLE} Screen: 01c Onboarding Carousel - Page 3 of 4. "
            "Top utility bar with 'Skip' text button on top right. "
            "Upper 55%: soft, poetic editorial illustration of serene audio narration and spoken reading: an open hardcover book emitting gentle, harmonious melodic soundwaves and acoustic ribbon curves drifting peacefully upwards into warm ivory space, delicate ink linework and calm watercolor tones. "
            "Below the illustration: headline in Newsreader serif 'Listen when your eyes rest', followed by a two-line body in slate #6B655D: 'Text-to-speech read aloud with natural voices, sentence tracking, and sleep timer, even when your screen is locked.'. "
            "Carousel page dots indicator with Page 3 of 4 active in deep ink blue #2F4A7A. "
            "Bottom full-width primary pill action button 'Next' in deep ink blue #2F4A7A with white text."
        )
    },
    {
        "id": "01d_onboarding_page4",
        "title": "01d_Onboarding_Page4_Privacy",
        "prompt": (
            f"{SHARED_STYLE} Screen: 01d Onboarding Carousel - Page 4 of 4 (Final Step). "
            "Top utility bar with minimal OpenPages logo mark. "
            "Upper 55%: soft, elegant editorial illustration of private offline reading sanctuary: an open book with a delicate minimalist padlock emblem embossed on leather, surrounded by gentle dictionary definition cards and letter glyphs. "
            "Below the illustration: headline in Newsreader serif 'Private by design', followed by a two-line body in slate #6B655D: 'No account, no telemetry, no tracking. DRM-free books stored only on your device, with free offline dictionary lookup.'. "
            "Carousel page dots indicator with Page 4 of 4 active in deep ink blue #2F4A7A. "
            "Bottom action area: full-width primary pill button 'Import your first book' in deep ink blue #2F4A7A with white text, and a secondary text link below 'Explore first' in slate #6B655D."
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

def main():
    token = get_token()
    print("Generating Onboarding Carousel Pages 2, 3, 4 on Stitch Canvas...")
    
    for item in ONBOARDING_SCREENS:
        screen_id = item['id']
        screen_title = item['title']
        prompt = item['prompt']
        target_dir = os.path.join(OUT_DIR, screen_id)
        os.makedirs(target_dir, exist_ok=True)
        
        print(f"\nGenerating: {screen_title}")
        cmd = [
            'stitch', 'generate', 'screen',
            '--project', PROJECT_ID,
            '--device', 'MOBILE',
            '--prompt', prompt,
            '--json'
        ]
        
        proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if proc.returncode != 0:
            print(f"Error generating {screen_title}: {proc.stderr}")
            continue
            
        res = json.loads(proc.stdout)
        data = res.get('data', {})
        node_id = data.get('id')
        print(f"Success! Node ID: {node_id}")
        
        meta_path = os.path.join(target_dir, f"{screen_id}_metadata.json")
        with open(meta_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2)
            
        img_url = data.get('imageUrl')
        if img_url:
            png_path = os.path.join(target_dir, f"{screen_id}_screen.png")
            download_file(token, img_url, png_path, is_json_wrapped_base64=True)
            print(f"Saved: {png_path}")
            
        html_url = data.get('htmlCode', {}).get('downloadUrl')
        if html_url:
            html_path = os.path.join(target_dir, f"{screen_id}_screen.html")
            download_file(token, html_url, html_path, is_json_wrapped_text=True)
            print(f"Saved: {html_path}")
            
        for idx, img in enumerate(data.get('images', [])):
            dl_url = img.get('screenshot', {}).get('downloadUrl') or img.get('imageUrl')
            if dl_url:
                img_path = os.path.join(target_dir, f"{screen_id}_asset_{idx+1}.png")
                download_file(token, dl_url, img_path, is_json_wrapped_base64=True)
                print(f"Saved asset illustration: {img_path}")
                
        time.sleep(2)

if __name__ == '__main__':
    main()

