#include "../../../src/game.h"
#include "../../../src/bundle.h"
#include "../../../src/dialogue_data.h"
#include "../../../src/render_cache.h"
Game g;Progress progress;
const uint8_t *artdata[60],*tiledata[2],*uidata[3][2],*uiimg[UI_COUNT],*pedro_flame;
static const uint8_t *banks[BUNDLE_BANKS];
int absi(int v){return v<0?-v:v;}
int clampi(int v,int lo,int hi){return v<lo?lo:(v>hi?hi:v);}
static bool open_banks(void){for(int i=0;i<BUNDLE_BANKS;i++){char name[9];snprintf(name,sizeof name,"PDB%02d",i);uint8_t f=ti_Open(name,"r");if(!f)return false;unsigned size=ti_GetSize(f);const uint8_t *p=ti_GetDataPtr(f);bool valid=size==bundle_bank_sizes[i]&&size>=11&&!memcmp(p,bundle_signature,8)&&p[8]==i&&(unsigned)(p[9]+256*p[10])==size;ti_Close(f);if(!valid)return false;banks[i]=p;}return true;}
const uint8_t *bundle_find(const char *name,unsigned *size){for(unsigned i=0;i<COUNT(bundle);i++)if(!strcmp(bundle[i].name,name)){if(size)*size=bundle[i].size;return banks[bundle[i].bank]+bundle[i].offset;}return NULL;}
static const uint8_t *resource(const char *name,unsigned min){unsigned size=0;const uint8_t *p=bundle_find(name,&size);if(p)return size>=min?p:NULL;uint8_t f=ti_Open(name,"r");if(!f)return NULL;p=ti_GetSize(f)>=min?ti_GetDataPtr(f):NULL;ti_Close(f);return p;}
bool load_resources(void){
 if(!open_banks())return false;
 pedro_flame=resource("PDPFLAME",13*722);if(!pedro_flame)return false;
 const uint8_t *pal=resource("PDCOLOR",512);if(!pal)return false;gfx_SetPalette(pal,512,0);
 tiledata[0]=resource("PDTILE0",148*258);tiledata[1]=resource("PDTILE1",148*258);
 for(int i=0;i<60;i++){char name[9];snprintf(name,sizeof name,"PDG%02d",i);if(artdef[i].frames)artdata[i]=resource(name,artdef[i].stride*artdef[i].frames*2);}
 for(int i=0;i<3;i++)for(int half=0;half<2;half++){char name[9];snprintf(name,sizeof name,"PDU%d%d",i,half);uidata[i][half]=resource(name,38402);}
 for(int i=0;i<UI_COUNT;i++)uiimg[i]=resource(uidef[i].name,uidef[i].stride*uidef[i].frames);
 return tiledata[0]&&tiledata[1]&&artdata[0]&&artdata[2]&&uidata[0][0]&&uidata[0][1]&&uidata[1][0]&&uidata[1][1]&&uidata[2][0]&&uidata[2][1]&&uiimg[UI_HEART]&&uiimg[UI_SKI]&&uiimg[UI_SKB];
}
void draw_sprite(int id,int fr,int facing,int x,int y){if(id<0||id>=60||!artdata[id])return;const ArtDef *a=&artdef[id];if(!a->frames||x>=320||y>=240||x+a->w<=0||y+a->h<=0)return;if(fr<0)fr=0;else if(fr>=a->frames)fr%=a->frames;cached_sprite(artdata[id]+((facing<0?a->frames:0)+fr)*a->stride,x,y);}
void draw_ui(int id,int fr,int x,int y){if(id<0||id>=UI_COUNT||!uiimg[id])return;const UiDef *u=&uidef[id];if(fr<0)fr=0;if(fr>=u->frames)fr=u->frames-1;if(!cached_hud(id,fr,x,y))gfx_TransparentSprite((gfx_sprite_t *)(uiimg[id]+fr*u->stride),x,y);}
int maxlife(void){int n=5;for(int i=0;i<15;i++)n+=progress.hearts[i]!=0;return n*100;}
int maxfury(void){int n=1;for(int i=0;i<15;i++)n+=progress.souls[i]!=0;return (n>5?5:n)*100;}
void story_draw(void){
 gfx_SetColor(cPanel);gfx_FillRectangle(14,37,292,117);gfx_SetColor(cWhite);gfx_Rectangle(14,37,292,117);gfx_SetTextFGColor(cWhite);wrap_text(23,47,274,dialogue_pages[g.story_event][g.story_page],11);gfx_SetTextFGColor(cYellow);center_text(163,"Alpha / Del / ENTER: continue");gfx_SetTextFGColor(cWhite);
}
bool intro_is_active(void){return false;}
void intro_camera(int*x,int*y){(void)x;(void)y;}
void intro_draw(int x,int y){(void)x;(void)y;}
int enemy_status_value(const Enemy*e,int which){return which==0?e->stun:0;}
void ref_draw_game(void);
/* World, actor and HUD drawing for Pedro Kicks Back CE. */
#include "../../../src/game.h"
#include "../../../src/sky_rows.h"
#include "../../../src/intro.h"
#include "../../../src/render_cache.h"
#ifdef PEDRO_PROFILE
#include <sys/timers.h>
volatile uint32_t pedro_draw_profile[6];
#define DRAW_START uint32_t phase_time=timer_GetSafe(1,TIMER_UP)
#define DRAW_PHASE(i) do { uint32_t n=timer_GetSafe(1,TIMER_UP);pedro_draw_profile[i]=n-phase_time;phase_time=n; }while(0)
#else
#define DRAW_START
#define DRAW_PHASE(i)
#endif

