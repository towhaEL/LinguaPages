import re
import os
import sys

plan_path = 'design/ui_generation_plan.md'
with open(plan_path, 'r', encoding='utf-8') as f:
    content = f.read()

comp_splits = re.split(r'\n#### Component: ', content)
header_part = comp_splits[0]
components = comp_splits[1:]

print(f"Total components parsed: {len(components)}")

records = []
for i, comp in enumerate(components):
    first_line = comp.split('\n')[0].strip('` ')
    
    filename_m = re.search(r'-\s*\*\*Filename\*\*:\s*`?([^\n`]+)`?', comp)
    filename = filename_m.group(1).strip() if filename_m else None
    
    path_m = re.search(r'-\s*\*\*Output Path\*\*:\s*`?([^\n`]+)`?', comp)
    path = path_m.group(1).strip() if path_m else None
    
    ar_m = re.search(r'-\s*\*\*Aspect Ratio\*\*:\s*`?([^\n`]+)`?', comp)
    ar = ar_m.group(1).strip() if ar_m else None

    dim_m = re.search(r'-\s*\*\*Target Dimensions\*\*:\s*`?([^\n`]+)`?', comp)
    dims = dim_m.group(1).strip() if dim_m else None
    
    role_m = re.search(r'-\s*\*\*Component Role\*\*:\s*([^\n]+(?:\n(?!\*\*|-|\n)[^\n]+)*)', comp)
    role_desc = role_m.group(1).strip() if role_m else None
    
    style_m = re.search(r'\*\*Shared Style Context\*\*:\s*\n(>[\s\S]*?)(?=\n\*\*|\n###|\n####|\Z)', comp)
    shared_style = style_m.group(1).strip() if style_m else None

    prompt_m = re.search(r'\*\*Visual Prompt\*\*:\s*\n(>[\s\S]*?)(?=\n\*\*|\n###|\n####|\Z)', comp)
    prompt = prompt_m.group(1).strip() if prompt_m else None

    neg_m = re.search(r'\*\*Negative Prompt\*\*:\s*\n(>[\s\S]*?)(?=\n\*\*|\n###|\n####|\n---|\Z)', comp)
    neg_prompt = neg_m.group(1).strip() if neg_m else None

    records.append({
        'index': i + 1,
        'title': first_line,
        'filename': filename,
        'path': path,
        'aspect_ratio': ar,
        'dimensions': dims,
        'has_role': bool(role_desc),
        'has_shared_style': bool(shared_style),
        'has_prompt': bool(prompt),
        'has_negative': bool(neg_prompt),
        'prompt_len': len(prompt) if prompt else 0,
        'prompt_text': prompt,
        'role_text': role_desc
    })

print(f"Total records created: {len(records)}")

missing_fields = []
for r in records:
    if not r['filename']: missing_fields.append((r['index'], r['title'], 'filename'))
    if not r['path']: missing_fields.append((r['index'], r['title'], 'path'))
    if not r['aspect_ratio']: missing_fields.append((r['index'], r['title'], 'aspect_ratio'))
    if not r['dimensions']: missing_fields.append((r['index'], r['title'], 'dimensions'))
    if not r['has_role']: missing_fields.append((r['index'], r['title'], 'role'))
    if not r['has_shared_style']: missing_fields.append((r['index'], r['title'], 'shared_style'))
    if not r['has_prompt']: missing_fields.append((r['index'], r['title'], 'prompt'))
    if not r['has_negative']: missing_fields.append((r['index'], r['title'], 'negative_prompt'))

print(f"Components with missing fields: {len(missing_fields)}")
if missing_fields:
    for mf in missing_fields:
        print(f"  Missing: {mf}")

invalid_paths = [r for r in records if not (r['path'] and r['path'].startswith('design/components/'))]
print(f"Invalid paths (<design/components/): {len(invalid_paths)}")
if invalid_paths:
    for ip in invalid_paths:
        print(f"  Invalid path: {ip['title']} -> {ip['path']}")

filenames = [r['filename'] for r in records if r['filename']]
dup_filenames = set([x for x in filenames if filenames.count(x) > 1])
print(f"Duplicate filenames: {dup_filenames}")

paths = [r['path'] for r in records if r['path']]
dup_paths = set([x for x in paths if paths.count(x) > 1])
print(f"Duplicate paths: {dup_paths}")

mismatched_paths = [r for r in records if r['path'] and r['filename'] and not r['path'].endswith('/' + r['filename'])]
print(f"Mismatched path vs filename: {len(mismatched_paths)}")
if mismatched_paths:
    for mp in mismatched_paths:
        print(f"  Mismatched: {mp['filename']} vs {mp['path']}")

# Check filename pattern: <screen_number>_<screen_name>_<component_name>.png
naming_pattern = re.compile(r'^(0[0-8][a-e]?)_([a-z0-9_]+)\.png$')
non_conforming_names = [r for r in records if r['filename'] and not naming_pattern.match(r['filename'])]
print(f"Non-conforming filenames: {len(non_conforming_names)}")
if non_conforming_names:
    for ncn in non_conforming_names:
        print(f"  Non-conforming: {ncn['filename']}")

# Check prompt uniqueness
prompts = [r['prompt_text'] for r in records if r['prompt_text']]
dup_prompts = set([x for x in prompts if prompts.count(x) > 1])
print(f"Duplicate prompts: {dup_prompts}")

prompt_lens = [r['prompt_len'] for r in records]
print(f"Prompt character lengths: min={min(prompt_lens)}, max={max(prompt_lens)}, avg={sum(prompt_lens)/len(prompt_lens):.1f}")

# Check pairwise Jaccard similarity across visual prompts (excluding boilerplate/shared tokens)
words_per_prompt = [set(re.findall(r'\b[a-zA-Z]{3,}\b', p.lower())) for p in prompts]
high_similarity_pairs = []
for i in range(len(words_per_prompt)):
    for j in range(i + 1, len(words_per_prompt)):
        s1 = words_per_prompt[i]
        s2 = words_per_prompt[j]
        jaccard = len(s1 & s2) / len(s1 | s2)
        if jaccard > 0.80:
            high_similarity_pairs.append((records[i]['filename'], records[j]['filename'], jaccard))

print(f"High similarity prompt pairs (>0.80 Jaccard): {len(high_similarity_pairs)}")
if high_similarity_pairs:
    for p1, p2, score in high_similarity_pairs:
        print(f"  Pair ({score:.2f}): {p1} <-> {p2}")

# Check screens coverage
screens_found = set()
for r in records:
    fn = r['filename']
    m = re.match(r'^(0[0-8][a-e]?)_', fn)
    if m:
        screens_found.add(m.group(1))

print(f"Screens covered: {sorted(list(screens_found))}")
