"""Validate the exact versioned resources consumed by the native renderer."""
from pathlib import Path
import struct,re,json
ROOT=Path(__file__).resolve().parents[1]
h=(ROOT/'src/art.h').read_text()
def block(name):return re.search(r'\b'+name+r'\[\]=\{(.*?)\};',h,re.S)[1]
def rows(name):return [tuple(map(int,m.split(','))) for m in re.findall(r'\{([^}]+)\}',block(name))]
sizes=list(map(int,block('artBankSizes').split(',')));signature=bytes(map(int,block('artSignature').split(',')))
banks=[]
for i,n in enumerate(sizes):
 name='SCA%02d'%i;f=(ROOT/'bin'/(name+'.8xv')).read_bytes()
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
for first,w,height,count in art:
 for frame in range(count):
  bank,offset=frames[first+frame];raw=banks[bank][offset:offset+w*height+2]
  assert len(raw)==w*height+2 and raw[:2]==bytes([w,height])
names=re.findall(r'^ART_(\w+),?$',h,re.M)
def frame(name,n):
 first,w,h,count=art[names.index(name)];bank,off=frames[first+n];return banks[bank][off+2:off+2+w*h]
for sky,(bank,off,size) in zip(['SKY_SUNSETIMAGE','SKY_DESERTIMAGE'],rows('artSkies')):
 source=banks[bank][off:off+size];pixels=bytearray();p=0
 while p<len(source):
  op=source[p];p+=1;count=(op&127)+1
  if op&128:pixels+=bytes([source[p]])*count;p+=1
  else:pixels+=source[p:p+count];p+=count
 assert len(pixels)==76800
 for side,label in enumerate(['LEFT','RIGHT']):
  for y in range(240):
   expected=frame(sky+'_'+label,y//120)[y%120*160:(y%120+1)*160]
   assert pixels[y*320+side*160:y*320+side*160+160]==expected
print(json.dumps({'banks':len(banks),'frames':len(frames),'assets':len(art),'signature':signature.hex(),'sky_pixels_compared':153600,'status':'PASS'}))


