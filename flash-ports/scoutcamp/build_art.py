"""Pack full-resolution original SWF art as archive-readable CE AppVars."""
import sys,pathlib,struct,re,hashlib,json,argparse
sys.path.insert(0,'../../local-tools/plot-libs')
from PIL import Image
root=pathlib.Path(__file__).parent
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--bin-dir',default='bin')
output=root/parser.parse_args().bin_dir
files={f.name.split('_',1)[1][:-4]:f for f in (root/'assets/images').glob('*_xplor*.png')}
images=[Image.open(f).convert('RGBA') for f in files.values()]
canvas=Image.new('RGB',(1024,1024),(0,0,0));x=y=0
for im in images:
 small=im.copy();small.thumbnail((128,64))
 if x+small.width>1024:x=0;y+=64
 if y+small.height>1024:break
 canvas.paste(small,(x,y),small);x+=small.width
quant=canvas.quantize(colors=255,method=Image.Quantize.MEDIANCUT)
palette=quant.getpalette();pal=[0]+[(((palette[i*3]>>3)<<10)|((palette[i*3+1]>>3)<<5)|(palette[i*3+2]>>3)) for i in range(255)]
banks=[bytearray()];entries=[];frameRefs=[];sourceFrames={}

def write_appvar(path,name,payload):
 data=struct.pack("<H",len(payload))+payload
 entry=struct.pack("<HHB",13,len(data),0x15)+name.encode().ljust(8,b"\0")+b"\0\x80"+struct.pack("<H",len(data))+data
 header=b"**TI83F*\x1a\x0a\0"+b"Scouts vs Aliens CE assets".ljust(42,b"\0")+struct.pack("<H",len(entry))
 path.write_bytes(header+entry+struct.pack("<H",sum(entry)&65535))
def add(name,im,fw=None,fh=None):
 im=im.convert('RGBA');fw=fw or im.width;fh=fh or im.height
 # Frames are tightly packed, all with the same dimensions; each is gfx_sprite_t.
 frames=[]
 for yy in range(0,im.height,fh):
  for xx in range(0,im.width,fw):
   frame=im.crop((xx,yy,xx+fw,yy+fh));alpha=frame.getchannel('A');rgb=frame.convert('RGB').quantize(palette=quant,dither=Image.Dither.NONE)
   frames.append(bytes([fw,fh])+bytes(v+1 if a>=100 and v<255 else 0 for v,a in zip(rgb.getdata(),alpha.getdata())))
 sourceFrames[name]=frames
 first=len(frameRefs)
 for frame in frames:
  assert len(frame)<=32000,(name,len(frame))
  if len(banks[-1])+len(frame)>32000:banks.append(bytearray())
  frameRefs.append((len(banks)-1,len(banks[-1])))
  banks[-1]+=frame
 entries.append((name,first,fw,fh,len(frames)))
for theme in range(4):
 key='xplor.TileSets.TileSet_Grave_TileImage'+('' if theme==0 else str(theme+1))
 add('TILES'+str(theme),Image.open(files[key]),16,16)
for key in ['TitleState_TitleImage','Menus.MapState_MapImage','Sky_SunsetImage','Sky_DesertImage','Sky_CaveImage']:
 im=Image.open(files['xplor.'+key]);add(key.replace('.','_')+'_LEFT',im.crop((0,0,160,240)),160,120);add(key.replace('.','_')+'_RIGHT',im.crop((160,0,320,240)),160,120)
for f in sorted((root/'original/scripts/xplor/Monster').glob('*.as')):
 s=f.read_text();m=re.search(r'loadGraphic\([^,]+,true,true,(\d+),(\d+)',s)
 if not m:continue
 cls=f.stem;embedded=re.search(r'(?:TowerImage|SkellyImage|SquirmyImage|HungryBabyImage|FoodImage|BuilderImage):Class = ([^;]+);',s)
 if not embedded:continue
 key='xplor.Monster.'+embedded[1]
 if key in files:add(cls,Image.open(files[key]),int(m[1]),int(m[2]))
