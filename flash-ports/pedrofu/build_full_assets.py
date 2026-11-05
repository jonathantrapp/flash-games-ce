"""Export original actor frames, UI artwork, palette and skill definitions.

Reads the decompiler's actual [Embed] bindings and loadGraphic frame sizes.
The output is archived calculator AppVars, not a replacement drawing of the art.
"""
from pathlib import Path
import sys,re,subprocess,struct,json
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'local-tools/plot-libs'))
from PIL import Image
P=Path(__file__).resolve().parent
S=P/'original/scripts/xplor'
CONV=ROOT/'local-tools/cedev/CEdev/bin/convbin.exe'
classes={0:'Pedro',2:'Monster/Yak',13:'Monster/Tent',14:'Monster/Tent',15:'Monster/Campfire',16:'Monster/Yak_Armor',17:'Monster/Yak_Archer',18:'Monster/Tree_Wall',19:'Monster/Tree_Wall',20:'Monster/Tree',21:'Monster/Tree',22:'Monster/Tree',23:'Monster/Tree',24:'Monster/Tree',25:'Monster/Tree',29:'Monster/FireMan',30:'Monster/BlimpChunk',31:'Monster/BlimpChunk',32:'Monster/BlimpShred',33:'Monster/BlimpShred',34:'Monster/BlimpEngine',35:'Monster/Yak_Ninja',38:'Monster/Yak_Bruiser',39:'Monster/Yak_Big',40:'Monster/Yak_Master',41:'Monster/Yak_Archer_Elite',42:'Monster/Barrier_Orb',43:'Monster/Barrier',44:'Monster/Tent_Grass',45:'Monster/Yakolyte',46:'Monster/Robot',47:'Monster/Iron_Priest',48:'Monster/PowerUp',49:'Bullet/Arrow',50:'Bullet/NinjaStar',51:'Bullet/BadFireball',52:'Bullet/RockSpike',53:'Bullet/GroundFire',54:'Bullet/PikeSlash',55:'Bullet/FireBit',56:'Bullet/HitSpark',57:'Bullet/Fireball',58:'Monster/Blimp',59:'Monster/PedroChute'}
spec={}
def img(name):return Image.open(next((P/'assets/images').glob('*'+name+'.png'))).convert('RGBA')
for id,cl in classes.items():
    code=(S/(cl+'.as')).read_text(); m=re.search(r'loadGraphic\((\w+),(?:true|false),(?:true|false),(\d+),(\d+)',code)
    if not m:continue
    binding=re.search(r'var '+m[1]+r':Class = (\w+)',code)
    if not binding:continue
    im=img(binding[1]);w,h=map(int,m.group(2,3));frames=im.width//w*(im.height//h)
    ctor=code[m.end():].split('public function')[0].split('override public function')[0]
    def val(key,default):
        a=re.search(r'(?<![\w])(?:this\.)?'+re.escape(key)+r' = (-?\d+);',ctor)
        return int(a[1]) if a else default
    spec[id]=dict(image=im,w=w,h=h,frames=frames,bw=val('width',w),bh=val('height',h),ox=val('offset.x',0),oy=val('offset.y',0),cl=cl)
