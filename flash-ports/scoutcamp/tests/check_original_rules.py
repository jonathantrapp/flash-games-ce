"""Compare actual native rule results against independently evaluated original AS3.

This checks source-derived stat values, including ActionScript int return coercion.
It does not establish projectile/AI behavior parity.
"""
from pathlib import Path
import json
import re
import subprocess
import math
import os

HERE = Path(__file__).resolve().parent
GAME = HERE.parent
ROOT = GAME.parents[1]
ORIGINAL = GAME / 'original/scripts/xplor'
TOWERS = ['Rock','Roll','Snow','Shock','Sling','Soapbox','Crusher','Quake','Ice','Slushee','Crippler','LightningRod']
MONSTERS = ['Lumpy','Squirmy','Beefy','Beasty','Wormy','Speedy','Blinky','Scary','Hungry','HungryBaby']
FIELDS = ['DamageCalc','RangeCalc','ReloadCalc','SecondCalc','UpgradePrice','BasePrice']
skilltext = (ORIGINAL / 'Menus/SkillDef.as').read_text()
skillids = {k:int(v) for k,v in re.findall(r'const (\w+):uint = (\d+)', skilltext)}
methods = {}
for cls in ['Tower'] + ['Tower_'+n for n in TOWERS] + MONSTERS:
    source = (ORIGINAL / ('Monster/'+cls+'.as')).read_text()
    for m in re.finditer(r'public static function (\w+)\([^)]*\)\s*:\s*(\w+)\s*\{\s*return ([^;]+);', source):
        methods[cls,m[1]] = (m[2], m[3], source[:m.start()].count('\n')+1)

def evaluate(cls, field, level, skills):
    typ, expr, _ = methods.get((cls,field), methods.get(('Tower',field), (None,None,None)))
    if expr is None:
        raise ValueError((cls,field))
    expr = re.sub(r'Profile\.skills\[SkillDef\.(\w+)\]', lambda m:str(skills[skillids[m[1]]]), expr)
    expr = re.sub(r'(Tower_\w+)\.(\w+)\(param1\)', lambda m:str(evaluate(m[1],m[2],level,skills)), expr)
    expr = expr.replace('param1',str(level))
    if not re.fullmatch(r'[\d.eE+*/()\s-]+', expr):
        raise ValueError('Unrecognized expression '+expr)
    result = eval(expr, {'__builtins__':{}}, {})
    return int(result) if typ in ('int','uint') else float(result)

engine=(GAME/'src/engine.h').read_text()
start=engine.index('static int skillNeeded(')
brace=engine.index('{',start);depth=1;end=brace+1
while depth:
    depth+=(engine[end]=='{')-(engine[end]=='}');end+=1
skill_function=engine[start:end]
skill_layout=[]
for m in re.finditer(r'new SkillDef\("(?:\\.|[^"\\])*"\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*SkillDef\.(\w+)\)',(ORIGINAL/'Menus/SkillState.as').read_text()):
    skill_layout.append((int(m[1]),int(m[2]),int(m[3]),skillids[m[4]]))
assert len(skill_layout)==48

source = '''#include <stdint.h>
#include <stdio.h>
#include "../src/rules.h"
uint8_t skills[48];
SKILL_FUNCTION
int main(void) {
 for(int p=0;p<246;p++) {
  for(int s=0;s<48;s++) skills[s]=p<6?p:((s==(p-6)/5)?(p-6)%5+1:0);
  for(int s=0;s<48;s++)printf("S %d %d %d\\n",p,s,skillNeeded(s));
  for(int t=0;t<12;t++)for(int l=0;l<6;l++) {
   printf("T %d %d %d %.9g %.9g %.9g %.9g %.9g %.9g\\n",p,t,l,
     (double)rule_DamageCalc(t,l),(double)rule_RangeCalc(t,l),
     (double)rule_ReloadCalc(t,l),(double)rule_SecondCalc(t,l),
     (double)rule_UpgradePrice(t,l),(double)rule_BasePrice(t,l));
  }
 }
 for(int t=0;t<10;t++)for(int l=0;l<65;l++)
  printf("M %d %d %d %d %d\\n",t,l,monster_Life(t,l),monster_Money(t,l),monsterSpeed[t]);
 return 0;
}
'''.replace('SKILL_FUNCTION',skill_function)
(HERE/'rules_dump.c').write_text(source)
zig = ROOT / 'local-tools/ziglang/zig.exe'
cache=HERE/'compiler-cache';cache.mkdir(exist_ok=True)
env=dict(os.environ,ZIG_LOCAL_CACHE_DIR=str(cache/'local'),ZIG_GLOBAL_CACHE_DIR=str(cache/'global'),TMP=str(cache),TEMP=str(cache))
subprocess.run([str(zig),'cc','-O1',str(HERE/'rules_dump.c'),'-o',str(HERE/'rules_dump.exe')],check=True,env=env)
run = subprocess.run([str(HERE/'rules_dump.exe')],check=True,capture_output=True,text=True)
failures, checks = [],0
for line in run.stdout.splitlines():
    row=line.split()
    if row[0]=='T':
        p,t,l=map(int,row[1:4]); skills=[p if p<6 else (p-6)%5+1 if s==(p-6)//5 else 0 for s in range(48)]
        for field,actual in zip(FIELDS,map(float,row[4:])):
            expected=evaluate('Tower_'+TOWERS[t],field,l,skills); checks+=1
            if not math.isclose(actual,expected,rel_tol=2e-6,abs_tol=2e-6):
                failures.append(dict(profile=p,tower=TOWERS[t],level=l,field=field,expected=expected,actual=actual,
                                     source_line=methods.get(('Tower_'+TOWERS[t],field),methods.get(('Tower',field)))[2]))
    elif row[0]=='S':
        p,s,actual=map(int,row[1:]);skills=[p if p<6 else (p-6)%5+1 if i==(p-6)//5 else 0 for i in range(48)]
        group,rank,_,icon=skill_layout[s]
        prerequisite={skillids['LIGHTNINGROD']:skillids['SHOCKER'],skillids['CRIPPLER']:skillids['SHOCKER'],
                      skillids['ICELAUNCHER']:skillids['SNOWFORT'],skillids['SLUSHEE']:skillids['SNOWFORT'],
                      skillids['CRUSHER']:skillids['ROLYPOLY'],skillids['QUAKE']:skillids['ROLYPOLY']}.get(icon)
        expected=999 if prerequisite is not None and not skills[prerequisite] else 3*rank-sum(skills[i] for g,r,c,i in skill_layout if g==group and r<rank)
        checks+=1
        if actual!=expected:failures.append(dict(profile=p,skill_index=s,field='PointsNeeded',actual=actual,expected=expected))
    else:
        t,l,life,money,speed=map(int,row[1:]);cls=MONSTERS[t]
        src=(ORIGINAL/('Monster/'+cls+'.as')).read_text()
        expected_speed=int(re.search(r'\bspeed = (\d+);',src)[1])
        for field,actual,expected in [('Life',life,evaluate(cls,'Life',l,[0]*48)),('Money',money,evaluate(cls,'Money',l,[0]*48)),('Speed',speed,expected_speed)]:
            checks+=1
            if actual!=expected:failures.append(dict(monster=cls,level=l,field=field,actual=actual,expected=expected))
result={'checks':checks,'failures':failures,'method':'Native compiled rules.h compared to original AS3 independently; includes int return coercion.'}
(HERE/'original-rules-results.json').write_text(json.dumps(result,indent=2))
print(f'{checks} checks, {len(failures)} differences')
for failure in failures[:15]:print(failure)
raise SystemExit(bool(failures))
