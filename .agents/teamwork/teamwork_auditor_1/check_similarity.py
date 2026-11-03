import re

with open('design/ui_generation_plan.md', 'r') as f:
    content = f.read()

comp_splits = re.split(r'\n#### Component: ', content)[1:]
records = []
for comp in comp_splits:
    fn = re.search(r'-\s*\*\*Filename\*\*:\s*`?([^\n`]+)`?', comp).group(1)
    prompt = re.search(r'\*\*Visual Prompt\*\*:\s*\n(>[\s\S]*?)(?=\n\*\*|\n###|\n####|\Z)', comp).group(1)
    words = set(re.findall(r'\b[a-zA-Z]{3,}\b', prompt.lower()))
    records.append((fn, prompt, words))

pairs = []
for i in range(len(records)):
    for j in range(i+1, len(records)):
        s1, s2 = records[i][2], records[j][2]
        jaccard = len(s1 & s2) / len(s1 | s2)
        pairs.append((jaccard, records[i][0], records[j][0], records[i][1], records[j][1]))

pairs.sort(reverse=True)
for score, f1, f2, p1, p2 in pairs[:5]:
    print(f"Similarity: {score:.3f} | {f1} <-> {f2}")
    print(f"  P1 excerpt: {p1[:100]}...")
    print(f"  P2 excerpt: {p2[:100]}...")
    print("-" * 50)
