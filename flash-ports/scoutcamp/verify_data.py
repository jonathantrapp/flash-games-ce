"""Compare every packed map byte and every native wave group with the supplied SWF."""
import pathlib,re,zlib,struct,json
root=pathlib.Path(__file__).parent
s=(root/'src/data.h').read_text();packed=(root/'build-art/maps.bin').read_bytes()
def array(name):
 m=re.search(r'\b'+name+r'\[\]=\{([^}]*)\}',s);assert m,name
 return [int(x) for x in m[1].split(',') if x]
portals=0
for level in range(17):
 f=next((root/'assets/binaryData').glob('*Level%02d.bin'%(level+1)))
 raw=zlib.decompress(f.read_bytes());w,h=struct.unpack('>HH',raw[:4]);n=w*h
 meta=re.search(r'\blevel%d=\{(\d+),(\d+),(\d+),(\d+),(\d+),'%level,s)
 mw,mh,camp,count,p=map(int,meta.groups());assert (mw,mh)==(w,h)
 decoded=[]
 for layer in range(4):
  data=[]
  while len(data)<n:
   k,v=packed[p:p+2];p+=2;data.extend([v]*k)
  assert len(data)==n,('run crosses layer',level,layer)
  decoded+=data
 assert bytes(decoded)==raw[4:],('map mismatch',level)
 good=decoded[3*n:];expected=[i for i,v in enumerate(good) if v==1]
 assert count==len(expected) and camp==good.index(2)
 for j,start in enumerate(expected):assert array('portal%d_%d'%(level,j))==[start];portals+=1
source=(root/'original/scripts/xplor/WaveDef.as').read_text().split('waves:Array = ')[1].split(';')[0]
names=['Lumpy','Squirmy','Beefy','Beasty','Wormy','Speedy','Blinky','Scary','Hungry']
source=source.replace('new Array(', '[').replace(')',']')
for name in names:source=re.sub(r'\b'+name+r'\b','"'+name+'"',source)
waves=json.loads(source);groups=0
for i,stage in enumerate(waves):
 assert array('waveCounts')[i]==len(stage)-1
 assert array('waveTimes')[i]==stage[0]
 for j,wave in enumerate(stage[1:]):
  expected=[]
  for k in range(0,len(wave),3):expected.extend([wave[k],names.index(wave[k+1]),round(wave[k+2]*20)]);groups+=1
  assert array('wave%d_%d'%(i,j))==expected
print('PASS:17 packedmaps byteexact,%d portals,%d complete original waves,%d groups'%(portals,sum(len(w)-1 for w in waves),groups))
