/* Keep hot, exactly converted sprites in RAM. RLET copies opaque spans instead
 * of testing every source pixel against the transparent color in slow archive.
 */
#include "game.h"
#include "render_cache.h"
#define TILE_SLOTS 24
/* GraphX's documented worst case is (width+1)*height*3/2+2 bytes,
 * including transparency alternating at every pixel. */
#define TILE_BYTES 410
#define ACTOR_SLOTS 8
#define ACTOR_BYTES 1024
static uint8_t tile_storage[TILE_SLOTS][TILE_BYTES];
static const gfx_rletsprite_t *tile_lookup[296];
static uint8_t actor_storage[ACTOR_SLOTS][ACTOR_BYTES];
static const uint8_t *actor_keys[ACTOR_SLOTS];
static uint8_t replacement;

static void draw_rlet(const gfx_rletsprite_t *s,int x,int y) {
    if(x>=320||y>=240||x+s->width<=0||y+s->height<=0)return;
    if(x>=0&&y>=0&&x+s->width<=320&&y+s->height<=240)gfx_RLETSprite_NoClip(s,x,y);
    else gfx_RLETSprite(s,x,y);
}

void cache_stage_tiles(const uint8_t *back,const uint8_t *solid,const uint8_t *decor,unsigned cells) {
    uint16_t counts[296]={0};
    memset(tile_lookup,0,sizeof tile_lookup);
    memset(actor_keys,0,sizeof actor_keys);replacement=0;
    for(unsigned i=0;i<cells;i++){counts[back[i]]++;counts[solid[i]]++;counts[decor[i]]++;}
    counts[0]=0;
    for(unsigned slot=0;slot<TILE_SLOTS;slot++){
        unsigned best=0;
        for(unsigned t=1;t<296;t++)if(counts[t]>counts[best])best=t;
        if(!best||!counts[best])break;
        counts[best]=0;
        gfx_sprite_t *source=(gfx_sprite_t *)(tiledata[best/148]+(best%148)*258);
        gfx_ConvertToRLETSprite(source,(gfx_rletsprite_t *)tile_storage[slot]);
        tile_lookup[best]=(gfx_rletsprite_t *)tile_storage[slot];
    }
}

void cached_tile(int t,int x,int y) {
    if(t<=0||t>=296)return;
    if(tile_lookup[t])draw_rlet(tile_lookup[t],x,y);
    else cached_sprite(tiledata[t/148]+(t%148)*258,x,y);
}

void cached_sprite(const uint8_t *source,int x,int y) {
    if(!source)return;
    for(unsigned i=0;i<ACTOR_SLOTS;i++)if(actor_keys[i]==source){draw_rlet((gfx_rletsprite_t *)actor_storage[i],x,y);return;}
    unsigned w=source[0],h=source[1];
    if(!w||!h||x>=320||y>=240||x+(int)w<=0||y+(int)h<=0)return;
    if((w+1)*h*3/2+2<=ACTOR_BYTES){
        unsigned slot=replacement;replacement=(replacement+1)%ACTOR_SLOTS;
        gfx_ConvertToRLETSprite((gfx_sprite_t *)source,(gfx_rletsprite_t *)actor_storage[slot]);
        actor_keys[slot]=source;draw_rlet((gfx_rletsprite_t *)actor_storage[slot],x,y);
    }else if(x>=0&&y>=0&&x+(int)w<=320&&y+(int)h<=240)gfx_TransparentSprite_NoClip((gfx_sprite_t *)source,x,y);
    else gfx_TransparentSprite((gfx_sprite_t *)source,x,y);
}
