#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <fileioc.h>
#include "art.h"
#include "input.h"
void scout_unpack(void *dst,const uint8_t *src,const uint8_t *end);
const uint8_t *artBanks[ART_BANKS];
char art_error[40];
static uint8_t skyCache[13000], tileCache[16][410];
static const uint8_t *cachedTiles[128];
static bool cachedOpaque[128];
/* Worst case RLET: one skip byte per opaque run plus data, per row. This
 * initialized buffer lives in linker-guarded resident storage, not the heap. */
static uint8_t hudCache[2+41*(125+64)]={1};
static bool hudReady;
static int cachedSky=-1,cachedTheme=-1;
static const uint8_t emptySprite[3]={1,1,0};
bool art_open(void) {
    for (int i=0;i<ART_BANKS;i++) {
        char name[9];snprintf(name,sizeof name,"SCA%02u",i);
        ti_var_t file=ti_Open(name,"r");
        if(!file){snprintf(art_error,sizeof art_error,"Missing %s",name);return false;}
        const uint8_t*ptr=ti_GetDataPtr(file);
        bool valid=ti_GetSize(file)==artBankSizes[i]+12&&!memcmp(ptr,"SCA3",4)&&!memcmp(ptr+4,artSignature,4)&&ptr[8]==i&&ptr[9]==0&&((unsigned)ptr[10]|(unsigned)ptr[11]<<8)==artBankSizes[i];
        if(!valid){ti_Close(file);snprintf(art_error,sizeof art_error,"Outdated or corrupt %s",name);return false;}
        artBanks[i]=ptr+12;ti_Close(file);
    }
    art_error[0]=0;return true;
}
gfx_sprite_t *art_sprite(int id,int frame) {
    if(id<0||id>=ART_COUNT)return(gfx_sprite_t*)emptySprite;
    const Art*art=&artTable[id];
    if(frame<0)frame=0;
    if(frame>=art->frames)frame%=art->frames;
    const ArtFrame*ref=&artFrames[art->first+frame];
    return(gfx_sprite_t*)(artBanks[ref->bank]+ref->offset);
}
void art_draw(int id,int frame,int x,int y) {
    /* Stage tiles have fixed16x16 dimensions. Use the cache before the
     * generic art-table lookup and software index multiply. */
    if(id==cachedTheme&&(unsigned)frame<128&&cachedTiles[frame]){
        const uint8_t *pixels=cachedTiles[frame];
        if(x>=320||y>=240||x+16<=0||y+16<=0)return;
        bool inside=x>=0&&y>=0&&x+16<=320&&y+16<=240;
        if(cachedOpaque[frame]){
            if(inside)gfx_Sprite_NoClip((gfx_sprite_t*)pixels,x,y);
            else gfx_Sprite((gfx_sprite_t*)pixels,x,y);
        }else{
            if(inside)gfx_RLETSprite_NoClip((gfx_rletsprite_t*)pixels,x,y);
            else gfx_RLETSprite((gfx_rletsprite_t*)pixels,x,y);
        }
        return;
    }
    if(id<0||id>=ART_COUNT)return;
    if(id==ART_HUD){
        if(x>=320||y>=240||x+125<=0||y+41<=0)return;
        if(!hudReady){gfx_ConvertToRLETSprite(art_sprite(id,0),(gfx_rletsprite_t*)hudCache);hudReady=true;}
        if(x>=0&&y>=0&&x+125<=320&&y+41<=240)gfx_RLETSprite_NoClip((gfx_rletsprite_t*)hudCache,x,y);
        else gfx_RLETSprite((gfx_rletsprite_t*)hudCache,x,y);
        return;
    }
    const Art *art=&artTable[id];
    if(x>=320||y>=240||x+art->width<=0||y+art->height<=0)return;
    gfx_sprite_t *sprite=art_sprite(id,frame);
    if(x>=0&&y>=0&&x+art->width<=320&&y+art->height<=240)gfx_TransparentSprite_NoClip(sprite,x,y);
    else gfx_TransparentSprite(sprite,x,y);
}
/* True only for a cached stage tile with no transparent pixel (it hides everything below). */
bool art_tile_opaque(int frame){return (unsigned)frame<128&&cachedTiles[frame]&&cachedOpaque[frame];}
void art_cache_level(const uint8_t*back,const uint8_t*solid,const uint8_t*decor,int cells,int theme) {
    uint16_t counts[128]={0};
    cachedTheme=-1;memset(cachedTiles,0,sizeof cachedTiles);memset(cachedOpaque,0,sizeof cachedOpaque);
    for(int i=0;i<cells;i++){if(back[i]<128)counts[back[i]]++;if(solid[i]<128)counts[solid[i]]++;if(decor[i]<128)counts[decor[i]]++;}
    counts[0]=0;
    for(int slot=0;slot<16;slot++) {
        input_poll();
        int best=0;for(int i=1;i<128;i++)if(counts[i]>counts[best])best=i;
        if(!counts[best])break;counts[best]=0;
        gfx_sprite_t *source=art_sprite(theme,best);
        bool opaque=true;for(unsigned p=0;p<256;p++)if(!source->data[p]){opaque=false;break;}
        cachedOpaque[best]=opaque;
        if(opaque)memcpy(tileCache[slot],source,258);
        else gfx_ConvertToRLETSprite(source,(gfx_rletsprite_t*)tileCache[slot]);
        cachedTiles[best]=tileCache[slot];
    }
    cachedTheme=theme;
}
/* Byte offset of each row in the two cached RLET sky halves (filled when a sky is
 * cached). BSS is nearly full: the initializer keeps these in resident data. */
