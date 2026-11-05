"""Pack full-resolution original SWF art as archive-readable CE AppVars."""
import sys,pathlib,struct,subprocess,re
sys.path.insert(0,'../../local-tools/plot-libs')
from PIL import Image
root=pathlib.Path(__file__).parent
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
banks=[bytearray()];entries=[]
def add(name,im,fw=None,fh=None):
 im=im.convert('RGBA');fw=fw or im.width;fh=fh or im.height
 # Frames are tightly packed, all with the same dimensions; each is gfx_sprite_t.
 frames=[]
 for yy in range(0,im.height,fh):
  for xx in range(0,im.width,fw):
   frame=im.crop((xx,yy,xx+fw,yy+fh));alpha=frame.getchannel('A');rgb=frame.convert('RGB').quantize(palette=quant,dither=Image.Dither.NONE)
   frames.append(bytes([fw,fh])+bytes(v+1 if a>=100 and v<255 else 0 for v,a in zip(rgb.getdata(),alpha.getdata())))
 raw=b''.join(frames)
 assert len(raw)<60000,(name,len(raw))
 if len(banks[-1])+len(raw)>60000:banks.append(bytearray())
 entries.append((name,len(banks)-1,len(banks[-1]),fw,fh,len(frames)))
 banks[-1]+=raw
for theme in range(4):
 key='xplor.TileSets.TileSet_Grave_TileImage'+('' if theme==0 else str(theme+1))
 add('TILES'+str(theme),Image.open(files[key]),16,16)
for key in ['TitleState_TitleImage','Menus.MapState_MapImage','Sky_SunsetImage','Sky_DesertImage','Sky_CaveImage']:
 im=Image.open(files['xplor.'+key]);add(key.replace('.','_')+'_LEFT',im.crop((0,0,160,240)));add(key.replace('.','_')+'_RIGHT',im.crop((160,0,320,240)))
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
(root/'src/art.h').write_text('#ifndef SCOUT_ART_H\n#define SCOUT_ART_H\n#include <stdint.h>\n#include <graphx.h>\ntypedef struct {uint8_t bank;uint16_t offset;uint8_t width,height,frames;} Art;\nenum {\n'+',\n'.join('ART_'+e[0].upper() for e in entries)+'\n,ART_COUNT};\nstatic const Art artTable[]={\n'+',\n'.join('{%d,%d,%d,%d,%d}'%e[1:] for e in entries)+'};\nstatic const uint16_t artPalette[]={'+','.join(map(str,pal))+'};\n#define ART_BANKS '+str(len(banks))+'\nextern const uint8_t *artBanks[ART_BANKS];\nbool art_open(void);\ngfx_sprite_t *art_sprite(int id,int frame);\nvoid art_draw(int id,int frame,int x,int y);\nvoid art_background(int left);\n#endif\n')
(root/'bin').mkdir(exist_ok=True);(root/'build-art').mkdir(exist_ok=True)
for i,data in enumerate(banks):
 name='SCA%02d'%i;binary=root/'build-art'/ (name+'.bin');binary.write_bytes(data)
 subprocess.run(['../../local-tools/cedev/CEdev/bin/convbin.exe','-j','bin','-k','8xv','-n',name,'-r','-i',str(binary),'-o',str(root/'bin'/(name+'.8xv'))],check=True,capture_output=True)
print('%d full-resolution art entries, %d archived resource banks, %d bytes'%(len(entries),len(banks),sum(map(len,banks))))