for name,key,fw,fh in [('FIRE','Campfire_FireImage',16,19),('TENT','Tent_FireImage',16,10),('SKILL_BACK','Menus.SkillState_BackImage',76,130),('SKILL_ICON','Menus.SkillState_IconImage',16,16),('SKILL_FRAME','Menus.SkillState_FrameImage',22,22),('CURSOR','Player_CursorImage',16,16),('SELECT','Player_SelectImage',18,18),('HUD','Hud_HudBoxImage',125,41),('BUTTON','TitleState_BtnImage',142,29),('BUILD','Monster.Builder_BuilderImage',16,16),('UPGRADE','Monster.Tower_UpgradeImage',4,4),('BOX','Player_BoxImage',24,24),('WAVE','WaveBlock_WaveBoxImage',16,16)]:
 add(name,Image.open(files['xplor.'+key]),fw,fh)
for f in sorted((root/'original/scripts/xplor/Bullet').glob('*.as')):
 s=f.read_text();m=re.search(r'loadGraphic\([^,]+,true,false,(\d+),(\d+)',s)
 e=re.search(r'(?:RockImage|BoomImage|SmokeImage|LaserEndImage):Class = ([^;]+);',s)
 if m and e and 'xplor.Bullet.'+e[1] in files:
  add('BULLET_'+f.stem,Image.open(files['xplor.Bullet.'+e[1]]),int(m[1]),int(m[2]))
for name,key,fw,fh in [('MAP_X','Menus.MapState_XImage',19,18),('MAP_BUTTON','Menus.MapState_ButtonImage',53,18),('SKILL_TRAY','Menus.SkillState_TrayImage',16,5),('SKILL_POINT','Menus.SkillState_PointImage',2,3),('WAVE_MONSTER','WaveBlock_WaveMonsterImage',14,16)]:
 add(name,Image.open(files['xplor.'+key]),fw,fh)
