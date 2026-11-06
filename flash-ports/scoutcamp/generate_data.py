"""Generate exact original map/wave tables, with map payload outside executable RAM."""
from pathlib import Path
import re,json,zlib,struct
root=Path(__file__).parent
out=[];packed=bytearray()
def array(name,values,typ='uint16_t'):
 out.append('static const '+typ+' '+name+'[]={'+','.join(map(str,values))+'};')
for level in range(17):
 f=next((root/'assets/binaryData').glob('*Level%02d.bin'%(level+1)))
 raw=zlib.decompress(f.read_bytes());w,h=struct.unpack('>HH',raw[:4]);n=w*h;data=raw[4:]
 assert len(data)==4*n
 offset=len(packed)
 for layer in range(4):
  row=data[layer*n:(layer+1)*n];i=0
  while i<n:
   count=1
   while i+count<n and row[i+count]==row[i] and count<255:count+=1
   packed.extend([count,row[i]]);i+=count
 goodies=data[3*n:];camp=goodies.index(2);portals=[i for i,v in enumerate(goodies) if v==1]
 for j,portal in enumerate(portals):array('portal%d_%d'%(level,j),[portal])
 out.append('static const Route routes%d[]={%s};'%(level,','.join('{portal%d_%d,1}'%(level,j) for j in range(len(portals)))))
 out.append('static const Map level%d={%d,%d,%d,%d,%d,routes%d};'%(level,w,h,camp,len(portals),offset,level))
out.append('static const Map *const maps[]={'+','.join('&level'+str(i) for i in range(17))+'};')
s=(root/'original/scripts/xplor/WaveDef.as').read_text().split('waves:Array = ')[1].split(';')[0]
names=['Lumpy','Squirmy','Beefy','Beasty','Wormy','Speedy','Blinky','Scary','Hungry']
s=s.replace('new Array(', '[').replace(')',']')
for name in names:s=re.sub(r'\b'+name+r'\b','"'+name+'"',s)
waves=json.loads(s)
for l,lev in enumerate(waves):
 for j,wave in enumerate(lev[1:]):
  values=[]
  for k in range(0,len(wave),3):values.extend([wave[k],names.index(wave[k+1]),round(wave[k+2]*20)])
  array('wave%d_%d'%(l,j),values)
 out.append('static const Wave waves%d[]={%s};'%(l,','.join('{wave%d_%d,%d}'%(l,j,len(w)//3) for j,w in enumerate(lev[1:]))))
out.append('static const Wave *const waveSets[]={'+','.join('waves'+str(l) for l in range(17))+'};')
array('waveCounts',[len(w)-1 for w in waves],'uint8_t');array('waveTimes',[int(w[0]) for w in waves],'uint8_t')
(root/'src/data.h').write_text('\n'.join(out))
(root/'build-art').mkdir(exist_ok=True);(root/'build-art/maps.bin').write_bytes(packed)
print('Exact17 maps moved toresource:',len(packed),'bytes; wave tables',sum(len(w)-1 for w in waves),'waves')
