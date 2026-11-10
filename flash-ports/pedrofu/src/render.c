/* World, actor and HUD drawing for Pedro Kicks Back CE. */
#include "game.h"
#include "sky_rows.h"
#include "sky_runtime.h"
#include "intro.h"
#include "render_cache.h"
#if defined(PEDRO_PROFILE)||defined(PEDRO_PATHSTAT)
volatile uint8_t pedro_last_path; /* 0 reuse, 1 tracked and skipped sky, 2 tracked, 3 untracked */
#define PATH(v) (pedro_last_path=(v))
#else
#define PATH(v)
#endif
#ifdef PEDRO_PROFILE
#include <sys/timers.h>
volatile uint32_t pedro_draw_profile[6],pedro_phase_sum[6],pedro_hud_sum[9];
/* Phase sums cover scrolling (non-reuse) frames only; pedro_phase_sum[5] counts them. */
#define DRAW_START uint32_t phase_time=timer_GetSafe(1,TIMER_UP)
#define DRAW_PHASE(i) do { uint32_t n=timer_GetSafe(1,TIMER_UP);pedro_draw_profile[i]=n-phase_time;if(pedro_last_path){pedro_phase_sum[i]+=n-phase_time;if(!(i))pedro_phase_sum[5]++;}phase_time=n; }while(0)
#define HUD_START uint32_t hud_time=timer_GetSafe(1,TIMER_UP)
#define HUD_PHASE(i) do { uint32_t n=timer_GetSafe(1,TIMER_UP);if(pedro_last_path)pedro_hud_sum[i]+=n-hud_time;hud_time=n; }while(0)
#else
#define DRAW_START
#define DRAW_PHASE(i)
#define HUD_START
#define HUD_PHASE(i)
#endif

uint8_t cBlack, cWhite = 255, cYellow = 254, cGold = 252, cRed, cGreen, cCyan, cPanel;
static int camx, camy;
extern const uint8_t *pedro_flame;
int enemy_status_value(const Enemy *e,int which);
static uint8_t flat_sprite[2+64*8];
/* The panel is opaque; two 150-pixel sprites retain every original panel/text pixel.
 * Zero-initialised, so it sits in the OS scratch RAM that BSS uses rather than in the resident
 * program image, where its 4.2 KB would come out of the free RAM the sky AppVar needs. */
static uint8_t notice_images[2][2+150*14];
static char notice_text[96];
static uint8_t notice_colors[3];
static bool notice_valid;
typedef struct {int x0,y0,x1,y1;} Damage;
typedef struct {int x,y;uint8_t type;int8_t face;} SceneryStamp;
#define DAMAGE_RECTS 24
typedef struct {
    Damage rect[DAMAGE_RECTS];uint8_t solid[21*16],count;
    SceneryStamp scenery[24];uint8_t scenery_count;
    int x,y,level;int hud_sig[8];uint32_t tick;bool valid,overflow,had_notice,hud_ok;
} SceneCache;
static SceneCache scene_cache[2];
volatile uint32_t pedro_render_stats[4]; /* full redraws, reused backgrounds, overflow fallbacks, full redraws that skipped clean sky rows */
static SceneCache *drawing_scene;
/* The sky is fixed to the screen. After a tracked frame, every pixel of that buffer above row top_old
 * is sky apart from the frame's own damage rects, so the next scrolling frame in the same buffer only
 * repaints from the higher of the old and new tile/scenery tops, plus any old rects above that.
 * content_top is this frame's highest tile or scenery row. */
