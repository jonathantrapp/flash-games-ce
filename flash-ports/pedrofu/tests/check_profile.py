"""Execute native profile.c and compare it with original AS3 rules.

Calculator file I/O is stubbed; numerical gameplay/progression functions are real.
"""
from pathlib import Path
import json, math, os, re, subprocess

HERE=Path(__file__).resolve().parent
GAME=HERE.parent
ROOT=GAME.parents[1]
ORIGINAL=GAME/'original/scripts/xplor'
stub=HERE/'stubs';stub.mkdir(exist_ok=True)
for name in ['tice.h','graphx.h','keypadc.h']:(stub/name).write_text('/* Host parity test: no calculator interfaces used. */\n')
(stub/'fileioc.h').write_text('''#include <stddef.h>
#include <stdint.h>
static inline uint8_t ti_Open(const char*a,const char*b){(void)a;(void)b;return 0;}
static inline size_t ti_Read(void*a,size_t b,size_t c,uint8_t d){(void)a;(void)b;(void)c;(void)d;return 0;}
static inline size_t ti_Write(const void*a,size_t b,size_t c,uint8_t d){(void)a;(void)b;(void)d;return c;}
static inline size_t ti_GetSize(uint8_t a){(void)a;return 0;}
static inline void ti_Close(uint8_t a){(void)a;}
static inline void ti_SetArchiveStatus(int a,uint8_t b){(void)a;(void)b;}
''')
source='''#include "../src/game.h"
static int parity_rand(void){return 99;}
#define rand parity_rand
#include "../src/profile.c"
Game g;
int clampi(int v,int lo,int hi){return v<lo?lo:v>hi?hi:v;}
static void reset(void){memset(&progress,0,sizeof progress);memset(&g,0,sizeof g);}
int main(void){
 int actions[]={PA_PUNCH,PA_DASH,PA_CARRY,PA_PILEDRIVE,PA_PEDROKEN,PA_JUMPKICK,PA_DIVEKICK,PA_CHARGEKICK,PA_TORNADO,PA_FURYPICK};
 for(int p=0;p<231;p++)for(int m=0;m<8;m++){
  reset();for(int i=0;i<45;i++)progress.skills[i]=p<6?p:(i==(p-6)/5?(p-6)%5+1:0);
  g.berserk=m&1;g.rage=m&2;g.hp=m&4?maxlife():100;g.fury=m&4?maxfury():0;
  for(int t=0;t<10;t++)printf("D %d %d %d %d\\n",p,m,t,skill_damage(actions[t]));
  if(!m)for(int i=0;i<45;i++)printf("S %d %d %d\\n",p,i,skill_need(i));
 }
 for(int n=0;n<=15;n++){reset();for(int i=0;i<n;i++)progress.hearts[i]=progress.souls[i]=1;printf("M %d %d %d\\n",n,maxlife(),maxfury());}
 int gains[]={0,1,49,50,51,100,500,10000};
 for(int r=0;r<100;r+=7)for(int f=0;f<=5;f++)for(int a=0;a<8;a++){
  reset();progress.rank=r;progress.skills[FANCYFOOTWORK]=f;profile_xp(gains[a]);printf("X %d %d %d %d %d %d\\n",r,f,gains[a],progress.rank,progress.xp,progress.points);
 }
 reset();progress.rank=98;progress.xp=1020;profile_xp(10);printf("L %d %d %d\\n",progress.rank,progress.xp,progress.points);
 for(int rank=1;rank<=5;rank++){
  reset();progress.skills[FURYOVERLOAD]=rank;g.hp=100;g.fury=maxfury();
  for(int i=0;i<10;i++){add_fury(20);printf("F %d %d %d %d\\n",rank,i+1,g.hp,g.fury);}
 }
 return 0;
}
'''
(HERE/'profile_dump.c').write_text(source)
cache=HERE/'compiler-cache';cache.mkdir(exist_ok=True)
env=dict(os.environ,ZIG_LOCAL_CACHE_DIR=str(cache/'local'),ZIG_GLOBAL_CACHE_DIR=str(cache/'global'),TMP=str(cache),TEMP=str(cache))
subprocess.run([str(ROOT/'local-tools/ziglang/zig.exe'),'cc','-O1','-I'+str(stub),str(HERE/'profile_dump.c'),'-o',str(HERE/'profile_dump.exe')],check=True,env=env)
run=subprocess.run([str(HERE/'profile_dump.exe')],check=True,capture_output=True,text=True)

skilltext=(ORIGINAL/'Menus/SkillDef.as').read_text()
ids={k:int(v) for k,v in re.findall(r'const (\w+):uint = (\d+)',skilltext)}
functions={}
for m in re.finditer(r'public static function (\w+)\([^)]*\)\s*:\s*Number\s*\{',skilltext):
 start=m.end();end=start;depth=1
 while depth:depth+=(skilltext[end]=='{')-(skilltext[end]=='}');end+=1
 body=skilltext[start:end]
 returns=re.findall(r'\breturn ([^;]+);',body)
 if returns:functions[m[1]]=(body,returns[-1])

def expression(expr,skills,pts=None):
 expr=re.sub(r'Profile\.skills\[(?:SkillDef\.)?(\w+)\]',lambda m:str(skills[ids[m[1]]]),expr)
 expr=re.sub(r'([A-Za-z]+)\(\)',lambda m:str(evaluate(m[1],skills)),expr)
 if pts is not None:expr=re.sub(r'\bpts\b',str(pts),expr)
 if not re.fullmatch(r'[\d.eE+*/()\s-]+',expr):raise ValueError(expr)
 return eval(expr,{'__builtins__':{}},{})

