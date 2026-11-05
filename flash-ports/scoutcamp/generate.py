import sys,pathlib,zlib,struct,re,heapq,json
sys.path.insert(0,'../../local-tools/plot-libs')
from PIL import Image
root=pathlib.Path(__file__).parent
out=[]
def arr(name,data,typ='uint8_t'):
 out.append('static const '+typ+' '+name+'[]={'+','.join(map(str,data))+'};')
def sprite(name,im):
 im=im.convert('RGBA'); w,h=im.size
 pixels=[]
 for r,g,b,a in im.getdata():
  idx=(r>>5)*32+(g>>5)*4+(b>>6)
  pixels.append(0 if a<100 else max(1,idx))
 arr(name,[w,h]+pixels)
def img(key):return Image.open(next((root/'assets/images').glob('*'+key+'.png')))
pal=[]
for i in range(256):
 r=((i>>5)&7)*31//7;g=((i>>2)&7)*31//7;b=(i&3)*31//3
 pal.append((r<<10)|(g<<5)|b)
arr('palette',pal,'uint16_t')
tiles=img('TileSet_Grave_TileImage')
for i in range(128): sprite('tile'+str(i),tiles.crop((i*16,0,i*16+16,16)).resize((8,8),Image.Resampling.NEAREST))
out.append('static const uint8_t *const tiles[]={'+','.join('tile'+str(i) for i in range(128))+'};')
for key,w,h,n in [('Lumpy_SkellyImage',15,17,2),('Squirmy_SquirmyImage',10,14,2),('Beefy_SkellyImage',20,21,2),('Beasty_SkellyImage',25,23,2),('Wormy_SkellyImage',20,16,2),('Speedy_SquirmyImage',10,14,2),('Blinky_SkellyImage',13,17,2),('Scary_SkellyImage',20,15,2),('Hungry_SkellyImage',32,48,2)]:
 im=img(key)
 for f in range(n):sprite('mob'+str(['Lumpy','Squirmy','Beefy','Beasty','Wormy','Speedy','Blinky','Scary','Hungry'].index(key.split('_')[0]))+'_'+str(f),im.crop((w*f,0,w*(f+1),h)).resize((max(6,w//2),max(7,h//2)),Image.Resampling.NEAREST))
out.append('static const uint8_t *const mobs[]={'+','.join('mob'+str(i)+'_'+str(f) for i in range(9) for f in range(2))+'};')
for i,key in enumerate(['Tower_Rock_TowerImage','Tower_Roll_TowerImage','Tower_Snow_TowerImage','Tower_Shock_TowerImage']):
 im=img(key);sprite('tower'+str(i),im.crop((0,0,16,im.height)).resize((8,im.height//2),Image.Resampling.NEAREST))
out.append('static const uint8_t *const towerpics[]={tower0,tower1,tower2,tower3};')
sprite('fire',img('Campfire_FireImage').crop((0,0,16,19)).resize((8,10),Image.Resampling.NEAREST))
sprite('tent',img('Tent_FireImage').resize((8,5),Image.Resampling.NEAREST))
for level in range(17):
 f=next((root/'assets/binaryData').glob('*Level%02d.bin'%(level+1)))
 d=zlib.decompress(f.read_bytes());w,h=struct.unpack('>HH',d[:4]);data=list(d[4:]);n=w*h
 assert len(data)==n*4
 rle=[];pos=0
 while pos<len(data):
  count=1
  while pos+count<len(data) and (pos+count)//n==pos//n and data[pos+count]==data[pos] and count<255:count+=1
  rle += [count,data[pos]];pos+=count
 arr('map'+str(level),rle)
 solid=data[n:2*n];good=data[3*n:]
 portals=[i for i,v in enumerate(good) if v==1];camp=good.index(2)
 # Route over original map: air-space search weighted toward the ground.
 paths=[]
 for portal in portals:
  heap=[(0,portal)];dist={portal:0};prev={}
  while heap:
   cost,p=heapq.heappop(heap)
   if p==camp:break
   if cost!=dist[p]:continue
   x,y=p%w,p//w
   for dx,dy in [(-1,0),(1,0),(0,-1),(0,1),(-1,-1),(1,-1),(-1,1),(1,1)]:
    xx,yy=x+dx,y+dy
    if not(0<xx<w-1 and 0<=yy<h-1):continue
    q=yy*w+xx
    if solid[q] and q!=camp:continue
    grounded=solid[q+w]!=0
    c=cost+(10 if grounded else 21)+(5 if dy else 0)
    if c<dist.get(q,10**9):dist[q]=c;prev[q]=p;heapq.heappush(heap,(c,q))
  if camp not in dist:raise RuntimeError('no path '+str(level))
  path=[camp]
  while path[-1]!=portal:path.append(prev[path[-1]])
  path.reverse();paths.append(path)
 for j,path in enumerate(paths):arr('path%d_%d'%(level,j),path,'uint16_t')
 out.append('static const Route routes%d[]={%s};'%(level,','.join('{path%d_%d,%d}'%(level,j,len(p)) for j,p in enumerate(paths))))
 out.append('static const Map level%d={%d,%d,%d,%d,map%d,routes%d};'%(level,w,h,camp,len(paths),level,level))
out.append('static const Map *const maps[]={'+','.join('&level'+str(i) for i in range(17))+'};')
s=(root/'original/scripts/xplor/WaveDef.as').read_text();s=s.split('waves:Array = ')[1].split(';')[0]
names=['Lumpy','Squirmy','Beefy','Beasty','Wormy','Speedy','Blinky','Scary','Hungry']
s=s.replace('new Array(', '[').replace(')',']')
for name in names:s=re.sub(r'\b'+name+r'\b','"'+name+'"',s)
waves=json.loads(s)
for l,lev in enumerate(waves):
 for j,wave in enumerate(lev[1:]):
  vals=[]
  for k in range(0,len(wave),3):vals.extend([wave[k],names.index(wave[k+1]),round(wave[k+2]*20)])
  arr('wave%d_%d'%(l,j),vals,'uint16_t')
 out.append('static const Wave waves%d[]={%s};'%(l,','.join('{wave%d_%d,%d}'%(l,j,len(w)//3) for j,w in enumerate(lev[1:]))))
out.append('static const Wave *const waveSets[]={'+','.join('waves'+str(l) for l in range(17))+'};')
arr('waveCounts',[len(w)-1 for w in waves]);arr('waveTimes',[int(w[0]) for w in waves])
(root/'src/data.h').write_text('\n'.join(out))
print('Generated original maps, weighted routes, original waves and artwork:',(root/'src/data.h').stat().st_size)
