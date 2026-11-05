"""Convert exported SWF map layers and pixel art into native CE AppVars."""
import sys, struct, zlib, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'local-tools/plot-libs'))
from PIL import Image
HERE=Path(__file__).resolve().parent
CONV=ROOT/'local-tools/cedev/CEdev/bin/convbin.exe'
def app(name,data):
    p=HERE/'data'/f'{name}.bin';p.write_bytes(data)
    subprocess.run([str(CONV),'-j','bin','-k','8xv','-r','-n',name,'-i',str(p),'-o',str(HERE/'bin'/f'{name}.8xv')],check=True)
def pixels(im):
    return bytes(0 if a<128 else max(1,((r>>5)<<5)|((g>>5)<<2)|(b>>6)) for r,g,b,a in im.convert('RGBA').getdata())
def spr(im):return bytes(im.size)+pixels(im)
def image(s):return Image.open(next((HERE/'assets/images').glob('*'+s+'.png'))).convert('RGBA')
tile=image('TileSet_Grave_TileImage');cols=tile.width//16
for bank in range(2):
    app('PDTILE'+str(bank),b''.join(spr(tile.crop((x*16,bank*16,x*16+16,bank*16+16))) for x in range(cols)))
ped=image('Pedro_PedroImage');yak=image('Yak_YakImage')
actors=b''
for im,w,h,frames in [(ped,20,19,40),(yak,19,19,22)]:
    for flip in range(2):
        for i in range(frames):
            frame=im.crop((i*w,0,(i+1)*w,h))
            if flip:frame=frame.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
            actors+=spr(frame)
app('PDACTOR',actors)
for i in range(1,16):
    data=zlib.decompress(next((HERE/'assets/binaryData').glob(f'*Level{i:02d}.bin')).read_bytes())
    w,h=struct.unpack('>HH',data[:4]);assert len(data)==4+w*h*4
    app(f'PDLV{i:02d}',struct.pack('<HH',w,h)+data[4:])
print('Assets built, tile columns:',cols)