uint8_t cBlack, cWhite = 255, cYellow = 254, cGold = 252, cRed, cGreen, cCyan, cPanel;
static int camx, camy;
extern const uint8_t *pedro_flame;
int enemy_status_value(const Enemy *e,int which);
static uint8_t flat_sprite[2+64*8];
/* Initialized storage lives in the guarded resident program region, leaving
 * the small BSS/allocator region available for runtime work. The panel is
 * opaque; two 150-pixel sprites retain every original panel/text pixel. */
static struct {uint8_t before[64],pixels[2+150*14],after[64];} notice_guard[2]={{{1}}};
static char notice_text[96];
static uint8_t notice_colors[3];
static bool notice_valid;
typedef struct {int x0,y0,x1,y1;} Damage;
typedef struct {int x,y;uint8_t type;int8_t face;} SceneryStamp;
#define DAMAGE_RECTS 24
typedef struct {
    Damage rect[DAMAGE_RECTS];uint8_t solid[21*16],count;
    SceneryStamp scenery[24];uint8_t scenery_count;
    int x,y,level;uint32_t tick;bool valid,overflow,had_notice;
} SceneCache;
static struct {uint8_t before[64];SceneCache values[2];uint8_t after[64];} scene_guard;
#define scene_cache scene_guard.values
volatile uint32_t pedro_render_stats[3]; /* full redraws, reused backgrounds, overflow fallbacks */
static SceneCache *drawing_scene;
void invalidate_scene_cache(void){scene_cache[0].valid=scene_cache[1].valid=false;}
static void damage(int x,int y,int w,int h){
    if(!drawing_scene)return;
    Damage r={x-2,y-2,x+w+2,y+h+2};
    if(r.x0<0)r.x0=0;if(r.y0<22)r.y0=22;if(r.x1>320)r.x1=320;if(r.y1>240)r.y1=240;
    if(r.x0>=r.x1||r.y0>=r.y1)return;
    for(unsigned i=0;i<drawing_scene->count;){
        Damage *d=&drawing_scene->rect[i];
        if(r.x0<d->x1&&r.x1>d->x0&&r.y0<d->y1&&r.y1>d->y0){
            if(d->x0<r.x0)r.x0=d->x0;if(d->y0<r.y0)r.y0=d->y0;
            if(d->x1>r.x1)r.x1=d->x1;if(d->y1>r.y1)r.y1=d->y1;
            *d=drawing_scene->rect[--drawing_scene->count];i=0;
        }else i++;
    }
    if(drawing_scene->count==DAMAGE_RECTS){drawing_scene->overflow=true;return;}
    drawing_scene->rect[drawing_scene->count++]=r;
}

static void draw_notice(void) {
    if(!notice_valid||strncmp(notice_text,g.notice,sizeof notice_text)||
       notice_colors[0]!=cPanel||notice_colors[1]!=cWhite||notice_colors[2]!=cYellow){
        gfx_SetColor(cPanel);gfx_FillRectangle(10,206,300,14);
        gfx_SetColor(cWhite);gfx_Rectangle(10,206,300,14);
        gfx_SetTextFGColor(cYellow);center_text(209,g.notice);
        if(gfx_GetStringWidth(g.notice)>296){notice_valid=false;damage(0,206,320,14);return;}
        for(unsigned i=0;i<2;i++){
            gfx_sprite_t *s=(gfx_sprite_t *)notice_guard[i].pixels;s->width=150;s->height=14;
            gfx_GetSprite(s,10+i*150,206);
        }
        strncpy(notice_text,g.notice,sizeof notice_text-1);notice_text[sizeof notice_text-1]=0;
        notice_colors[0]=cPanel;notice_colors[1]=cWhite;notice_colors[2]=cYellow;notice_valid=true;
    }else{
        gfx_Sprite_NoClip((gfx_sprite_t *)notice_guard[0].pixels,10,206);
        gfx_Sprite_NoClip((gfx_sprite_t *)notice_guard[1].pixels,160,206);
        gfx_SetColor(cWhite);gfx_SetTextFGColor(cYellow);
    }
}

