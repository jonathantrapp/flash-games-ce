"""Compare native descriptions with original AS3 over ranks/profile bonuses.

Hardware is not used. Output buffers are guarded, including zero/tiny capacities.
The only accepted text differences are <=0.01 numeric Flash floating roundoff;
key labels deliberately map X/C to ALPHA/DEL. This does not test screen layout.
"""
from pathlib import Path
import ast, hashlib, json, os, random, re, subprocess

HERE=Path(__file__).resolve().parent;GAME=HERE.parent;ROOT=GAME.parents[1]
original=(GAME/'original/scripts/xplor/Menus/SkillDef.as').read_text()
ids={k:int(v) for k,v in re.findall(r'const (\w+):uint = (\d+)',original)}
functions={}
for match in re.finditer(r'public static function (\w+)\([^)]*\)\s*:\s*Number\s*\{',original):
 start=end=match.end();depth=1
 while depth:depth+=(original[end]=='{')-(original[end]=='}');end+=1
 body=original[start:end];default=re.search(r'pts = int\(Profile.skills\[(?:SkillDef\.)?(\w+)\]\)',body)
 functions[match[1]]=(re.findall(r'return ([^;]+);',body)[-1],ids[default[1]] if default else None)


def evaluate(source,skills,pts):
 source=re.sub(r'Profile.skills\[(?:SkillDef\.)?(\w+)\]',lambda m:'skills[%d]'%ids[m[1]],source)
 def visit(node):
  if isinstance(node,ast.Constant):return node.value
  if isinstance(node,ast.Name)and node.id=='pts':return pts
  if isinstance(node,ast.Subscript)and isinstance(node.value,ast.Name)and node.value.id=='skills':return skills[node.slice.value]
  if isinstance(node,ast.UnaryOp)and isinstance(node.op,ast.USub):return -visit(node.operand)
  if isinstance(node,ast.BinOp):
   a,b=visit(node.left),visit(node.right)
   if isinstance(node.op,ast.Add):return a+b
   if isinstance(node.op,ast.Sub):return a-b
   if isinstance(node.op,ast.Mult):return a*b
   if isinstance(node.op,ast.Div):return a/b
  if isinstance(node,ast.Call)and isinstance(node.func,ast.Name):
   formula,default=functions[node.func.id]
   point=visit(node.args[0])if node.args else skills[default]if default is not None else -1
   return evaluate(formula,skills,point)
  raise ValueError(ast.dump(node))
 return visit(ast.parse(source,mode='eval').body)


def expected(source,skills,pts):
 quote=escape=False;depth=0;start=0;terms=[]
 for i,char in enumerate(source):
  if escape:escape=False;continue
  if quote and char=='\\':escape=True;continue
  if char=='"':quote=not quote
  if quote:continue
  if char=='(':depth+=1
  if char==')':depth-=1
  if char=='+'and not depth:terms.append(source[start:i].strip());start=i+1
 terms.append(source[start:].strip());out=''
 for term in terms:
  if term.startswith('"'):out+=json.loads(term.replace("\\'","'"))
  else:
   if term.endswith('.toString()'):term=term[:-11]
   kind,inner=term.split('(',1);value=evaluate(inner[:-1],skills,max(1,pts))
   out+=str(int(value))if kind=='int'else format(int(value*100)/100,'.12g')
 return re.sub(r'\bC\b','DEL',re.sub(r'\bX\b','ALPHA',out))