static const uint8_t *skyHalf[2];
/* Repair index, rebuilt when a sky is cached: each row's band colour (-1: no band) and,
 * per 64-pixel column block of each half, the RLET segment (transparent-count byte)
 * covering the block start and its x. A repair starts decoding at its own column. */
#define SKY_INDEX_ROWS 217
#define SKY_BLOCKS 3
static int16_t skyRowColor[SKY_INDEX_ROWS]={1};
static uint16_t skyRunAt[2][SKY_INDEX_ROWS][SKY_BLOCKS]={{{1}}};
static uint8_t skyRunX[2][SKY_INDEX_ROWS][SKY_BLOCKS]={{{1}}};
static const uint8_t *nextRow(const uint8_t *p,int w){
    /* RLET row: transparent count, then opaque count + pixels, repeated until the
     * width is used; no opaque count follows a run that reaches the row end. */
    for(int x=0;;){x+=*p++;if(x>=w)return p;int o=*p++;p+=o;x+=o;if(x>=w)return p;}
}
static int skyIndex(int left){return left==ART_SKY_SUNSETIMAGE_LEFT?0:left==ART_SKY_DESERTIMAGE_LEFT?1:-1;}
static void cacheSky(int sky){
    if(cachedSky==sky)return;
    memcpy(skyCache,art_sprite(artSkies[sky].left,0),artSkies[sky].leftSize);
    if(artSkies[sky].leftSize+artSkies[sky].rightSize<=sizeof skyCache)
        memcpy(skyCache+artSkies[sky].leftSize,art_sprite(artSkies[sky].right,0),artSkies[sky].rightSize);
    skyHalf[0]=skyCache;
    skyHalf[1]=artSkies[sky].leftSize+artSkies[sky].rightSize<=sizeof skyCache?skyCache+artSkies[sky].leftSize:(const uint8_t*)art_sprite(artSkies[sky].right,0);
    for(int y=0;y<SKY_INDEX_ROWS;y++)skyRowColor[y]=-1;
    for(unsigned i=0;i<artSkies[sky].groups;i++){ /* later bands overwrite earlier ones, as when drawn */
        const uint8_t*row=artSkies[sky].rows[i];
        for(int y=row[1];y<row[1]+row[2]&&y<SKY_INDEX_ROWS;y++)skyRowColor[y]=row[0];
    }
    for(int h=0;h<2;h++){
        const uint8_t*s=skyHalf[h];int w=s[0];
        const uint8_t*row=s+2;
        for(int y=0;y<s[1]&&y<SKY_INDEX_ROWS;y++,row=nextRow(row,w)){
            const uint8_t*p=row;int x=0,b=0;
            while(b<SKY_BLOCKS){
                int end=x+p[0],o=0;
                if(end<w){o=p[1];end+=o;}
                while(b<SKY_BLOCKS&&(b*64<end||end>=w)){skyRunAt[h][y][b]=p-s;skyRunX[h][y][b]=x;b++;}
                p+=2+o;x=end;
            }
        }
    }
    cachedSky=sky;
}
void art_background(int left) {
    int sky=skyIndex(left);
    if(sky>=0) {
        cacheSky(sky);
        for(unsigned i=0;i<artSkies[sky].groups;i++){
            const uint8_t*row=artSkies[sky].rows[i];gfx_SetColor(row[0]);gfx_FillRectangle_NoClip(0,row[1],320,row[2]);
            input_poll();
        }
        gfx_RLETSprite_NoClip((gfx_rletsprite_t*)skyHalf[0],0,0);
        input_poll();
        gfx_RLETSprite_NoClip((gfx_rletsprite_t*)skyHalf[1],160,0);
        return;
    }
    gfx_Sprite_NoClip(art_sprite(left,0),0,0);gfx_Sprite_NoClip(art_sprite(left,1),0,120);
    input_poll();
    gfx_Sprite_NoClip(art_sprite(left+1,0),160,0);gfx_Sprite_NoClip(art_sprite(left+1,1),160,120);
}
/* Repaint the sky of art_background(left) inside [x0,x1) x [y0,y1) only, writing
 * straight into the draw buffer. Never writes outside that rectangle. */