static void draw_flattened(const Enemy *e,const ArtDef *a,int x,int y) {
    unsigned h=(a->h+9)/10;
    if(a->w>64||h>8||!artdata[e->type]){damage(x-camx,y-camy+22,a->w,a->h);draw_sprite(e->type,0,e->face,x-camx,y-camy+22);return;}
    flat_sprite[0]=a->w;flat_sprite[1]=h;
    damage(x-camx,y-camy+22+a->h-h,a->w,h);
    const uint8_t *p=artdata[e->type]+(e->face<0?a->frames:0)*a->stride+2;
    for(unsigned row=0;row<h;row++)memcpy(flat_sprite+2+row*a->w,p+(row*a->h/h)*a->w,a->w);
    gfx_TransparentSprite((gfx_sprite_t *)flat_sprite,x-camx,y-camy+22+a->h-h);
}

static void draw_sky_region(int left,int top,int right,int bottom) {
    gfx_Wait();
    uint8_t *dest=(uint8_t *)gfx_vbuffer+top*320+left;
    unsigned width=right-left;
    for(unsigned y=top;y<(unsigned)bottom;y++,dest+=320){
        unsigned offset=sky_row_offsets[y];
        if(offset==65535)memset(dest,sky_row_colors[y],width);
        else memcpy(dest,sky_row_pixels+offset+left,width);
    }
}
static void draw_sky(int bottom){draw_sky_region(0,22,320,bottom);}

static uint8_t nearest_color(const uint8_t *palette, int r, int g, int b) {
    int best = 1, best_distance = 0x7fffff;
    for (int i = 1; i < 256; i++) {
        int p = palette[i * 2] | (palette[i * 2 + 1] << 8), pr = ((p >> 10) & 31) * 255 / 31, pg = ((p >> 5) & 31) * 255 / 31, pb = (p & 31) * 255 / 31;
        int d = (pr - r) * (pr - r) + (pg - g) * (pg - g) + (pb - b) * (pb - b);
        if (d < best_distance) { best_distance = d; best = i; }
    }
    return (uint8_t)best;
}
void pick_colors(void) {
    uint8_t f = ti_Open("PDCOLOR", "r");
    if (!f) return;
    const uint8_t *palette = ti_GetDataPtr(f);
    ti_Close(f);
    cBlack = nearest_color(palette, 0, 0, 0); cRed = nearest_color(palette, 230, 30, 30); cGreen = nearest_color(palette, 40, 200, 60);
    cCyan = nearest_color(palette, 90, 220, 255); cPanel = nearest_color(palette, 24, 24, 48);
    cWhite = 255; cYellow = 254; cGold = 252;
}

/* GraphX does not clip text at the right edge (it wraps into the next scanline), so truncate to fit. */
void print_fit(const char *s, int x, int y) {
    if (!s || y < 0 || y > 232 || x > 315) return;
    if (x < 0) x = 0;
    if (x + (int)gfx_GetStringWidth(s) <= 316) { gfx_PrintStringXY(s, x, y); return; }
    char buffer[96] = {0}; int n = 0;
    while (s[n] && n < 90) { buffer[n] = s[n]; buffer[n + 1] = 0; if (x + (int)gfx_GetStringWidth(buffer) > 316) { buffer[n] = 0; break; } n++; }
    gfx_PrintStringXY(buffer, x, y);
}
void center_text(int y, const char *s) { int w = gfx_GetStringWidth(s); print_fit(s, w >= 316 ? 2 : (320 - w) / 2, y); }
void wrap_text(int x, int y, int width, const char *s, int step) {
    char line[96]; int n = 0;
    if (!s || width <= 0 || step <= 0) return;
    while (*s && y <= 232) {
        if (*s == '\n') { line[n] = 0; print_fit(line, x, y); n = 0; y += step; s++; continue; }
        if (*s == ' ') { if (n && n < 90) line[n++] = ' '; s++; continue; }
        int len = 0; while (s[len] && s[len] != ' ' && s[len] != '\n') len++;
        if (len > 40) len = 40;
        /* Check capacity before copying: a narrow-font line can contain many
         * characters even when it still fits the requested pixel width. */
        if (n + len >= (int)sizeof line) {
            line[n] = 0; print_fit(line, x, y); y += step; n = 0;
            if (y > 232) break;
        }
        memcpy(line + n, s, len); line[n + len] = 0;
        if (n && (int)gfx_GetStringWidth(line) > width) {
            while (n && line[n - 1] == ' ') n--;
            line[n] = 0; print_fit(line, x, y); y += step; memcpy(line, s, len); n = len; line[n] = 0;
        } else n += len;
        s += len;
    }
    line[n] = 0; if (n) print_fit(line, x, y);
}