UI=[('PDHEART','Hud_HeartImage',9,9),('PDMAIL','Hud_MailImage',11,11),('PDFURY','Hud_FuryImage',63,9),('PDFURYI','Hud_FuryInnardsImage',61,7),('PDFBOX','Hud_FuryBoxImage',7,9),('PDXP','Hud_XPMeterImage',68,6),('PDBADG','Hud_BadguyMeterImage',63,9),('PDBADGI','Hud_BadguyMeterInsideImage',59,5),('PDSKI','SkillState_IconImage',16,16),('PDSKF','SkillState_FrameImage',22,22),('PDSKT','SkillState_TrayImage',16,5),('PDSKP','SkillState_PointImage',2,3),('PDSKB','SkillState_BackImage',92,139)]
uiimages=[img(n) for _,n,_,_ in UI]
title=img('TitleState_TitleImage');world=img('MapState_MapImage');sky=img('Sky_DesertImage');tile=img('TileSet_Grave_TileImage')
canvas=Image.new('RGB',(2048,1024),(0,0,0));x=y=rowh=0
for im in [tile,title,world,sky]+[v['image'] for v in spec.values()]+uiimages:
    if im.width>2048:im=im.resize((2048,max(1,im.height*2048//im.width)))
    if x+im.width>2048:x=0;y+=rowh;rowh=0
    canvas.paste(im.convert('RGB'),(x,y));x+=im.width;rowh=max(rowh,im.height)
pal=canvas.crop((0,0,2048,min(1024,y+rowh))).quantize(colors=251,method=Image.Quantize.MEDIANCUT)
rgb=pal.getpalette()[:251*3]
palette=bytes(6)+bytes(rgb)+bytes([255,200,0,80,130,215,255,255,0,255,255,255])
# palette indices: 0 transparent, 1..251 quantized, 252 gold,253 sky,254 yellow,255 white
palette=bytes([0,0,0])+bytes(rgb)+bytes([255,200,0,80,130,215,255,255,0,255,255,255])
assert len(palette)==768
def app(name,data):
    f=P/'data'/f'{name}.bin';f.write_bytes(data)
    subprocess.run([str(CONV),'-j','bin','-k','8xv','-r','-n',name,'-i',str(f),'-o',str(P/'bin'/f'{name}.8xv')],check=True,stdout=subprocess.DEVNULL)
def pixels(im):
    q=im.convert('RGB').quantize(palette=pal,dither=Image.Dither.NONE)
    return bytes(a+1 if alpha>=128 else 0 for a,alpha in zip(q.tobytes(),im.getchannel('A').tobytes()))
def sprite(im):return bytes(im.size)+pixels(im)
app('PDCOLOR',b''.join(struct.pack('<H',((palette[i]>>3)<<10)|((palette[i+1]>>3)<<5)|(palette[i+2]>>3))for i in range(0,768,3)))
for b in range(2):app(f'PDTILE{b}',b''.join(sprite(tile.crop((x*16,b*16,x*16+16,b*16+16)))for x in range(148)))
header=['/* Generated from original AS3 loadGraphic/Embed definitions. */','#ifndef RESOURCES_H','#define RESOURCES_H','typedef struct { unsigned short stride,frames; unsigned char w,h,bw,bh; signed char ox,oy; } ArtDef;','static const ArtDef artdef[60]={']
for id,s in spec.items():
    frames=[];im=s['image'];w=s['w'];h=s['h'];cols=im.width//w
    if w>255 or h>255:
        print('Skipping oversized sheet',id,s['cl'],w,h)
        continue
    for flip in range(2):
        for i in range(s['frames']):
            fr=im.crop((i%cols*w,i//cols*h,i%cols*w+w,i//cols*h+h))
            if flip:fr=fr.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
            frames.append(sprite(fr))
    data=b''.join(frames)
    assert len(data)<65500,(id,len(data))
    app(f'PDG{id:02}',data)
    header.append(f"[{id}]={{{w*h+2},{s['frames']},{w},{h},{s['bw']},{s['bh']},{s['ox']},{s['oy']}}}, /* {s['cl']} */")
header+=['};','#endif']
(P/'src/resources.h').write_text('\n'.join(header)+'\n')
for id,im in enumerate([title,world,sky]):
    for half in range(2):app(f'PDU{id}{half}',sprite(im.crop((half*160,0,(half+1)*160,240))))
ui_header=['/* Generated by build_full_assets.py from the original HUD and skill-screen images. */','#ifndef UI_RESOURCES_H','#define UI_RESOURCES_H','typedef struct { const char *name; unsigned char w,h,frames; unsigned short stride; } UiDef;','enum { '+','.join('UI_'+n[2:] for n,_,_,_ in UI)+',UI_COUNT };','static const UiDef uidef[UI_COUNT]={']
for (name,_,w,h),im in zip(UI,uiimages):
    cols=im.width//w;rows=im.height//h;frames=[sprite(im.crop((c*w,r*h,c*w+w,r*h+h))) for r in range(rows) for c in range(cols)]
    app(name,b''.join(frames))
    ui_header.append('{"%s",%d,%d,%d,%d},'%(name,w,h,len(frames),w*h+2))
ui_header+=['};','#endif']
(P/'src/ui_resources.h').write_text(chr(10).join(ui_header)+chr(10))
# Skill display metadata is copied directly from SkillState's constructor list.
skills=re.findall(r'new SkillDef\("([^"]+)"\s*,(\d+),(\d+),(\d+),SkillDef\.(\w+)\)',re.sub(r'\s+',' ',(S/'Menus/SkillState.as').read_text()).replace('SkillDef .','SkillDef.').replace('SkillDef. ','SkillDef.'))
assert len(skills)==45
order=sorted(range(45),key=lambda i:0)
by_icon={}
for k,s_ in enumerate(skills):by_icon[k]=(int(s_[1]),int(s_[2]),int(s_[3]))
out=['#ifndef SKILL_META_H','#define SKILL_META_H','enum { '+','.join(s[4] for s in skills)+' };','static const char *const skillnames[45]={'+','.join('"'+s[0]+'"'for s in skills)+'};','/* group, rank, column as listed by the original SkillState constructor. */','static const unsigned char skillgrid[45][3]={'+','.join('{%d,%d,%d}'%by_icon[k] for k in range(45))+'};','#endif']
(P/'src/skill_meta.h').write_text('\n'.join(out)+'\n')
(P/'data/skill-definitions.json').write_text(json.dumps(skills,indent=2))
print('Generated',len(spec),'original actor sheets, title/map/sky and palette; 45 skill definitions.')