from collections import Counter
add('SPEED_SLIDER',Image.open(files['xplor.Hud_HudSpeedImage']),7,9)
skyRows=[];skyOverlays=[]
for prefix in ['Sky_SunsetImage','Sky_DesertImage']:
 raw=bytearray(76800)
 for side,label in enumerate(['LEFT','RIGHT']):
  frames=sourceFrames[prefix+'_'+label]
  for yy in range(240):raw[yy*320+side*160:yy*320+side*160+160]=frames[yy//120][2+(yy%120)*160:2+(yy%120+1)*160]
 base=[Counter(raw[y*320:(y+1)*320]).most_common(1)[0][0] for y in range(240)]
 groups=[]
 for y,color in enumerate(base):
  if groups and groups[-1][0]==color:groups[-1][2]+=1
  else:groups.append([color,y,1])
 ids=[];sizes=[]
 for side in range(2):
  rlet=bytearray([160,240])
  for y in range(240):
   row=raw[y*320+side*160:y*320+side*160+160];x=0
   while x<160:
    start=x
    while x<160 and row[x]==base[y]:x+=1
    rlet.append(x-start)
    if x==160:break
    start=x
    while x<160 and row[x]!=base[y]:x+=1
    rlet.append(x-start);rlet+=row[start:x]
  if len(banks[-1])+len(rlet)>32000:banks.append(bytearray())
  ids.append(len(entries));sizes.append(len(rlet));first=len(frameRefs)
  frameRefs.append((len(banks)-1,len(banks[-1])));banks[-1]+=rlet
  entries.append(('OVERLAY_'+prefix+'_'+str(side),first,160,240,1))
 skyRows.append(groups);skyOverlays.append((ids[0],ids[1],sizes[0],sizes[1]))
mapData=(root/'build-art/maps.bin').read_bytes()
if len(banks[-1])+len(mapData)>32000:banks.append(bytearray())
mapBank,mapOffset=len(banks)-1,len(banks[-1]);banks[-1]+=mapData
skillText=(root/'build-art/skill-text.bin').read_bytes()
assert len(skillText)<32000 and skillText[-1]==0
if len(banks[-1])+len(skillText)>32000:banks.append(bytearray())
skillBank,skillOffset=len(banks)-1,len(banks[-1]);banks[-1]+=skillText
signature=hashlib.sha256(b''.join(banks)+str(entries).encode()+str(frameRefs).encode()+bytes(str(pal),'ascii')).digest()[:4]
header='#ifndef SCOUT_ART_H\n#define SCOUT_ART_H\n#include <stdbool.h>\n#include <stdint.h>\n#include <graphx.h>\ntypedef struct {uint16_t first;uint8_t width,height,frames;} Art;\ntypedef struct {uint8_t bank;uint16_t offset;} ArtFrame;\nenum {\n'+',\n'.join('ART_'+e[0].upper() for e in entries)+'\n,ART_COUNT};\n'
header+='static const Art artTable[]={\n'+',\n'.join('{%d,%d,%d,%d}'%e[1:] for e in entries)+'};\n'
header+='static const ArtFrame artFrames[]={\n'+',\n'.join('{%d,%d}'%f for f in frameRefs)+'};\n'
for i,groups in enumerate(skyRows):header+='static const uint8_t artSkyRows%d[][3]={'%i+','.join('{%d,%d,%d}'%tuple(g) for g in groups)+'};\n'
header+='static const struct {uint8_t left,right;uint16_t leftSize,rightSize;const uint8_t (*rows)[3];uint8_t groups;} artSkies[]={'+','.join('{%d,%d,%d,%d,artSkyRows%d,%d}'%(v[0],v[1],v[2],v[3],i,len(skyRows[i])) for i,v in enumerate(skyOverlays))+'};\n'
header+='#define ART_MAP_BANK '+str(mapBank)+'\n#define ART_MAP_OFFSET '+str(mapOffset)+'\n#define ART_MAP_SIZE '+str(len(mapData))+'\n'
header+='#define ART_SKILL_BANK '+str(skillBank)+'\n#define ART_SKILL_OFFSET '+str(skillOffset)+'\n#define ART_SKILL_SIZE '+str(len(skillText))+'\n'
header+='static const uint16_t artPalette[]={'+','.join(map(str,pal))+'};\n'
header+='static const uint16_t artBankSizes[]={'+','.join(str(len(b)) for b in banks)+'};\n'
header+='static const uint8_t artSignature[]={'+','.join(map(str,signature))+'};\n'
header+='#define ART_BANKS '+str(len(banks))+'\nextern const uint8_t *artBanks[ART_BANKS];\nextern char art_error[40];\nbool art_open(void);\ngfx_sprite_t *art_sprite(int id,int frame);\nvoid art_draw(int id,int frame,int x,int y);\nvoid art_background(int left);\nconst uint8_t *art_map_data(void);\nvoid art_cache_level(const uint8_t *back,const uint8_t *solid,const uint8_t *decor,int cells,int theme);\n#endif\n'
(root/'src/art.h').write_text(header)
output.mkdir(exist_ok=True);(root/'build-art').mkdir(exist_ok=True)
for i,data in enumerate(banks):
 name='SCA%02d'%i
 payload=b'SCA3'+signature+struct.pack('<HH',i,len(data))+data
 (root/'build-art'/(name+'.bin')).write_bytes(payload)
 write_appvar(output/(name+'.8xv'),name,payload)
(root/'build-art/manifest.json').write_text(json.dumps(dict(signature=signature.hex(),banks=len(banks),frames=len(frameRefs),bytes=sum(map(len,banks))),indent=2))
print('%d full-resolution art entries, %d versioned resource banks, max32000 payload bytes, %d bytes'%(len(entries),len(banks),sum(map(len,banks))))