static void tile(int t, int x, int y) {
    cached_tile(t,x,y);
}
static void restore_region(const Damage *r){
    draw_sky_region(r->x0,r->y0,r->x1,r->y1);
    int x0=(camx+r->x0)/16,x1=(camx+r->x1-1)/16+1;
    int y0=(camy+r->y0-22)/16,y1=(camy+r->y1-23)/16+1;
    if(x1>(int)g.w)x1=g.w;if(y1>(int)g.h)y1=g.h;
    for(int y=y0;y<y1;y++){
        const uint8_t *b=g.back+y*g.w,*s=g.solid+y*g.w;
        for(int x=x0;x<x1;x++){
            int sx=x*16-camx,sy=y*16-camy+22;
            if(b[x])tile(b[x],sx,sy);if(s[x])tile(s[x],sx,sy);
        }
    }
}
static int pedro_frame(void) {
    static const uint8_t walk[5] = {1, 2, 3, 4, 0}, crawl[4] = {5, 23, 24, 23}, carrywalk[5] = {11, 12, 13, 14, 10}, kick[6] = {7, 6, 6, 6, 6, 7};
    static const uint8_t punch1[7] = {21, 20, 21, 22, 23, 23, 23}, punch2[7] = {19, 18, 18, 17, 17, 17, 17}, talk[4] = {27, 28, 29, 28}, tornado[3] = {25, 26, 25}, ken[4] = {31, 32, 33, 34};
    int t = g.ticks / 3, moving = absi(g.vx) > 3 && g.ground;
    if (g.mode == DIALOGUE) return talk[(g.ticks / 6) % 4];
    switch (g.action) {
    case PA_IDLE: return moving ? walk[t % 5] : 0;
    case PA_JUMP: return 15;
    case PA_GLIDE: return 6;
    case PA_DASH: return 30;
    case PA_DUCK: return moving ? crawl[t % 4] : 5;
    case PA_JUMPKICK: return kick[clampi((12 - g.actiontime) * 6 / 12, 0, 5)];
    case PA_CARRY: return moving ? carrywalk[t % 5] : 10;
    case PA_CARRYJUMP: return 16;
    case PA_PUNCH: { int p = clampi((10 - g.actiontime) * 7 / 10, 0, 6); return (g.combo & 1) ? punch1[p] : punch2[p]; }
    case PA_HITSTUN: return 24;
    case PA_TORNADO: return tornado[t % 3];
    case PA_FURYPICK: case PA_FURYHEAL: return 10;
    case PA_INACTIVE: return talk[(g.ticks / 6) % 4];
    case PA_DIVEKICK: return 7;
    case PA_PEDROKEN: return ken[clampi((30 - g.actiontime) / 8, 0, 3)];
    case PA_CHARGEKICK: return g.vy < -20 ? 8 : g.vy > 20 ? 7 : 6;
    case PA_PILEDRIVE: return 35;
    default: return 0;
    }
}
static void sprite_at(int id, int frame, int face, int x, int y) { damage(x-camx,y-camy+22,artdef[id].w,artdef[id].h);draw_sprite(id, frame, face, x - camx, y - camy + 22); }
static void prop_sprite(const Prop *p) {
    int id = p->type, frame = 0, x = p->x, y = p->y;
    const ArtDef *a = &artdef[id];
    if (id == 48) { sprite_at(48, p->state, 1, p->x, p->y + ((g.ticks / 6) & 1)); return; }
    if (!a->frames) return;
    x = p->x + 8 - a->w / 2; y = p->y + 16 - a->h;
    if (id == 13 || id == 14 || id == 44) frame = p->state ? 4 : 0;
    else if (id == 15) frame = (g.ticks / 4) % a->frames;
    else if (id >= 20 && id <= 22) frame = id - 20;
    else if (id >= 23 && id <= 25) frame = id - 23;
    else if (id == 30 || id == 31) frame = id - 30;
    else if (id == 32 || id == 33) frame = id - 32;
    else if (id == 18) { x = p->x - 32 + 44; y = p->y - 5; }
    else if (id == 19) { x = p->x - 32; y = p->y - 5; }
    else if (id == 43) { x = p->x + 3 - a->w / 2; y = p->y + 16 - a->h; frame = (g.ticks / 2) % a->frames; }
    /* These scenery props never move, animate or disappear within a stage.
     * Always repaint them after actor cleanup, without erasing them first. */
    if((id>=18&&id<=25)||(id>=30&&id<=34))draw_sprite(id,frame,p->face,x-camx,y-camy+22);
    else sprite_at(id, frame, p->face, x, y);
}
void shot_sprite(const Shot *s) {
    int x = s->x / 16, y = s->y / 16;
    if(s->type==60){if(pedro_flame){damage(x-10-camx,y-18-camy+22,20,36);cached_sprite(pedro_flame+clampi(s->frame,0,12)*722,x-10-camx,y-18-camy+22);}return;}
    if(s->type>=60)return;
    if (s->type == 51) { damage(x-camx-3,y-camy+19,7,7);gfx_SetColor(cYellow); gfx_FillCircle(x - camx, y - camy + 22, 3); return; }
    const ArtDef *a = &artdef[s->type];
    if (!a->frames) return;
    sprite_at(s->type, s->frame, s->face, x - a->w / 2, y - a->h / 2);
}
static void clipped_ui(int id, int frame, int x, int y, int clip_x0, int clip_x1) {
    gfx_SetClipRegion(clip_x0, 0, clip_x1, 240); draw_ui(id, frame, x, y); gfx_SetClipRegion(0, 0, 320, 240);
}
static void draw_hud(void) {
    damage(217,228,100,10);
    if(progress.points)damage(4,228,96,10);
    int mail_y=3+((maxlife()/100+9)/10)*10+2;
    if(g.totalmail&&mail_y+11>22)damage(3,mail_y,(g.totalmail<26?g.totalmail:26)*12-1,11);
    int hearts = maxlife() / 100, blink = (g.ticks / 6) & 1;
    for (int i = 0; i < hearts; i++) {
        int frame = g.hp >= i * 100 + 50 ? 1 : 0;
        if (frame && g.hp <= 100 && blink) frame = 2;
        draw_ui(UI_HEART, frame, 3 + (i % 10) * 10, 3 + (i / 10) * 10);
    }
    for (int i = 0; i < g.totalmail && i < 26; i++) draw_ui(UI_MAIL, i >= g.mailleft ? 1 : 0, 3 + i * 12, 3 + ((hearts + 9) / 10) * 10 + 2);
    int boxes = maxfury() / 100, whole = g.fury / 100, part = g.fury % 100;
    draw_ui(UI_FURY, 0, 255, 2);
    if (part) clipped_ui(UI_FURYI, 0, 256, 3, 256 + 61 - 61 * part / 100, 256 + 61);
    for (int i = 0; i < boxes; i++) draw_ui(UI_FBOX, i < whole ? 1 + (g.fury >= maxfury() && blink) : 0, 256 + i * 8, 13);
    int need = progress.rank * 10 + 50;
    draw_ui(UI_XP, 0, 247, 229);
    if (progress.xp) clipped_ui(UI_XP, 1, 247, 229, 247, 247 + 68 * progress.xp / need);
    char text[24]; snprintf(text, sizeof text, "Lv %d", progress.rank + 1);
    gfx_SetTextFGColor(cWhite); gfx_PrintStringXY(text, 217, 228);
    if (progress.points) { snprintf(text, sizeof text, "+%d pts", progress.points); gfx_SetTextFGColor(cYellow); gfx_PrintStringXY(text, 4, 228); }
    for (int i = 0; i < g.enemies; i++) {
        const Enemy *e = &g.enemy[i];
        if (e->active && (e->type == 39 || e->type == 40 || e->type == 46) && absi(e->x - g.px) < 320 * 16) {
            draw_ui(UI_BADG, 0, 128, 3);
            int w = 59 * clampi(e->hp, 0, e->maxhp) / (e->maxhp ? e->maxhp : 1);
            if (w) clipped_ui(UI_BADGI, 0, 130, 5, 130, 130 + w);
            break;
        }
    }
    if (g.arena >= 0 && g.arenaround < 5) {
        damage(0,25,320,10);
        snprintf(text, sizeof text, "Round %d/5  %ds", g.arenaround + 1, g.arenatime / 30);
        gfx_SetTextFGColor(g.arenatime > 0 ? cYellow : cRed); center_text(26, text);
    }
    if (g.notice_timer && g.notice) {
        draw_notice();
    }
}
void draw_game(void) {
    DRAW_START;
    drawing_scene=NULL;
    int tx = g.px / 16 + 4 - 160, ty = g.py / 16 + 8 - 120;
    if (g.ticks <= 1) { camx = tx; camy = ty; }
    camx += (clampi(tx, 0, (int)g.w * 16 - 320) - camx) / 3; camy += (clampi(ty, 0, (int)g.h * 16 - 218) - camy) / 3;
    camx = clampi(camx, 0, (int)g.w * 16 - 320 < 0 ? 0 : (int)g.w * 16 - 320); camy = clampi(camy, 0, (int)g.h * 16 - 218 < 0 ? 0 : (int)g.h * 16 - 218);
    if(intro_is_active())intro_camera(&camx,&camy);
    int x0 = camx / 16, y0 = camy / 16, x1 = (camx + 320) / 16 + 1, y1 = (camy + 218) / 16 + 1;
    if (x1 > (int)g.w) x1 = g.w; if (y1 > (int)g.h) y1 = g.h;
    /* Keep immutable loop data local: drawing calls cannot force a reload and
     * software multiply of g.w for every single visible tile. */
    const unsigned width=g.w;
    const uint8_t *back=g.back,*solid=g.solid,*decor=g.decor,*good=g.good;
    SceneCache *cached=&scene_cache[(uint8_t *)gfx_vbuffer==gfx_vram?0:1];
    bool reuse=cached->valid&&!cached->overflow&&cached->level==g.level&&cached->x==camx&&cached->y==camy&&g.ticks>=cached->tick&&g.mode==PLAY&&!intro_is_active();
    if(cached->overflow)pedro_render_stats[2]++;
    unsigned cell=0;
    for(int y=y0;y<y1;y++)for(int x=x0;x<x1;x++){
        uint8_t value=solid[y*width+x];if(cached->solid[cell]!=value)reuse=false;cached->solid[cell++]=value;
    }
    unsigned scenery_count=0;
    for(int i=0;i<g.props;i++){
        const Prop*p=&g.prop[i];int id=p->type;
        if(!p->active||!((id>=18&&id<=25)||(id>=30&&id<=34))||p->x<camx-160||p->x>camx+480||p->y<camy-160||p->y>camy+400)continue;
        if(scenery_count==24){reuse=false;scenery_count=255;break;}
        SceneryStamp *stamp=&cached->scenery[scenery_count++];
        if(stamp->x!=p->x||stamp->y!=p->y||stamp->type!=id||stamp->face!=p->face)reuse=false;
        *stamp=(SceneryStamp){p->x,p->y,id,p->face};
    }
    if(cached->scenery_count!=scenery_count)reuse=false;cached->scenery_count=scenery_count;
    int sky_bottom=240;
    const uint8_t *opaque=cached_tile_opacity();
    if(width>=20)for(int y=y1-1;y>=y0;y--){
        int sy=y*16-camy+22;if(sy>=240)continue;if(sy+16<sky_bottom)break;
        const uint8_t *s=solid+y*width,*b=back+y*width,*d=decor+y*width;
        bool covered=true;
        for(int x=x0;x<x1;x++)if(!opaque[s[x]]&&!opaque[b[x]]&&!opaque[d[x]]){covered=false;break;}
        if(!covered)break;sky_bottom=sy<22?22:sy;
    }
    if(reuse){
        pedro_render_stats[1]++;for(unsigned i=0;i<cached->count;i++)restore_region(&cached->rect[i]);
        if(cached->had_notice&&(!g.notice_timer||!g.notice)){Damage r={10,206,310,220};restore_region(&r);}
    }
    else {pedro_render_stats[0]++;draw_sky(sky_bottom);}
    DRAW_PHASE(0);
    if(!reuse)for(int y=y0,sy=y0*16-camy+22;y<y1;y++,sy+=16){
        const uint8_t *b=back+y*width,*s=solid+y*width;
        for(int x=x0,sx=x0*16-camx;x<x1;x++,sx+=16){int t=b[x];if(t)tile(t,sx,sy);t=s[x];if(t)tile(t,sx,sy);}
    }
    DRAW_PHASE(1);
    cached->count=0;cached->overflow=false;drawing_scene=cached;
    for (int i = 0; i < g.props; i++) if (g.prop[i].active) prop_sprite(&g.prop[i]);
    for (int y = y0; y < y1; y++) for (int x = x0; x < x1; x++) {
        int t = good[y * width + x], which = t == 12 ? 5 : t == 6 ? 0 : (t >= 7 && t <= 9) ? t - 6 : t == 36 ? 4 : t == 37 ? 6 : -1;
        if (which >= 0) sprite_at(48, which, 1, x * 16, y * 16 + ((g.ticks / 6) & 1));
    }
    for (int i = 0; i < g.enemies; i++) {
        const Enemy *e = &g.enemy[i]; if (!e->active || (e->type==35&&e->state==5)) continue;
        if (g.carry == i) continue;
        const ArtDef *a = &artdef[e->type];
        int ex = e->x / 16 - a->ox, ey = e->y / 16 - a->oy;
        if (ex - camx > 320 || ex - camx + a->w < 0 || ey - camy > 240 || ey - camy + a->h < 0) continue;
        if(enemy_status_value(e,0))draw_flattened(e,a,ex,ey);
        else sprite_at(e->type, e->fr, e->face, ex, ey);
        if (e->freeze) { gfx_SetColor(cCyan); gfx_Rectangle(ex - camx, ey - camy + 22, a->w, a->h); }
        if (e->type == 42 || e->type == 40) { /* barrier orbs and the master need no extra overlay */ }
    }
    DRAW_PHASE(2);
    if (g.carry >= 0 && g.carry < g.enemies) { const Enemy *e = &g.enemy[g.carry]; const ArtDef *a = &artdef[e->type]; sprite_at(e->type, e->fr, e->face, g.px / 16 - a->w / 2 + 4, g.py / 16 - a->h + 2); }
    for (int i = 0; i < MAX_SHOTS; i++) if (g.shot[i].active) shot_sprite(&g.shot[i]);
    if (intro_is_active())intro_draw(camx,camy-22);
    else if (g.mode != DEFEAT && (!g.invul || (g.ticks & 2)) && g.action != PA_DIE) sprite_at(0, pedro_frame(), g.face, g.px / 16 - 6, g.py / 16 - 3);
    for(int y=y0,sy=y0*16-camy+22;y<y1;y++,sy+=16){const uint8_t*d=decor+y*width;for(int x=x0,sx=x0*16-camx;x<x1;x++,sx+=16){int t=d[x];if(t)tile(t,sx,sy);}}
    DRAW_PHASE(3);
    gfx_SetColor(cBlack); gfx_FillRectangle(0, 0, 320, 22);
    draw_hud();
    DRAW_PHASE(4);
    if (g.mode == DIALOGUE) story_draw();
    cached->x=camx;cached->y=camy;cached->level=g.level;cached->tick=g.ticks;
    cached->had_notice=g.notice_timer&&g.notice;
    cached->valid=g.mode==PLAY&&!intro_is_active();drawing_scene=NULL;
}