def evaluate(name,skills):
 body,expr=functions[name];m=re.search(r'pts = int\(Profile\.skills\[(?:SkillDef\.)?(\w+)\]\)',body)
 pts=skills[ids[m[1]]] if m else skills[ids['FURIOUSBLAST']] if name=='FuriousBlastDamage' else None
 return expression(expr,skills,pts)

names=['PunchDamage','BurroBashDamage','ThrowDamage','PiledriverDamage','PedrokenDamage','JumpkickDamage','DiveKickDamage','ChargeKickDamage','TornadoKickDamage','FuriousBlastDamage']
layout=[]
for m in re.finditer(r'new SkillDef\("(?:\\.|[^"\\])*"\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*SkillDef\s*\.\s*(\w+)\)',(ORIGINAL/'Menus/SkillState.as').read_text()):
 layout.append((int(m[1]),int(m[2]),int(m[3]),ids[m[4]]))
assert len(layout)==45
base=(ORIGINAL/'Monster/BaseMonster.as').read_text()
multipliers=re.findall(r'dmg \*= ([^;]+);',base[base.index('override public function hurt('):])
rage=next(x for x in multipliers if 'RAGINGBURRO' in x);maximum=next(x for x in multipliers if 'MAXIMUMFORCE' in x)
profile=(ORIGINAL/'Profile.as').read_text()
xpneed=re.search(r'function XPNeed\(\).*?return ([^;]+);\s*\}',profile,re.S)[1]
# The first XPNeed return is level99's1; ordinary expression is the final return.
xpbody=profile[profile.index('function XPNeed('):profile.index('function GetXP(')]
xpformula=re.findall(r'return ([^;]+);',xpbody)[-1]
xpbonus=re.search(r'amt \*= ([^;]+);',profile)[1]
threshold=re.search(r'this\.excessFury > ([^)]*)\)',(ORIGINAL/'Pedro.as').read_text())[1]

checks=0;failures=[];rounding=[]
for line in run.stdout.splitlines():
 row=line.split();tag=row[0]
 if tag=='D':
  p,m,t,actual=map(int,row[1:]);skills=[p if p<6 else (p-6)%5+1 if i==(p-6)//5 else 0 for i in range(45)]
  expected=evaluate(names[t],skills)*100
  if m&1:expected*=2
  if m&2:expected*=expression(rage,skills)
  if m&4:expected*=expression(maximum,skills)
  checks+=1
  if abs(expected-actual)>2.01:failures.append(dict(kind='Damage',profile=p,modifiers=m,move=names[t],expected=expected,actual=actual))
  elif abs(expected-actual)>.00001:rounding.append(abs(expected-actual))
 elif tag=='S':
  p,i,actual=map(int,row[1:]);skills=[p if p<6 else (p-6)%5+1 if j==(p-6)//5 else 0 for j in range(45)]
  group,rank,_,_=layout[i];expected=3*rank-sum(skills[icon] for group2,rank2,col,icon in layout if group2==group and rank2<rank)
  checks+=1
  if expected!=actual:failures.append(dict(kind='Prerequisite',profile=p,skill=i,expected=expected,actual=actual))
 elif tag=='M':
  n,life,fury=map(int,row[1:]);checks+=2
  if life!=(5+n)*100 or fury!=min(1+n,5)*100:failures.append(dict(kind='Maxima',collected=n,life=life,fury=fury))
 elif tag=='X':
  r,f,n,actual_rank,actual_xp,actual_points=map(int,row[1:]);skills=[0]*45;skills[ids['FANCYFOOTWORK']]=f
  expected_xp=int(n*expression(xpbonus.replace('skills[SkillDef.FANCYFOOTWORK]','Profile.skills[SkillDef.FANCYFOOTWORK]'),skills));need=eval(xpformula,{'__builtins__':{}},{'level':r})
  expected_rank=r;points=0
  if expected_xp>=need:expected_xp-=need;expected_rank+=1;points=1
  if expected_rank==99:expected_xp=1
  checks+=1
  if (actual_rank,actual_xp,actual_points)!=(expected_rank,expected_xp,points):failures.append(dict(kind='XP',rank=r,fancy=f,gain=n,expected=[expected_rank,expected_xp,points],actual=[actual_rank,actual_xp,actual_points]))
 elif tag=='L':
  actual=list(map(int,row[1:]));checks+=1
  if actual!=[99,1,1]:failures.append(dict(kind='Level99',expected=[99,1,1],actual=actual))
 elif tag=='F':
  rank,count,hp,fury=map(int,row[1:]);skills=[0]*45;skills[ids['FURYOVERLOAD']]=rank
  lim=expression(threshold,skills)*100;excess=count*20;heals=0
  while excess>lim+1e-8:heals+=1;excess-=lim
  expected_hp=min(100+heals*100,500);checks+=1
  if hp!=expected_hp:failures.append(dict(kind='FuryOverload',rank=rank,gains=count,expected_hp=expected_hp,actual_hp=hp))
result=dict(checks=checks,failures=failures,rounding_cases=len(rounding),maximum_accepted_rounding=max(rounding,default=0),
            limitations='Runs actual native profile.c with fileIO stubs. Allows up to2.01 hundredths fixed-point damage quantization. Does not prove move timings, hitboxes, enemy AI or save IO.')
(HERE/'profile-results.json').write_text(json.dumps(result,indent=2))
from collections import Counter
print(checks,'checks;',len(failures),'differences:',dict(Counter(x['kind'] for x in failures)))
for f in failures[:12]:print(f)
raise SystemExit(bool(failures))