static int top_old[2]={22,22},content_top;
void invalidate_scene_cache(void){scene_cache[0].valid=scene_cache[1].valid=scene_cache[0].hud_ok=scene_cache[1].hud_ok=false;top_old[0]=top_old[1]=22;}
static void damage(int x,int y,int w,int h){
    if(!drawing_scene)return;
    Damage r={x-2,y-2,x+w+2,y+h+2};
    if(r.x0<0)r.x0=0;if(r.y0<22)r.y0=22;if(r.x1>320)r.x1=320;if(r.y1>240)r.y1=240;
    if(r.x0>=r.x1||r.y0>=r.y1)return;
    SceneCache *sc=drawing_scene;
    Damage *d=sc->rect,*end=d+sc->count; /* walk by pointer: indexing 12-byte rects costs a multiply each */
    while(d<end){
        if(r.x0<d->x1&&r.x1>d->x0&&r.y0<d->y1&&r.y1>d->y0){
            if(d->x0<r.x0)r.x0=d->x0;if(d->y0<r.y0)r.y0=d->y0;
            if(d->x1>r.x1)r.x1=d->x1;if(d->y1>r.y1)r.y1=d->y1;
            *d=*--end;sc->count--;d=sc->rect;
        }else d++;
    }
    if(sc->count==DAMAGE_RECTS){sc->overflow=true;return;}
    *end=r;sc->count++;
}

static void draw_notice(void) {
    if(!notice_valid||strncmp(notice_text,g.notice,sizeof notice_text)||
       notice_colors[0]!=cPanel||notice_colors[1]!=cWhite||notice_colors[2]!=cYellow){
        gfx_SetColor(cPanel);gfx_FillRectangle(10,206,300,14);
        gfx_SetColor(cWhite);gfx_Rectangle(10,206,300,14);
        gfx_SetTextFGColor(cYellow);center_text(209,g.notice);
        if(gfx_GetStringWidth(g.notice)>296){notice_valid=false;damage(0,206,320,14);return;}
        for(unsigned i=0;i<2;i++){
            gfx_sprite_t *s=(gfx_sprite_t *)notice_images[i];s->width=150;s->height=14;
            gfx_GetSprite(s,10+i*150,206);
        }
        strncpy(notice_text,g.notice,sizeof notice_text-1);notice_text[sizeof notice_text-1]=0;
        notice_colors[0]=cPanel;notice_colors[1]=cWhite;notice_colors[2]=cYellow;notice_valid=true;
    }else{
        gfx_Sprite_NoClip((gfx_sprite_t *)notice_images[0],10,206);
        gfx_Sprite_NoClip((gfx_sprite_t *)notice_images[1],160,206);
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
        if(offset==65535){
            if(width==320){ /* consecutive rows of one flat colour are one contiguous block */
                unsigned run=1;uint8_t color=sky_row_colors[y];
                while(y+run<(unsigned)bottom&&sky_row_offsets[y+run]==65535&&sky_row_colors[y+run]==color)run++;
                memset(dest,color,run*320);y+=run-1;dest+=(run-1)*320;
            }else memset(dest,sky_row_colors[y],width);
        }
#ifdef SKY_FLASH_ROWS
        else if(sky_ram_pixels)memcpy(dest,sky_ram_pixels+offset+left,width);
        /* Original sky halves PDU20/PDU21 (160x240 each) read in place from archive. */
        else{
            if(left<160){unsigned end=right<160?right:160;memcpy(dest,uidata[2][0]+2+y*160+left,end-left);}
            if(right>160){unsigned start=left>160?left:160;memcpy(dest+(start-left),uidata[2][1]+2+y*160+(start-160),right-start);}
        }
#else
        else memcpy(dest,sky_row_pixels+offset+left,width);
#endif
    }
}
static void draw_sky(int bottom){draw_sky_region(0,22,320,bottom);}
/* Index of the first non-zero byte of p[0..n), or n. The per-cell loops below cost about 200 cycles a
 * cell when the compiler keeps their state on the stack, and most cells of a scene are empty, so
 * empty runs are skipped three bytes at a time. */
static unsigned skip_zero(const uint8_t *p,unsigned n){
    unsigned i=0;
    while(i+3<=n&&!*(const unsigned *)(p+i))i+=3;
    while(i<n&&!p[i])i++;
    return i;
}
static unsigned skip_zero2(const uint8_t *p,const uint8_t *q,unsigned n){
    unsigned i=0;
    while(i+3<=n&&!(*(const unsigned *)(p+i)|*(const unsigned *)(q+i)))i+=3;
    while(i<n&&!(p[i]|q[i]))i++;
    return i;
}
/* Any non-empty cell in a row of n? Reads three bytes at a time, so it may look up to two cells past
 * the span; that only makes the answer more conservative. */
