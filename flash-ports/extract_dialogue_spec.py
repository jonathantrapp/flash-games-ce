"""Recover original Pedro conversation pages and their precise event branches."""
from pathlib import Path
import json
import re

root = Path(__file__).resolve().parent
path = root / 'pedrofu/original/scripts/xplor/Conversation.as'
source = path.read_text()
setup = source.index('public function Setup(')
end = source.index('public function End(')
button = source.index('public function ButtonHit(')
update = source.index('override public function update(')
events = {str(i): {'event': i, 'initial': [], 'followups': []} for i in range(12)}
for start, stop, phase in [(setup, end, 'initial'), (button, update, 'followups')]:
    section = source[start:stop]
    cases = list(re.finditer(r'case (\d+):', section))
    for ix, case in enumerate(cases):
        event = case[1]
        body = section[case.end():cases[ix+1].start() if ix+1 < len(cases) else len(section)]
        base = start + case.end()
        for match in re.finditer(r'this\.SetBubble\((.*?),"((?:\\.|[^"\\])*)"\);', body):
            before = body[:match.start()]
            states = list(re.finditer(r'this\.status == (\d+)', before))
            state = int(states[-1][1]) if states else 0
            events[event][phase].append({
                'status': state,
                'speaker_and_position': match[1],
                'text': match[2].replace("\\'", "'").replace('\\"', '"'),
                'line': source[:base+match.start()].count('\n') + 1,
            })
        events[event][phase + '_branch_source'] = body.strip()
triggers = []
for f in sorted((root / 'pedrofu/original/scripts/xplor').rglob('*.as')):
    data = f.read_text()
    for m in re.finditer(r'conversation\.Setup\((\d+),([^)]*)\)', data):
        line = data[:m.start()].count('\n') + 1
        lines = data.splitlines()
        triggers.append({'event': int(m[1]), 'other': m[2],
                         'file': str(f.relative_to(root)), 'line': line,
                         'context': '\n'.join(lines[max(0,line-12):line+6])})
result = {'source': str(path.relative_to(root)), 'events': list(events.values()),
          'triggers': triggers,
          'global_rules': {'setup': 'Global.conversation=true; status=0; camera detaches; bubble/words visible',
                           'end': 'Global.conversation=false; camera follows Pedro; bubble/words hidden',
                           'continue': 'B2 or B3 or Escape edge, increments status and executes ButtonHit branch',
                           'freezes': 'Arena.Update returns while conversation; most gameplay BasicUpdate blocked',
                           'source_note': 'Followup branches retained verbatim to preserve non-dialogue effects; page status inferred from preceding explicit status condition.'}}
(root / 'pedro-dialogue-spec.json').write_text(json.dumps(result, indent=2))
print('Recovered', sum(len(e['initial'])+len(e['followups']) for e in events.values()), 'pages across 12 events,', len(triggers), 'triggers')
