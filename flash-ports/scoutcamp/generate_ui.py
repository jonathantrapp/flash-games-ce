"""Extract original campaign locations, tip art choices, ending and skill descriptions."""
from pathlib import Path
import re,json,ast,operator
root=Path(__file__).parent
skill=(root/'original/scripts/xplor/Menus/SkillDef.as').read_text();ids=dict((k,int(v))for k,v in re.findall(r'public static const (\w+):uint = (\d+)',skill))
def arithmetic(s,rank):
 tree=ast.parse(s,mode='eval')
 for n in ast.walk(tree):
  assert isinstance(n,(ast.Expression,ast.BinOp,ast.UnaryOp,ast.Constant,ast.Name,ast.Load,ast.Add,ast.Sub,ast.Mult,ast.Div,ast.USub,ast.UAdd)),ast.dump(n)
  if isinstance(n,ast.Name):assert n.id=='param1'
 return eval(compile(tree,'<original arithmetic>','eval'),{'__builtins__':{}},{'param1':rank})
def terms(s):
 quote=escape=False;depth=0;last=0;out=[]
 for i,c in enumerate(s):
  if escape:escape=False;continue
  if c=='\\' and quote:escape=True;continue
  if c=='"':quote=not quote
  if quote:continue
  if c=='(':depth+=1
  if c==')':depth-=1
  if c=='+' and depth==0:out.append(s[last:i].strip());last=i+1
 out.append(s[last:].strip());return out
def describe(s,rank):
 out=''
 for t in terms(s):
  if t.startswith('"'):out+=json.loads(t.replace("\\'","'"))
  elif t.startswith('Str('):out+=format(int(arithmetic(t[4:-1],rank)*100)/100,'.12g')
  elif t.startswith('int(')and t.endswith(').toString()'):out+=str(int(arithmetic(t[4:-12],rank)))
  else:raise AssertionError(t)
 return out
cases=re.findall(r'case (\w+):\s*return (.*?);',skill,re.S);assert len(cases)==48
blob=bytearray();offsets=[[0]*5 for _ in range(48)]
for name,expr in cases:
 for rank in range(1,6):
  text=describe(expr,rank);offsets[ids[name]][rank-1]=len(blob);blob+=text.encode('ascii')+b'\0'
assert len(blob)<32000
(root/'build-art/skill-text.bin').write_bytes(blob)
(root/'src/skill_text_index.h').write_text('static const uint16_t skillTextOffsets[48][5]={'+','.join('{'+','.join(map(str,row))+'}'for row in offsets)+'};\n')
source=(root/'original/scripts/xplor/Menus/MapState.as').read_text();nodes=re.findall(r'new Map_X\((\d+),(\d+),new Array\(([^)]+)\)\)',source);assert len(nodes)==17
out=['static const uint16_t mapNodes[17][2]={'+','.join('{%s,%s}'%(x,y)for x,y,d in nodes)+'};'];flat=[];starts=[0]
for x,y,d in nodes:flat+=list(map(int,d.split(',')));starts.append(len(flat)//2)
out+=['static const uint16_t mapDotStarts[18]={'+','.join(map(str,starts))+'};','static const uint16_t mapDots[][2]={'+','.join('{%d,%d}'%(flat[i],flat[i+1])for i in range(0,len(flat),2))+'};']
tips=(root/'original/scripts/xplor/Menus/LevelTip.as').read_text();modes=re.findall(r'new Array\((NONE|BEWARE|SPECIAL)\s*,(\d+),"',tips);assert len(modes)==17
out+=['static const uint8_t tipModes[17]={'+','.join(str({'NONE':0,'BEWARE':1,'SPECIAL':2}[m])for m,i in modes)+'};','static const uint8_t tipArt[17]={'+','.join(i for m,i in modes)+'};']
win=(root/'original/scripts/xplor/Menus/WinState.as').read_text();expr=re.search(r'new FlxText\(0,60,320,(.*?)\);',win,re.S)[1];text=''.join(json.loads(t.replace("\\'","'"))for t in terms(expr))
out+=['static const char endingText[]='+json.dumps(text)+';']
(root/'src/menu_data.h').write_text('\n'.join(out));print('48x5 original skill descriptions:',len(blob),'bytes;17mapnodes+%ddots;17tipartchoices;originalending'%(len(flat)//2))
