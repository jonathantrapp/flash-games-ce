"""Verify generated map, route and wave tables against the local SWF exports."""
import pathlib,re,zlib,struct
root=pathlib.Path(__file__).parent
s=(root/'src/data.h').read_text()
def array(name):
 m=re.search(r'\b'+name+r'\[\]=\{([^}]*)\}',s)
 assert m,name
 return [int(x) for x in m[1].split(',') if x]
count=0
for level in range(17):
 f=next((root/'assets/binaryData').glob('*Level%02d.bin'%(level+1)))
 d=zlib.decompress(f.read_bytes());w,h=struct.unpack('>HH',d[:4]);n=w*h
 encoded=array('map'+str(level));decoded=[];p=0
 for layer in range(4):
  result=[]
  while len(result)<n:
   k,v=encoded[p:p+2];p+=2
   result += [v]*k
  assert len(result)==n,('run crosses layer',level,layer)
  decoded+=result
 assert bytes(decoded)==d[4:],('map changed',level)
 assert p==len(encoded)
 good=decoded[3*n:];camp=good.index(2);portals=[i for i,v in enumerate(good) if v==1]
 for j,start in enumerate(portals):
  path=array('path%d_%d'%(level,j))
  assert path[0]==start and path[-1]==camp
  for a,b in zip(path,path[1:]):
   assert max(abs(a%w-b%w),abs(a//w-b//w))==1
   assert not decoded[n+b]
  count+=1
assert len(array('waveCounts'))==17
assert array('waveCounts')[0]==6
assert array('wave0_0')==[10,0,60]
assert array('wave16_0')==[1,8,20]
assert len(array('palette'))==256 and array('palette')[255]==32767
print('PASS: all 17 maps byte-exact after RLE decode, %d valid portal-to-camp routes, wave and palette checks.'%count)
