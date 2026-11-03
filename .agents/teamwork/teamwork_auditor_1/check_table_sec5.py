import re

with open('design/ui_generation_plan.md', 'r') as f:
    lines = f.readlines()

table_lines = [line.strip() for line in lines[100:172] if line.strip().startswith('|')]

table_records = []
for line in table_lines:
    cols = [c.strip() for c in line.split('|')[1:-1]]
    table_records.append({
        'screen': cols[0],
        'name': cols[1],
        'filename': cols[2].strip('`'),
        'aspect_ratio': cols[3],
        'dimensions': cols[4],
        'summary': cols[5]
    })

print(f"Table rows in Section 4: {len(table_records)}")

with open('design/ui_generation_plan.md', 'r') as f:
    text = f.read()

comp_splits = re.split(r'\n#### Component: ', text)[1:]
sec5_records = []
for comp in comp_splits:
    fn = re.search(r'-\s*\*\*Filename\*\*:\s*`?([^\n`]+)`?', comp).group(1)
    path = re.search(r'-\s*\*\*Output Path\*\*:\s*`?([^\n`]+)`?', comp).group(1)
    ar = re.search(r'-\s*\*\*Aspect Ratio\*\*:\s*`?([^\n`]+)`?', comp).group(1)
    dims = re.search(r'-\s*\*\*Target Dimensions\*\*:\s*`?([^\n`]+)`?', comp).group(1)
    sec5_records.append({
        'filename': fn,
        'path': path,
        'aspect_ratio': ar,
        'dimensions': dims.replace('px', '').replace('`', '').strip()
    })

print(f"Section 5 component specs: {len(sec5_records)}")

table_filenames = [r['filename'] for r in table_records]
sec5_filenames = [r['filename'] for r in sec5_records]

diff1 = set(table_filenames) - set(sec5_filenames)
diff2 = set(sec5_filenames) - set(table_filenames)

print(f"Filenames in Table but not in Sec 5: {diff1}")
print(f"Filenames in Sec 5 but not in Table: {diff2}")

order_match = table_filenames == sec5_filenames
print(f"Exact sequence / order match between Table and Sec 5: {order_match}")

mismatches = []
for t, s in zip(table_records, sec5_records):
    if t['filename'] == s['filename']:
        if t['aspect_ratio'] != s['aspect_ratio']:
            mismatches.append((t['filename'], 'AR', t['aspect_ratio'], s['aspect_ratio']))
        if t['dimensions'] != s['dimensions']:
            mismatches.append((t['filename'], 'Dims', t['dimensions'], s['dimensions']))

print(f"Metadata mismatches between Table and Sec 5: {len(mismatches)}")
if mismatches:
    for m in mismatches:
        print(f"  Mismatch: {m}")