volatile uint16_t scene_diag[5]; /* done,frames,pixel failures,guard failures,first failed frame */
static char changing_notice[96];
static void fixture(int stage,int k){
 g.px=((int)g.w*16-1)*(k%6)/5*16;g.py=((int)g.h*16-1)*((k*3)%7)/6*16;
 g.mode=k%7==6?DIALOGUE:PLAY;g.story_event=k%12;g.story_page=0;
 g.ticks=30+k*7;g.face=k&1?-1:1;g.action=k%19;g.actiontime=k%30;g.invul=k%3==0?4:0;
 g.hp=(k%6==0?50:100+(k*137)%1900);g.fury=(k*37)%501;g.totalmail=k%2?26:4;g.mailleft=k%5;
 memset(progress.hearts,k%2,sizeof progress.hearts);memset(progress.souls,k%2,sizeof progress.souls);
 progress.rank=k*7;progress.points=k%3?0:25;progress.xp=k*7;
 g.arena=k%4==0?0:-1;g.arenaround=k%5;g.arenatime=300-k*31;
 snprintf(changing_notice,sizeof changing_notice,"Same pointer, changed text %d, stage %d",k/2,stage);
 g.notice=changing_notice;g.notice_timer=k%5==0?0:100;
 g.carry=-1;g.enemies=4;g.props=3;
 const uint8_t types[4]={2,39,40,46};
 for(int i=0;i<4;i++)g.enemy[i]=(Enemy){.x=g.px+(i*35-55)*16,.y=g.py,.hp=700-k*19,.maxhp=1000,.active=1,.type=types[i],.face=k&1?-1:1,.fr=k%4,.freeze=k%4==1?10:0,.stun=k%4==2?10:0};
 const uint8_t props[3]={23,15,32};
 for(int i=0;i<3;i++)g.prop[i]=(Prop){.x=g.px/16+i*35,.y=g.py/16+25,.type=props[i],.active=1,.face=1};
 memset(g.shot,0,sizeof g.shot);g.shot[0]=(Shot){.x=g.px+50*16,.y=g.py,.type=56,.frame=k%6,.active=1,.face=1};
}
int main(void){
 gfx_Begin();gfx_SetDrawBuffer();gfx_SetTransparentColor(0);gfx_SetTextTransparentColor(0);gfx_SetTextBGColor(0);
 for(int i=0;i<2;i++){memset(notice_guard[i].before,0xa5,64);memset(notice_guard[i].after,0xa5,64);}
 memset(scene_guard.before,0xa5,64);memset(scene_guard.after,0xa5,64);
 if(!load_resources()){scene_diag[0]=2;while(1){}}
 cache_hud();pick_colors();
 for(int surface=0;surface<2;surface++)for(int stage=1;stage<=15;stage++){
  char name[9];snprintf(name,sizeof name,"PDLV%02d",stage);unsigned size;const uint8_t*p=bundle_find(name,&size);
  memset(&g,0,sizeof g);g.w=p[0]+256*p[1];g.h=p[2]+256*p[3];g.n=g.w*g.h;
  memcpy(g.mapdata,p+4+g.n,g.n);memcpy(g.mapdata+g.n,p+4+3*g.n,g.n);
  g.back=p+4;g.solid=g.mapdata;g.decor=p+4+2*g.n;g.good=g.mapdata+g.n;g.level=stage-1;
  cache_stage_tiles(g.back,g.solid,g.decor,g.n);
  for(int k=0;k<12;k++){
   fixture(stage,k);
   if(surface)gfx_SetDrawBuffer();else gfx_SetDrawScreen();
   gfx_FillScreen(17);ref_draw_game();
   if(surface)gfx_SetDrawScreen();else gfx_SetDrawBuffer();
   draw_game();
   if(memcmp(gfx_vram,gfx_vram+76800,76800)){scene_diag[2]++;if(!scene_diag[4])scene_diag[4]=scene_diag[1]+1;}
   for(int i=0;i<2;i++)for(int j=0;j<64;j++)if(notice_guard[i].before[j]!=0xa5||notice_guard[i].after[j]!=0xa5)scene_diag[3]++;
   scene_diag[1]++;
  }
  if(stage==1||stage==8||stage==15)for(int j=0;j<40;j++){
   fixture(stage,j%12);g.px=g.w*8*16;g.py=g.h*8*16;g.mode=PLAY;g.ticks=100+j;
   int at=(g.py/16/16)*g.w+g.px/16/16;
   if(j==24)g.solid[at]=g.solid[at]?0:1;
   if(j==25)g.good[at]=12;if(j==28)g.good[at]=0;
   if(j==35){memset(changing_notice,'W',90);changing_notice[90]=0;g.notice_timer=100;}
   if(j==30||j==31){g.enemies=MAX_ENEMIES;for(int i=0;i<MAX_ENEMIES;i++)g.enemy[i]=(Enemy){.active=1,.type=2,.x=(camx+14+(i%12)*26)*16,.y=(camy+10+(i/12)*24)*16,.hp=100,.maxhp=100,.face=1};}
   if(j==32||j==33){g.props=j==32?25:24;for(int i=0;i<g.props;i++)g.prop[i]=(Prop){.x=camx+20+(i%5)*55,.y=camy+40+(i/5)*28,.type=23,.active=1,.face=1};}
   if(surface)gfx_SetDrawBuffer();else gfx_SetDrawScreen();
   gfx_FillScreen(17);ref_draw_game();
   if(surface)gfx_SetDrawScreen();else gfx_SetDrawBuffer();
   draw_game();
   if(memcmp(gfx_vram,gfx_vram+76800,76800)){scene_diag[2]++;if(!scene_diag[4])scene_diag[4]=scene_diag[1]+1;}
   for(int i=0;i<2;i++)for(int z=0;z<64;z++)if(notice_guard[i].before[z]!=0xa5||notice_guard[i].after[z]!=0xa5)scene_diag[3]++;
   for(int z=0;z<64;z++)if(scene_guard.before[z]!=0xa5||scene_guard.after[z]!=0xa5)scene_diag[3]++;
   scene_diag[1]++;
  }
 }
 gfx_SwapDraw();gfx_Wait();scene_diag[0]=1;while(1){kb_Scan();}
}
