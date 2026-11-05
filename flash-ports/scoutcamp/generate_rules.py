from pathlib import Path
import re
root=Path(__file__).parent
skill=(root/'original/scripts/xplor/Menus/SkillDef.as').read_text()
ids=re.findall(r'public static const (\w+):uint = (\d+)',skill)
state=(root/'original/scripts/xplor/Menus/SkillState.as').read_text()
entries=re.findall(r'new SkillDef\("((?:\\.|[^"\\])*)",(\d+),(\d+),(\d+),SkillDef\.(\w+)\)',state.replace('\n','').replace('\r','').replace('      ',''))
out=['/* Generated directly from the supplied SWF AS3 formulas. */','#ifndef SCOUT_RULES_H','#define SCOUT_RULES_H','enum { '+','.join('SK_'+k+'='+v for k,v in ids)+' };','typedef struct {const char *name;uint8_t group,rank,column,icon;} SkillRule;','static const SkillRule skillRules[]={']
for name,group,rank,col,icon in entries:out.append('{"%s",%s,%s,%s,SK_%s},'%(name.replace("\\'","'"),group,rank,col,icon))
out+=['};','extern uint8_t skills[48];','enum { ROCK,ROLL,SNOW,SHOCK,SLING,SOAPBOX,CRUSHER,QUAKE,ICE,SLUSHEE,CRIPPLER,LIGHTNING };']
names=['Rock','Roll','Snow','Shock','Sling','Soapbox','Crusher','Quake','Ice','Slushee','Crippler','LightningRod']
out.append('static const char *const towerNames[]={'+','.join('"'+re.search(r'name = "([^"]+)"',(root/('original/scripts/xplor/Monster/Tower_'+n+'.as')).read_text())[1]+'"' for n in names)+'};')
functions=['DamageCalc','RangeCalc','ReloadCalc','SecondCalc','UpgradePrice','BasePrice']
for field,fun in enumerate(functions):
 out.append('static float rule_'+fun+'(int type,int param1) { switch(type) {')
 for index,name in enumerate(names):
  s=(root/('original/scripts/xplor/Monster/Tower_'+name+'.as')).read_text();m=re.search(r'public static function '+fun+r'\([^)]*\) : \w+\s*\{\s*return ([^;]+);',s)
  expr=m[1] if m else ('1' if fun=='SecondCalc' else '0')
  expr=re.sub(r'Profile.skills\[SkillDef.(\w+)\]',r'skills[SK_\1]',expr)
  expr=re.sub(r'Tower_(\w+)\.(\w+)\(param1\)',lambda m:'rule_'+m[2]+'('+str(names.index(m[1]))+',param1)',expr)
  out.append('case %d:return %s;'%(index,expr))
 out.append('default:return 0;} }')
# Monster numeric formulas used directly rather than approximate health arrays.
monster=['Lumpy','Squirmy','Beefy','Beasty','Wormy','Speedy','Blinky','Scary','Hungry','HungryBaby']
for fun in ['Life','Money']:
 out.append('static int monster_'+fun+'(int type,int param1) {switch(type){')
 for i,name in enumerate(monster):
  s=(root/('original/scripts/xplor/Monster/'+name+'.as')).read_text();m=re.search(r'public static function '+fun+r'\(param1:int\) : int\s*\{\s*return ([^;]+);',s)
  out.append('case %d:return %s;'%(i,m[1] if m else '3+param1*2'))
 out.append('default:return 0;} }')
out.append('static const uint8_t monsterSpeed[]={'+','.join(re.search(r'speed = (\d+);',(root/('original/scripts/xplor/Monster/'+n+'.as')).read_text())[1] for n in monster)+'};')
out.append('static const uint8_t monsterHeight[]={'+','.join(re.search(r'height = (\d+);',(root/('original/scripts/xplor/Monster/'+n+'.as')).read_text())[1] for n in monster)+'};')
out.append('#endif')
(root/'src/rules.h').write_text('\n'.join(out));print(len(entries),'skills and all tower/monster formulas extracted')
