#include "../../../src/game.h"
#include "../../../src/bundle.h"
const uint8_t *artdata[60],*tiledata[2],*uidata[3][2],*uiimg[UI_COUNT];
/* Keep hot, exactly converted sprites in RAM. RLET copies opaque spans instead
 * of testing every source pixel against the transparent color in slow archive.
 */
#include "../../../src/game.h"
#include "../../../src/render_cache.h"
#define TILE_SLOTS 24
/* GraphX's documented worst case is (width+1)*height*3/2+2 bytes,
 * including transparency alternating at every pixel. */
#define TILE_BYTES 410
/* Six larger slots also fit the original 23x38 tree and 25x30 hit-spark
 * sprites. Keep total storage bounded (9,600 bytes versus the old 8,192),
 * rather than repeatedly drawing those frames straight from archive. */
#define ACTOR_SLOTS 6
#define ACTOR_BYTES 1600
static struct {uint8_t before[64],pixels[TILE_SLOTS][TILE_BYTES],after[64];} tile_guard;
#define tile_storage tile_guard.pixels
static const gfx_rletsprite_t *tile_lookup[296];
/* Opaque terrain needs no per-run transparency decoder. Reuse each cache
 * slot for its original sprite when all 256 pixels are opaque. */
static uint8_t tile_opaque[296];
#ifndef PEDRO_TILE_OPAQUE
#define PEDRO_TILE_OPAQUE 1
#endif
static struct {uint8_t before[64],pixels[ACTOR_BYTES],after[64];} actor_guard[ACTOR_SLOTS];
static const uint8_t *actor_keys[ACTOR_SLOTS];
static uint8_t replacement;
/* Separate from the actor LRU: drawing hearts/mail must not evict Pedro's
 * current animation frame on every frame. Keep the complete small HUD set.
 * Each slot reserves GraphX's documented worst-case output size. */
static struct {uint8_t before[64],pixels[7000],after[64];} hud_guard;
#define hud_storage hud_guard.pixels
static gfx_rletsprite_t *hud_lookup[UI_BADGI+1][3];

