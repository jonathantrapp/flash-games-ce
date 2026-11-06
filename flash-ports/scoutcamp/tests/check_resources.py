"""Validate the exact versioned resources consumed by the native renderer."""
from pathlib import Path
import struct,re,json,argparse
ROOT=Path(__file__).resolve().parents[1]
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--bin-dir',default='bin');args=parser.parse_args()
h=(ROOT/'src/art.h').read_text()
def block(name):return re.search(r'\b'+name+r'\[\](?:\[\d+\])?=\{(.*?)\};',h,re.S)[1]
def rows(name):return [tuple(map(int,m.split(','))) for m in re.findall(r'\{([^}]+)\}',block(name))]
sizes=list(map(int,block('artBankSizes').split(',')));signature=bytes(map(int,block('artSignature').split(',')))
banks=[]
for i,n in enumerate(sizes):
 name='SCA%02d'%i;f=(ROOT/args.bin_dir/(name+'.8xv')).read_bytes()
 assert f[:11]==b'**TI83F*\x1a\x0a\0'
 section=struct.unpack_from('<H',f,53)[0]
 assert section+57==len(f)
 assert sum(f[55:-2])&65535==struct.unpack_from('<H',f,len(f)-2)[0]
 assert f[59]==0x15 and f[60:68].rstrip(b'\0')==name.encode()
 payload=f[74:-2]
 assert len(payload)==n+12 and n<=32000
 assert payload[:4]==b'SCA3' and payload[4:8]==signature
 assert struct.unpack_from('<HH',payload,8)==(i,n)
 assert payload==(ROOT/'build-art'/(name+'.bin')).read_bytes()
 banks.append(payload[12:])
frames=rows('artFrames');art=rows('artTable')
names=re.findall(r'^ART_(\w+),?$',h,re.M)
for idx,(first,w,height,count) in enumerate(art):
 for f in range(count):
  bank,offset=frames[first+f]
  if names[idx].startswith('OVERLAY_'):continue
  raw=banks[bank][offset:offset+w*height+2]
  assert len(raw)==w*height+2 and raw[:2]==bytes([w,height])
def frame(name,n):
 first,w,height,count=art[names.index(name)];bank,off=frames[first+n];return banks[bank][off+2:off+2+w*height]
for sky,(left,right,lsize,rsize,rowid,count) in zip(['SKY_SUNSETIMAGE','SKY_DESERTIMAGE'],re.findall(r'\{(\d+),(\d+),(\d+),(\d+),artSkyRows(\d+),(\d+)\}',block('artSkies'))):
 left,right,lsize,rsize,rowid,count=map(int,[left,right,lsize,rsize,rowid,count]);base=[0]*240
 for color,y,n in rows('artSkyRows'+str(rowid)):base[y:y+n]=[color]*n
 for side,(id,size) in enumerate([(left,lsize),(right,rsize)]):
  first,w,height,n=art[id];bank,off=frames[first];stream=banks[bank][off:off+size];assert stream[:2]==bytes([160,240]);p=2;pixels=bytearray()
  for y in range(240):
   line=bytearray([base[y]])*160;x=0
   while x<160:
    x+=stream[p];p+=1
    if x==160:break
    n=stream[p];p+=1;line[x:x+n]=stream[p:p+n];x+=n;p+=n
   assert x==160
   expected=frame(sky+('_RIGHT' if side else '_LEFT'),y//120)[y%120*160:(y%120+1)*160]
   assert line==expected
  assert p==len(stream)
mapbank=int(re.search(r'#define ART_MAP_BANK (\d+)',h)[1]);mapoffset=int(re.search(r'#define ART_MAP_OFFSET (\d+)',h)[1]);mapsize=int(re.search(r'#define ART_MAP_SIZE (\d+)',h)[1])
assert banks[mapbank][mapoffset:mapoffset+mapsize]==(ROOT/'build-art/maps.bin').read_bytes()
skillbank=int(re.search(r'#define ART_SKILL_BANK (\d+)',h)[1]);skilloffset=int(re.search(r'#define ART_SKILL_OFFSET (\d+)',h)[1]);skillsize=int(re.search(r'#define ART_SKILL_SIZE (\d+)',h)[1])
skilltext=banks[skillbank][skilloffset:skilloffset+skillsize]
assert skilltext==(ROOT/'build-art/skill-text.bin').read_bytes()
index=(ROOT/'src/skill_text_index.h').read_text();offsets=list(map(int,re.findall(r'\d+',index.split('=')[1])))
assert len(offsets)==240 and len(set(offsets))==240
for offset in offsets:
 assert 0<=offset<len(skilltext) and (offset==0 or skilltext[offset-1]==0)
 text=skilltext[offset:skilltext.index(0,offset)].decode('ascii');assert 0<len(text)<200
print(json.dumps({'banks':len(banks),'frames':len(frames),'assets':len(art),'signature':signature.hex(),'sky_pixels_compared':153600,'map_bytes':mapsize,'skill_descriptions':len(offsets),'status':'PASS'}))