static bool row_any(const uint8_t *p,unsigned n){
    for(const uint8_t *e=p+n;p<e;p+=3)if(*(const unsigned *)p)return true;
    return false;
}

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
    if((id>=18&&id<=25)||(id>=30&&id<=34)){
        if(y-camy+22<content_top&&x-camx<320&&x-camx+a->w>0&&y-camy+22+a->h>22)content_top=y-camy+22<22?22:y-camy+22;
        draw_sprite(id,frame,p->face,x-camx,y-camy+22);
    }
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
static void draw_hud_impl(bool force_full) {
    /* Rows 0-21 hold only the black bar and HUD sprites. When nothing drawn there changed since
     * the previous frame (the other buffer), copy that strip instead of repainting it. */
    HUD_START;
    SceneCache *sc=drawing_scene,*oc=sc==scene_cache?&scene_cache[1]:&scene_cache[0];
    int hearts = maxlife() / 100, blink = (g.ticks / 6) & 1, boss = -1, bossw = 0;
    const Enemy *e = g.enemy;
    for (int i = 0; i < g.enemies; i++, e++) {
        if (e->active && (e->type == 39 || e->type == 40 || e->type == 46) && absi(e->x - g.px) < 320 * 16) {
            bossw = 59 * clampi(e->hp, 0, e->maxhp) / (e->maxhp ? e->maxhp : 1); boss = i;
            break;
        }
    }
    int fmax = maxfury(), sig[8] = {g.hp, hearts, g.totalmail, g.mailleft, g.fury, fmax, (g.hp <= 100 || g.fury >= fmax) ? blink : 0, boss < 0 ? -1 : bossw};
    /* The scene is clipped below row 21, so a strip drawn into this buffer earlier is still intact
     * when its signature matches: nothing to copy or redraw except the mail icons spilling below it. */
    bool own = !force_full && sc->hud_ok && !memcmp(sig, sc->hud_sig, sizeof sig);
    bool keep = own || (!force_full && oc->hud_ok && !memcmp(sig, oc->hud_sig, sizeof sig));
    memcpy(sc->hud_sig, sig, sizeof sig); sc->hud_ok = g.mode == PLAY && !intro_is_active();
    gfx_SetClipRegion(0, 0, 320, 240);
    if (own);
    else if (keep) memcpy(gfx_vbuffer, (uint8_t *)gfx_vbuffer == gfx_vram ? gfx_vram + 320 * 240 : gfx_vram, 320 * 22);
    else { gfx_SetColor(cBlack); gfx_FillRectangle(0, 0, 320, 22); }
    HUD_PHASE(0);
    damage(217,228,100,10);
    if(progress.points)damage(4,228,96,10);
    int mail_y=3+((hearts+9)/10)*10+2;
    if(g.totalmail&&mail_y+11>22)damage(3,mail_y,(g.totalmail<26?g.totalmail:26)*12-1,11);
    for (int i = keep ? 20 : 0; i < hearts; i++) {
        int frame = g.hp >= i * 100 + 50 ? 1 : 0;
        if (frame && g.hp <= 100 && blink) frame = 2;
        draw_ui(UI_HEART, frame, 3 + (i % 10) * 10, 3 + (i / 10) * 10);
    }
    if (keep) gfx_SetClipRegion(0, 22, 320, 240); /* rows 0-21 of the icons are already in the strip */
    for (int i = 0; i < g.totalmail && i < 26; i++) draw_ui(UI_MAIL, i >= g.mailleft ? 1 : 0, 3 + i * 12, 3 + ((hearts + 9) / 10) * 10 + 2);
    gfx_SetClipRegion(0, 0, 320, 240);
    HUD_PHASE(1);
    int boxes = fmax / 100, whole = g.fury / 100, part = g.fury % 100;
    if (!keep) {
        draw_ui(UI_FURY, 0, 255, 2);
        if (part) clipped_ui(UI_FURYI, 0, 256, 3, 256 + 61 - 61 * part / 100, 256 + 61);
        for (int i = 0; i < boxes; i++) draw_ui(UI_FBOX, i < whole ? 1 + (g.fury >= fmax && blink) : 0, 256 + i * 8, 13);
        if (boss >= 0) {
            draw_ui(UI_BADG, 0, 128, 3);
            if (bossw) clipped_ui(UI_BADGI, 0, 130, 5, 130, 130 + bossw);
        }
    }
    HUD_PHASE(2);
    int need = progress.rank * 10 + 50;
    draw_ui(UI_XP, 0, 247, 229);
    if (progress.xp) clipped_ui(UI_XP, 1, 247, 229, 247, 247 + 68 * progress.xp / need);
    HUD_PHASE(3);
    static char lv_text[12], pts_text[16]; static int lv_rank = -1, pts_value = -1;
    char text[24];
    if (lv_rank != progress.rank) { lv_rank = progress.rank; snprintf(lv_text, sizeof lv_text, "Lv %d", lv_rank + 1); }
    HUD_PHASE(4);
    gfx_SetTextFGColor(cWhite); gfx_PrintStringXY(lv_text, 217, 228);
    HUD_PHASE(5);
    if (progress.points) {
        if (pts_value != progress.points) { pts_value = progress.points; snprintf(pts_text, sizeof pts_text, "+%d pts", pts_value); }
        gfx_SetTextFGColor(cYellow); gfx_PrintStringXY(pts_text, 4, 228);
    }
    HUD_PHASE(6);
    if (g.arena >= 0 && g.arenaround < 5) {
        damage(0,25,320,10);
        snprintf(text, sizeof text, "Round %d/5  %ds", g.arenaround + 1, g.arenatime / 30);
        gfx_SetTextFGColor(g.arenatime > 0 ? cYellow : cRed); center_text(26, text);
    }
    HUD_PHASE(7);
    if (g.notice_timer && g.notice) {
        draw_notice();
    }
    HUD_PHASE(8);
}
#ifdef PEDRO_HUDCHECK
volatile uint32_t pedro_hud_check[3]; /* frames compared, mismatches, strips kept */
static uint32_t hud_sum(void){const uint8_t *p=gfx_vbuffer;uint32_t a=1,b=0;for(unsigned i=0;i<320*22;i++){a+=p[i]+1;b+=a;}return b^(a<<7);}
static void draw_hud(void){
    SceneCache *sc=drawing_scene,*oc=sc==scene_cache?&scene_cache[1]:&scene_cache[0];
    bool will_keep=oc->hud_ok;
    draw_hud_impl(false);
    uint32_t first=hud_sum();
    draw_hud_impl(true);
    pedro_hud_check[0]++;if(hud_sum()!=first)pedro_hud_check[1]++;if(will_keep)pedro_hud_check[2]++;
}
#else
static void draw_hud(void){draw_hud_impl(false);}
#endif
void draw_game(void) {
    DRAW_START;
    drawing_scene=NULL;
    gfx_SetClipRegion(0,22,320,240); /* keep scene draws out of the retained HUD strip; draw_hud restores it */
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
    const unsigned buf=(uint8_t *)gfx_vbuffer==gfx_vram?0:1;
    SceneCache *cached=buf?&scene_cache[1]:&scene_cache[0];
    const bool prior=cached->valid&&!cached->overflow; /* this buffer's last frame left usable old rects */
    bool reuse=cached->valid&&!cached->overflow&&cached->level==g.level&&cached->x==camx&&cached->y==camy&&g.ticks>=cached->tick&&g.mode==PLAY&&!intro_is_active();
    if(cached->overflow)pedro_render_stats[2]++;
    unsigned cell=0;
    {
        const unsigned span=x1-x0;const uint8_t *row=solid+y0*width+x0;
        for(int y=y0;y<y1;y++,row+=width,cell+=span)
            if(memcmp(cached->solid+cell,row,span)){reuse=false;memcpy(cached->solid+cell,row,span);}
    }
    unsigned scenery_count=0;
    const Prop*p=g.prop;
    for(int i=0;i<g.props;i++,p++){
        int id=p->type;
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
    bool track_frame=false;
    if(reuse){
        PATH(0);pedro_render_stats[1]++;for(const Damage *r=cached->rect,*end=r+cached->count;r<end;r++)restore_region(r);
        if(cached->had_notice&&(!g.notice_timer||!g.notice)){Damage r={10,206,310,220};restore_region(&r);}
    }
    else {
        pedro_render_stats[0]++;
        const bool track=track_frame=g.mode==PLAY&&!intro_is_active();
        int top=22;
        content_top=240;
        if(track){
            const unsigned span=x1-x0;const uint8_t *srow=solid+y0*width+x0,*brow=back+y0*width+x0,*drow=decor+y0*width+x0;
            for(int y=y0,sy=y0*16-camy+22;y<y1;y++,sy+=16,srow+=width,brow+=width,drow+=width)
                if(row_any(srow,span)||row_any(brow,span)||row_any(drow,span)){content_top=sy<22?22:sy;break;}
            if(prior){top=top_old[buf]<content_top?top_old[buf]:content_top;if(top>sky_bottom)top=sky_bottom;}
        }
        PATH(top>22?1:track?2:3);
        if(top>22)pedro_render_stats[3]++;
        if(top<sky_bottom)draw_sky_region(0,top,320,sky_bottom);
        if(prior&&track&&top>22){
            for(const Damage *r=cached->rect,*end=r+cached->count;r<end;r++)if(r->y0<top)draw_sky_region(r->x0,r->y0,r->x1,r->y1<top?r->y1:top);
            if(cached->had_notice&&206<top)draw_sky_region(10,206,310,220<top?220:top);
        }
    }
    DRAW_PHASE(0);
    const unsigned cells=x1>x0?x1-x0:0;
    if(!reuse)for(int y=y0,sy=y0*16-camy+22;y<y1;y++,sy+=16){
        const uint8_t *b=back+y*width+x0,*s=solid+y*width+x0;
        for(unsigned i=0;;i++){
            i+=skip_zero2(b+i,s+i,cells-i);if(i>=cells)break;
            const int t=b[i],u=s[i],sx=(x0+(int)i)*16-camx;
            if(t&&!(u&&opaque[u]))tile(t,sx,sy);if(u)tile(u,sx,sy);
        }
    }
    DRAW_PHASE(1);
    cached->count=0;cached->overflow=false;drawing_scene=cached;
    for (const Prop *q=g.prop,*qend=q+g.props; q<qend; q++) if (q->active) prop_sprite(q);
    {
        const int bob=(g.ticks / 6) & 1;
        const uint8_t *goodRow=good+y0*width+x0;
        for (int y = y0; y < y1; y++, goodRow += width) for (unsigned i = 0;; i++) {
            i += skip_zero(goodRow + i, cells - i);
            if (i >= cells) break;
            int t = goodRow[i];
            int which = t == 12 ? 5 : t == 6 ? 0 : (t >= 7 && t <= 9) ? t - 6 : t == 36 ? 4 : t == 37 ? 6 : -1;
            if (which >= 0) sprite_at(48, which, 1, (x0 + (int)i) * 16, y * 16 + bob);
        }
    }
    const Enemy *e = g.enemy;
    for (int i = 0; i < g.enemies; i++, e++) {
        if (!e->active || (e->type==35&&e->state==5)) continue;
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
    for(int y=y0,sy=y0*16-camy+22;y<y1;y++,sy+=16){
        const uint8_t *d=decor+y*width+x0;
        for(unsigned i=0;;i++){i+=skip_zero(d+i,cells-i);if(i>=cells)break;tile(d[i],(x0+(int)i)*16-camx,sy);}
    }
    DRAW_PHASE(3);
    draw_hud();
    DRAW_PHASE(4);
    if (g.mode == DIALOGUE) story_draw();
    cached->x=camx;cached->y=camy;cached->level=g.level;cached->tick=g.ticks;
    cached->had_notice=g.notice_timer&&g.notice;
    cached->valid=g.mode==PLAY&&!intro_is_active();drawing_scene=NULL;
    if(!reuse)top_old[buf]=track_frame?content_top:22; /* a reuse frame leaves tiles and scenery as they were */
}
