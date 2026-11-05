"""Make small source-bound mechanics indexes for porting and parity review."""
from pathlib import Path
import json
import re
root = Path(__file__).resolve().parent
for game in ['scoutcamp', 'pedrofu']:
    base = root / game / 'original/scripts/xplor'
    records = []
    for path in sorted(base.rglob('*.as')):
        if 'Image' in path.stem or path.stem.startswith('Sounds_'):
            continue
        source = path.read_text()
        functions = []
        for m in re.finditer(r'(?:public|protected|private)(?:\s+(?:static|override))*\s+function\s+(\w+)\s*\([^)]*\)\s*(?::\s*[\w.]+)?\s*\{', source):
            start = m.end() - 1
            depth, end = 1, start + 1
            # AS3 function bodies here do not contain structural braces inside strings
            # that affect these selected method inventories.
            while end < len(source) and depth:
                depth += (source[end] == '{') - (source[end] == '}')
                end += 1
            body = source[start:end]
            functions.append({'name': m[1], 'line': source[:m.start()].count('\n')+1,
                              'returns': re.findall(r'\breturn\s+([^;]+);', body),
                              'body': body})
        records.append({'file': str(path.relative_to(base)), 'functions': functions})
    (root / (game + '-mechanics-spec.json')).write_text(json.dumps(records, indent=2))
    print(game, len(records), 'files indexed')
