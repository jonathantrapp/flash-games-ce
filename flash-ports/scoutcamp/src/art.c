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
void art_background(int left) {
    int sky=left==ART_SKY_SUNSETIMAGE_LEFT?0:left==ART_SKY_DESERTIMAGE_LEFT?1:-1;
    if(sky>=0) {
        if(cachedSky!=sky){
            memcpy(skyCache,art_sprite(artSkies[sky].left,0),artSkies[sky].leftSize);
            if(artSkies[sky].leftSize+artSkies[sky].rightSize<=sizeof skyCache)
                memcpy(skyCache+artSkies[sky].leftSize,art_sprite(artSkies[sky].right,0),artSkies[sky].rightSize);
            cachedSky=sky;
        }
        for(unsigned i=0;i<artSkies[sky].groups;i++){
            const uint8_t*row=artSkies[sky].rows[i];gfx_SetColor(row[0]);gfx_FillRectangle_NoClip(0,row[1],320,row[2]);
            input_poll();
        }
        gfx_RLETSprite_NoClip((gfx_rletsprite_t*)skyCache,0,0);
        input_poll();
        const uint8_t*right=artSkies[sky].leftSize+artSkies[sky].rightSize<=sizeof skyCache?skyCache+artSkies[sky].leftSize:(const uint8_t*)art_sprite(artSkies[sky].right,0);
        gfx_RLETSprite_NoClip((gfx_rletsprite_t*)right,160,0);
        return;
    }
    gfx_Sprite_NoClip(art_sprite(left,0),0,0);gfx_Sprite_NoClip(art_sprite(left,1),0,120);
    input_poll();
    gfx_Sprite_NoClip(art_sprite(left+1,0),160,0);gfx_Sprite_NoClip(art_sprite(left+1,1),160,120);
}

const uint8_t *art_map_data(void){return artBanks[ART_MAP_BANK]+ART_MAP_OFFSET;}
