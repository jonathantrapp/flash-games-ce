"""Open every stage of each port in windowless CEmu and record whether it loads and keeps running.

This is a crash/launch smoke test only. It proves a stage can be entered through the QA path (hold VARS
on the map/menu) and that the program is still in the expected state after a few seconds of input; it
says nothing about whether the stage can be won.
Usage: python verify_stages.py [scoutcamp|pedrofu ...]
"""
import subprocess
import sys
import argparse
import hashlib
from pathlib import Path

HERE = Path(__file__).resolve().parent
GAMES = {
    # game: (stage count, steps to open stage k, check for stage k, extra play steps)
    'scoutcamp': (17, lambda k: 'enter down:vars ' + ('right*%d ' % k if k else '') + 'enter up:vars enter wait:200 2nd right*2 2nd graph wait:1500',
                  lambda k: ['scout_diag+1:%d:1' % k, 'scout_diag:1:1']),
    'pedrofu': (15, lambda k: 'enter down:vars ' + ('right*%d ' % k if k else '') + 'enter up:vars ' + ('wait:18000 ' if k==0 else 'wait:300 ') + 'enter wait:300 enter hold:right:1500 2nd hold:right:800 alpha wait:600',
                lambda k: ['pedro_diag+1:%d:1' % k, 'pedro_diag:1,3,4,7,8:1']),
}
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('games',nargs='*',choices=list(GAMES));p.add_argument('--tag',default='continuation')
a=p.parse_args();games=a.games or list(GAMES)
assert a.tag and all(c.isalnum() or c in '-_' for c in a.tag)
rows = []
for game in games:
    count, steps, checks = GAMES[game]
    for k in range(count):
        scenario = a.tag+'_stage%02d' % (k + 1)
        command = [sys.executable, str(HERE / 'run_scenario.py'), game, scenario, steps(k),'--tap','500']
        for c in checks(k):
            command += ['--check', c]
        result = subprocess.run(command, capture_output=True, text=True)
        text = result.stdout + result.stderr
        passed = result.returncode == 0 and 'Autotest passed' in text
        rows.append((game, k + 1, 'pass' if passed else 'FAIL'))
        print(game, scenario, rows[-1][2], flush=True)
lines = ['# Stage launch smoke results', '', 'Each stage was opened in windowless CEmu through the QA stage-select path and played for a few seconds.',
         'This checks launch and an expected gameplay/dialogue/result state only, not completability. NMI resets fail even if diagnostic bytes match.', '',
         'Binary SHA-256: '+', '.join(game+' '+hashlib.sha256((HERE/game/'bin'/({'scoutcamp':'SCOUTCE','pedrofu':'PEDROCE'}[game]+'.8xp')).read_bytes()).hexdigest() for game in games),
         '', '| Game | Stage | Result |', '| --- | --- | --- |']
lines += ['| %s | %d | %s |' % row for row in rows]
(HERE / 'verification' / ('STAGE-SMOKE-'+a.tag+'-'+ '-'.join(games)+'.md')).write_text('\n'.join(lines) + '\n', encoding='utf-8')
print('failures:', sum(r[2] != 'pass' for r in rows))
raise SystemExit(any(r[2]!='pass' for r in rows))