void cache_hud(void) {
    unsigned used=0;
    memset(hud_lookup,0,sizeof hud_lookup);
    for(uint8_t id=0;id<=UI_BADGI;id++){
        const UiDef *u=&uidef[id];
        unsigned bytes=((unsigned)u->w+1)*u->h*3/2+2;
        if(!uiimg[id])continue;
        for(uint8_t fr=0;fr<u->frames&&fr<3;fr++){
            const uint8_t *s=uiimg[id]+fr*u->stride;
            if(s[0]!=u->w||s[1]!=u->h||bytes>sizeof hud_storage-used)continue;
            gfx_rletsprite_t *out=(gfx_rletsprite_t *)(hud_storage+used);
            gfx_ConvertToRLETSprite((gfx_sprite_t *)s,out);
            hud_lookup[id][fr]=out;used+=bytes;
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
    if(x>=0&&y>=0&&x+s->width<=320&&y+s->height<=240)gfx_RLETSprite_NoClip(s,x,y);
    else gfx_RLETSprite(s,x,y);
}

void cache_stage_tiles(const uint8_t *back,const uint8_t *solid,const uint8_t *decor,unsigned cells) {
    uint16_t counts[296]={0};
    memset(tile_lookup,0,sizeof tile_lookup);
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
        tile_lookup[best]=(gfx_rletsprite_t *)tile_storage[slot];
    }
}

void cached_tile(int t,int x,int y) {
    if(t<=0||t>=296)return;
    if(tile_lookup[t]&&tile_opaque[t]){
        const gfx_sprite_t *s=(const gfx_sprite_t *)tile_lookup[t];
        if(x>=320||y>=240||x+16<=0||y+16<=0)return;
        if(x>=0&&y>=0&&x+16<=320&&y+16<=240)gfx_Sprite_NoClip(s,x,y);
        else gfx_Sprite(s,x,y);
    }
    else if(tile_lookup[t])draw_rlet(tile_lookup[t],x,y);
    else cached_sprite(tiledata[t/148]+(t%148)*258,x,y);
}

void cached_sprite(const uint8_t *source,int x,int y) {
    if(!source)return;
    for(unsigned i=0;i<ACTOR_SLOTS;i++)if(actor_keys[i]==source){draw_rlet((gfx_rletsprite_t *)actor_guard[i].pixels,x,y);return;}
    unsigned w=source[0],h=source[1];
    if(!w||!h||x>=320||y>=240||x+(int)w<=0||y+(int)h<=0)return;
    if((w+1)*h*3/2+2<=ACTOR_BYTES){
        unsigned slot=replacement;replacement=(replacement+1)%ACTOR_SLOTS;
        gfx_ConvertToRLETSprite((gfx_sprite_t *)source,(gfx_rletsprite_t *)actor_guard[slot].pixels);
        actor_keys[slot]=source;draw_rlet((gfx_rletsprite_t *)actor_guard[slot].pixels,x,y);
    }else if(x>=0&&y>=0&&x+(int)w<=320&&y+(int)h<=240)gfx_TransparentSprite_NoClip((gfx_sprite_t *)source,x,y);
    else gfx_TransparentSprite((gfx_sprite_t *)source,x,y);
}

static const uint8_t *banks[BUNDLE_BANKS];
volatile uint16_t render_diag[8]; /* done,stage_montages,hud_montages,pixel_fail,canary_fail,opaque_selections,actor_montages,visible */
static bool load(void){for(int i=0;i<BUNDLE_BANKS;i++){char n[9];snprintf(n,sizeof n,"PDB%02d",i);uint8_t f=ti_Open(n,"r");if(!f)return false;unsigned sz=ti_GetSize(f);const uint8_t*p=ti_GetDataPtr(f);bool ok=sz==bundle_bank_sizes[i]&&!memcmp(p,bundle_signature,8)&&p[8]==i;ti_Close(f);if(!ok)return false;banks[i]=p;}return true;}
static const uint8_t *resource(const char*n){for(unsigned i=0;i<COUNT(bundle);i++)if(!strcmp(n,bundle[i].name))return banks[bundle[i].bank]+bundle[i].offset;uint8_t f=ti_Open(n,"r");if(!f)return NULL;const uint8_t*p=ti_GetDataPtr(f);ti_Close(f);return p;}
static void clear(void){gfx_SetClipRegion(0,0,320,240);gfx_SetDrawScreen();gfx_FillScreen(7);gfx_SetDrawBuffer();gfx_FillScreen(7);}
static void compare(void){if(memcmp(gfx_vram,gfx_vram+76800,76800))render_diag[3]++;}
static void guards(void){for(unsigned i=0;i<64;i++){if(hud_guard.before[i]!=0xa5||hud_guard.after[i]!=0xa5||tile_guard.before[i]!=0xa5||tile_guard.after[i]!=0xa5){render_diag[4]++;break;}for(unsigned j=0;j<ACTOR_SLOTS;j++)if(actor_guard[j].before[i]!=0xa5||actor_guard[j].after[i]!=0xa5){render_diag[4]++;return;}}}
static void actors(bool cached,int edge){int count=0;for(int id=0;id<60;id++)if(artdata[id])for(int face=0;face<2;face++){
 const ArtDef*a=&artdef[id];unsigned frame=(id+edge)%a->frames;const uint8_t*s=artdata[id]+(face*a->frames+frame)*a->stride;
 int x=(count%8)*40+(edge==1?-20:edge==2?300:0),y=(count/8)*24+(edge==3?-20:edge==4?228:0);count++;
 if(cached)cached_sprite(s,x,y);else gfx_TransparentSprite((gfx_sprite_t*)s,x,y);
}}
static void hud_montage(bool cached,int xoffset){int count=0;for(uint8_t id=0;id<=UI_BADGI;id++)for(uint8_t f=0;f<uidef[id].frames;f++){
 int x=(count%4)*80+xoffset,y=(count/4)*30+2;count++;
 if(cached){if(!cached_hud(id,f,x,y))render_diag[3]++;}
 else gfx_TransparentSprite((gfx_sprite_t *)(uiimg[id]+f*uidef[id].stride),x,y);
}}
int main(void){gfx_Begin();gfx_SetDefaultPalette(gfx_8bpp);gfx_SetDrawBuffer();gfx_SetTransparentColor(0);memset(&hud_guard,0xa5,sizeof hud_guard);memset(&tile_guard,0xa5,sizeof tile_guard);memset(actor_guard,0xa5,sizeof actor_guard);
 if(!load()){render_diag[0]=2;}else{
  tiledata[0]=resource("PDTILE0");tiledata[1]=resource("PDTILE1");for(int id=0;id<=UI_BADGI;id++)uiimg[id]=resource(uidef[id].name);
  for(int id=0;id<60;id++)if(artdef[id].frames){char name[9];snprintf(name,sizeof name,"PDG%02d",id);artdata[id]=resource(name);}
  if(!tiledata[0]||!tiledata[1])render_diag[0]=2;else{
   cache_hud();guards();
   for(int stage=1;stage<=15;stage++){
    char name[9];snprintf(name,sizeof name,"PDLV%02d",stage);const uint8_t*p=resource(name);if(!p){render_diag[0]=2;break;}
    unsigned n=(p[0]+256*p[1])*(p[2]+256*p[3]);cache_stage_tiles(p+4,p+4+n,p+4+n*2,n);guards();
    for(unsigned i=1;i<296;i++)render_diag[5]+=tile_opaque[i]!=0;
    clear();gfx_SetDrawScreen();for(int t=1;t<296;t++)gfx_TransparentSprite((gfx_sprite_t *)(tiledata[t/148]+(t%148)*258),(t%20)*16,(t/20)*16);
    gfx_SetDrawBuffer();for(int t=1;t<296;t++)cached_tile(t,(t%20)*16,(t/20)*16);compare();render_diag[1]++;
   }
   for(int edge=0;edge<4;edge++){
    const int dx[4]={-8,8,-319,319},dy[4]={-8,8,-239,239};
    clear();gfx_SetDrawScreen();for(int t=1;t<296;t++)gfx_TransparentSprite((gfx_sprite_t *)(tiledata[t/148]+(t%148)*258),(t%20)*16+dx[edge],(t/20)*16+dy[edge]);
    gfx_SetDrawBuffer();for(int t=1;t<296;t++)cached_tile(t,(t%20)*16+dx[edge],(t/20)*16+dy[edge]);compare();guards();render_diag[1]++;
   }
   for(int clipped=0;clipped<4;clipped++)for(int shift=0;shift<2;shift++){
    clear();if(clipped==1)gfx_SetClipRegion(17,9,301,173);if(clipped==2)gfx_SetClipRegion(260,0,310,240);if(clipped==3)gfx_SetClipRegion(0,0,320,22);
    gfx_SetDrawScreen();hud_montage(false,shift?-12:0);gfx_SetDrawBuffer();hud_montage(true,shift?-12:0);compare();guards();render_diag[2]++;
   }
   for(int edge=0;edge<5;edge++){
    clear();gfx_SetDrawScreen();actors(false,edge);gfx_SetDrawBuffer();actors(true,edge);compare();guards();render_diag[6]++;
    /* Redraw after cache eviction to exercise both misses and hits. */
    clear();gfx_SetDrawScreen();actors(false,edge);gfx_SetDrawBuffer();actors(true,edge);compare();guards();render_diag[6]++;
   }
   if(!render_diag[0])render_diag[0]=1;
  }
 }
 gfx_SetClipRegion(0,0,320,240);gfx_SetDrawBuffer();gfx_FillScreen(0);gfx_SetTextFGColor(255);char text[48];gfx_PrintStringXY("Native render cache comparison",6,12);for(int i=0;i<7;i++){snprintf(text,sizeof text,"%d: %d",i,render_diag[i]);gfx_PrintStringXY(text,12,35+i*23);}gfx_SwapDraw();gfx_Wait();render_diag[7]=1;while(1){kb_Scan();}
}