cases={ids[name]:source for name,source in re.findall(r'case (\w+):\s*return (.*?);',original,re.S)}
assert len(cases)==45
profiles=[[rank]*45 for rank in range(6)]
profiles += [[5 if i==chosen else 0 for i in range(45)]for chosen in range(45)]
rng=random.Random(20261106);profiles += [[rng.randrange(6)for i in range(45)]for j in range(16)]
source='''#include "../src/game.h"
#define snprintf pd_snprintf
#include "../src/small_format.c"
#include "../src/skill_descriptions.h"
Progress progress;
static const uint8_t profiles[][45]={PROFILE_DATA};
int main(void){unsigned failures=0;char guarded[416];
 for(unsigned p=0;p<sizeof profiles/sizeof profiles[0];p++){
  memcpy(progress.skills,profiles[p],45);
  for(int id=0;id<45;id++)for(int rank=0;rank<=5;rank++){
   unsigned capacities[]={0,1,2,64,384};
   for(int c=0;c<5;c++){
    memset(guarded,0x6b,sizeof guarded);skill_description(id,rank,guarded+16,capacities[c]);
    for(unsigned i=0;i<sizeof guarded;i++)if((i<16||i>=16+capacities[c])&&guarded[i]!=0x6b)failures++;
    if(capacities[c]&&guarded[16+capacities[c]-1]!=0&&strlen(guarded+16)>=capacities[c])failures++;
   }
   printf("%u\\t%d\\t%d\\t%s\\n",p,id,rank,guarded+16);
  }
 }
 printf("CANARY %u\\n",failures);return failures!=0;
}
'''.replace('PROFILE_DATA',','.join('{'+','.join(map(str,p))+'}'for p in profiles))
(HERE/'skill_descriptions_dump.c').write_text(source)
cache=HERE/'compiler-cache';cache.mkdir(exist_ok=True)
env=dict(os.environ,ZIG_LOCAL_CACHE_DIR=str(cache/'local'),ZIG_GLOBAL_CACHE_DIR=str(cache/'global'),TMP=str(cache),TEMP=str(cache))
subprocess.run([str(ROOT/'local-tools/ziglang/zig.exe'),'cc','-O1','-I'+str(HERE/'stubs'),str(HERE/'skill_descriptions_dump.c'),'-o',str(HERE/'skill_descriptions_dump.exe')],check=True,env=env)
run=subprocess.run([str(HERE/'skill_descriptions_dump.exe')],capture_output=True,text=True,check=True)
checks=roundoff=0;failures=[];maximum_length=0
for line in run.stdout.splitlines():
 if line.startswith('CANARY '):assert line=='CANARY 0';continue
 p,id,rank,text=line.split('\t',3);p,id,rank=map(int,(p,id,rank));wanted=expected(cases[id],profiles[p],rank)
 checks+=1;maximum_length=max(maximum_length,len(text))
 if text==wanted:continue
 actual_parts=re.split(r'(\d+(?:\.\d+)?)',text);wanted_parts=re.split(r'(\d+(?:\.\d+)?)',wanted)
 if len(actual_parts)==len(wanted_parts)and actual_parts[::2]==wanted_parts[::2]and all(abs(float(a)-float(b))<=.010001 for a,b in zip(actual_parts[1::2],wanted_parts[1::2])):roundoff+=1
 else:failures.append(dict(profile=p,skill=id,rank=rank,actual=text,expected=wanted))
result=dict(checks=checks,failures=failures,accepted_flash_roundoff_cases=roundoff,maximum_description_bytes=maximum_length,
 guarded_capacities=[0,1,2,64,384],source_sha256=hashlib.sha256(original.encode()).hexdigest(),
 generated_sha256=hashlib.sha256((GAME/'src/skill_descriptions.h').read_bytes()).hexdigest(),
 formatter_sha256=hashlib.sha256((GAME/'src/small_format.c').read_bytes()).hexdigest(),
 scope='All45 original descriptions, ranks0..5,67 modifier profiles; original text with CE key labels; numeric Flash roundoff tolerance0.01; actual native generated C, not UI rendering.')
(HERE/'skill-description-results.json').write_text(json.dumps(result,indent=2))
print(checks,'descriptions;',len(failures),'failures;',roundoff,'Flash roundoff cases; maximum',maximum_length,'bytes; guarded capacities passed')
for failure in failures[:5]:print(failure)
raise SystemExit(bool(failures))