void art_sky_rect(int left,int x0,int y0,int x1,int y1) {
    uint8_t *buf=(const uint8_t*)gfx_vbuffer==gfx_vram?gfx_vram+320*240:gfx_vram;
    int sky=skyIndex(left);
    if(sky<0){
        for(int part=0;part<4;part++){
            const gfx_sprite_t*s=art_sprite(left+(part>>1),part&1);int sx=part&2?160:0,sy=part&1?120:0,w=s->width;
            int a=x0>sx?x0:sx,b=x1<sx+w?x1:sx+w,c=y0>sy?y0:sy,d=y1<sy+s->height?y1:sy+s->height;
            if(a>=b||c>=d)continue;
            uint8_t*out=buf+c*320+a;const uint8_t*in=s->data+(c-sy)*w+(a-sx);unsigned n=b-a;
            for(int y=c;y<d;y++,out+=320,in+=w)memcpy(out,in,n);
        }
        return;
    }
    cacheSky(sky);
    if(y1>SKY_INDEX_ROWS)y1=SKY_INDEX_ROWS; /* callers never repair the HUD panel rows */
    for(int y=y0;y<y1;){ /* band fills, grouped into runs of rows with one colour */
        int c=skyRowColor[y],y2=y+1;
        while(y2<y1&&skyRowColor[y2]==c)y2++;
        if(c>=0){gfx_SetColor(c);gfx_FillRectangle_NoClip(x0,y,x1-x0,y2-y);}
        y=y2;
    }
    for(int h=0;h<2;h++){
        /* lo/hi: the rectangle's columns relative to this half; rows stop parsing at hi. */
        const uint8_t*s=skyHalf[h];int sx=h?160:0,w=s[0],lo=x0-sx,hi=x1-sx,end=y1<s[1]?y1:s[1];
        if(lo<0)lo=0;
        if(hi>w)hi=w;
        if(lo>=hi||y0>=end)continue;
        uint8_t*out=buf+y0*320+sx;
        const uint16_t*runAt=&skyRunAt[h][y0][lo>>6];const uint8_t*runX=&skyRunX[h][y0][lo>>6];
        for(int y=y0;y<end;y++,out+=320,runAt+=SKY_BLOCKS,runX+=SKY_BLOCKS){
            const uint8_t*p=s+*runAt;
            for(int x=*runX;;){
                x+=*p++;if(x>=hi)break;
                int o=*p++,b=x+o;
                if(b>lo){int a=x<lo?lo:x,c=b>hi?hi:b;memcpy(out+a,p+(a-x),c-a);}
                if(b>=hi)break;
                p+=o;x=b;
            }
        }
    }
}

const uint8_t *art_map_data(void){return artBanks[ART_MAP_BANK]+ART_MAP_OFFSET;}
