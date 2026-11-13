/* Keep hot, exactly converted sprites in RAM. RLET copies opaque spans instead
 * of testing every source pixel against the transparent color in slow archive.
 */
#include "game.h"
#include "render_cache.h"
#define TILE_SLOTS 24
/* GraphX's documented worst case is (width+1)*height*3/2+2 bytes,
 * including transparency alternating at every pixel. */
#define TILE_BYTES 410
/* Six larger slots also fit the original 23x38 tree and 25x30 hit-spark
 * sprites. Keep total storage bounded (9,600 bytes versus the old 8,192),
 * rather than repeatedly drawing those frames straight from archive. */
#define ACTOR_SLOTS 6
#define ACTOR_BYTES 1600
static uint8_t tile_storage[TILE_SLOTS][TILE_BYTES];
/* tile_slot holds cache slot + 1 (0 = not cached); slot_ptr has a power-of-two stride, so the hot
 * lookup is shifts and adds instead of the 24-bit multiply helper an array of 3-byte pointers needs. */
static uint8_t tile_slot[296];
typedef struct {const gfx_rletsprite_t *p;uint8_t unused;} SlotPtr;
static SlotPtr slot_ptr[TILE_SLOTS+1];
/* Opaque terrain needs no per-run transparency decoder. Reuse each cache
 * slot for its original sprite when all 256 pixels are opaque. */
static uint8_t tile_opaque[296];
#ifndef PEDRO_TILE_OPAQUE
#define PEDRO_TILE_OPAQUE 1
#endif
static uint8_t actor_storage[ACTOR_SLOTS][ACTOR_BYTES];
static const uint8_t *actor_keys[ACTOR_SLOTS];
static uint8_t replacement;
/* Separate from the actor LRU: drawing hearts/mail must not evict Pedro's
 * current animation frame on every frame. Keep the complete small HUD set.
 * Each slot reserves GraphX's documented worst-case output size. */
static uint8_t hud_storage[4800];
static unsigned hud_used;
static gfx_rletsprite_t *hud_lookup[UI_BADGI+1][3];
/* GraphX asks for exactly the converted size; packing the small HUD set tightly needs under 4.3 KB
 * instead of the 6.7 KB its per-sprite worst case would reserve. A sprite that does not fit simply
 * stays uncached and draw_ui falls back to the archived art. */
static void *hud_alloc(size_t bytes){
    if(bytes>sizeof hud_storage-hud_used)return NULL;
    void *p=hud_storage+hud_used;hud_used+=bytes;return p;
}
const uint8_t *cached_tile_opacity(void){return tile_opaque;}

void cache_hud(void) {
    hud_used=0;
    memset(hud_lookup,0,sizeof hud_lookup);
    for(uint8_t id=0;id<=UI_BADGI;id++){
        const UiDef *u=&uidef[id];
        if(!uiimg[id])continue;
        for(uint8_t fr=0;fr<u->frames&&fr<3;fr++){
            const uint8_t *s=uiimg[id]+fr*u->stride;
            if(s[0]==u->w&&s[1]==u->h)hud_lookup[id][fr]=gfx_ConvertToNewRLETSprite((gfx_sprite_t *)s,hud_alloc);
        }
    }
}

bool cached_hud(uint8_t id,uint8_t frame,int x,int y) {
    if(id>UI_BADGI||frame>=3||!hud_lookup[id][frame])return false;
    /* Always respect the current clip region: Fury/XP/boss meters crop their
     * foreground sprites to the current amount, even inside the LCD bounds. */
    gfx_RLETSprite(hud_lookup[id][frame],x,y);
    return true;
}

static void draw_rlet(const gfx_rletsprite_t *s,int x,int y) {
    if(x>=320||y>=240||x+s->width<=0||y+s->height<=0)return;
    if(x>=0&&y>=22&&x+s->width<=320&&y+s->height<=240)gfx_RLETSprite_NoClip(s,x,y);
    else gfx_RLETSprite(s,x,y);
}

void cache_stage_tiles(const uint8_t *back,const uint8_t *solid,const uint8_t *decor,unsigned cells) {
    uint16_t counts[296]={0};
    memset(tile_slot,0,sizeof tile_slot);
    memset(tile_opaque,0,sizeof tile_opaque);
    memset(actor_keys,0,sizeof actor_keys);replacement=0;
    for(unsigned i=0;i<cells;i++){counts[back[i]]++;counts[solid[i]]++;counts[decor[i]]++;}
    counts[0]=0;
    for(unsigned slot=0;slot<TILE_SLOTS;slot++){
        unsigned best=0;
        for(unsigned t=1;t<296;t++)if(counts[t]>counts[best])best=t;
        if(!best||!counts[best])break;
        counts[best]=0;
        gfx_sprite_t *source=(gfx_sprite_t *)(tiledata[best/148]+(best%148)*258);
        bool opaque=PEDRO_TILE_OPAQUE!=0;
        for(unsigned i=0;opaque&&i<256;i++)if(!source->data[i])opaque=false;
        if(opaque){memcpy(tile_storage[slot],source,258);tile_opaque[best]=1;}
        else gfx_ConvertToRLETSprite(source,(gfx_rletsprite_t *)tile_storage[slot]);
        slot_ptr[slot+1].p=(gfx_rletsprite_t *)tile_storage[slot];tile_slot[best]=slot+1;
    }
}

#ifdef PEDRO_PROFILE
volatile uint32_t pedro_tile_cnt[4];
#define TC(i) (pedro_tile_cnt[i]++)
#else
#define TC(i)
#endif
void cached_tile(int t,int x,int y) {
    if(t<=0||t>=296)return;
    const unsigned k=tile_slot[t];
    TC(k&&tile_opaque[t]?0:k?1:2);
    if(k&&tile_opaque[t]){
        const gfx_sprite_t *s=(const gfx_sprite_t *)slot_ptr[k].p;
        if(x>=320||y>=240||x+16<=0||y+16<=0)return;
        if(x>=0&&y>=22&&x+16<=320&&y+16<=240)gfx_Sprite_NoClip(s,x,y);
        else gfx_Sprite(s,x,y);
    }
    else if(k)draw_rlet(slot_ptr[k].p,x,y);
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
    }else if(x>=0&&y>=22&&x+(int)w<=320&&y+(int)h<=240)gfx_TransparentSprite_NoClip((gfx_sprite_t *)source,x,y);
    else gfx_TransparentSprite((gfx_sprite_t *)source,x,y);
}
