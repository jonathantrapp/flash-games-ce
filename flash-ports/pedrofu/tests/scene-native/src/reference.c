#define pick_colors ref_pick_colors
#define print_fit ref_print_fit
#define center_text ref_center_text
#define wrap_text ref_wrap_text
#define shot_sprite ref_shot_sprite
#define draw_game ref_draw_game
/* World, actor and HUD drawing for Pedro Kicks Back CE. */
#include "../../../src/game.h"
#include "../../../src/sky_cache.h"
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

extern uint8_t cBlack,cWhite,cYellow,cGold,cRed,cGreen,cCyan,cPanel;
static int camx, camy;
extern const uint8_t *pedro_flame;
int enemy_status_value(const Enemy *e,int which);
static uint8_t flat_sprite[2+64*8];

static void draw_flattened(const Enemy *e,const ArtDef *a,int x,int y) {
    unsigned h=(a->h+9)/10;
    if(a->w>64||h>8||!artdata[e->type]){draw_sprite(e->type,0,e->face,x-camx,y-camy+22);return;}
    flat_sprite[0]=a->w;flat_sprite[1]=h;
    const uint8_t *p=artdata[e->type]+(e->face<0?a->frames:0)*a->stride+2;
    for(unsigned row=0;row<h;row++)memcpy(flat_sprite+2+row*a->w,p+(row*a->h/h)*a->w,a->w);
    gfx_TransparentSprite((gfx_sprite_t *)flat_sprite,x-camx,y-camy+22+a->h-h);
}

static void draw_sky(void) {
    for (unsigned i=0;i<COUNT(cached_sky_rows);i++) {
        gfx_SetColor(cached_sky_rows[i][0]);
        gfx_FillRectangle_NoClip(0,cached_sky_rows[i][1],320,cached_sky_rows[i][2]);
    }
    gfx_RLETSprite_NoClip((gfx_rletsprite_t *)cached_sky_overlay0,0,0);
    gfx_RLETSprite_NoClip((gfx_rletsprite_t *)cached_sky_overlay1,160,0);
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
static void sprite_at(int id, int frame, int face, int x, int y) { draw_sprite(id, frame, face, x - camx, y - camy + 22); }
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
    sprite_at(id, frame, p->face, x, y);
}
void shot_sprite(const Shot *s) {
    int x = s->x / 16, y = s->y / 16;
    if(s->type==60){if(pedro_flame)cached_sprite(pedro_flame+clampi(s->frame,0,12)*722,x-10-camx,y-18-camy+22);return;}
    if(s->type>=60)return;
    if (s->type == 51) { gfx_SetColor(cYellow); gfx_FillCircle(x - camx, y - camy + 22, 3); return; }
    const ArtDef *a = &artdef[s->type];
    if (!a->frames) return;
    sprite_at(s->type, s->frame, s->face, x - a->w / 2, y - a->h / 2);
}
static void clipped_ui(int id, int frame, int x, int y, int clip_x0, int clip_x1) {
    gfx_SetClipRegion(clip_x0, 0, clip_x1, 240); draw_ui(id, frame, x, y); gfx_SetClipRegion(0, 0, 320, 240);
}
static void draw_hud(void) {
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
        snprintf(text, sizeof text, "Round %d/5  %ds", g.arenaround + 1, g.arenatime / 30);
        gfx_SetTextFGColor(g.arenatime > 0 ? cYellow : cRed); center_text(26, text);
    }
    if (g.notice_timer && g.notice) {
        gfx_SetColor(cPanel); gfx_FillRectangle(10, 206, 300, 14); gfx_SetColor(cWhite); gfx_Rectangle(10, 206, 300, 14);
        gfx_SetTextFGColor(cYellow); center_text(209, g.notice);
    }
}
void draw_game(void) {
    DRAW_START;
    int tx = g.px / 16 + 4 - 160, ty = g.py / 16 + 8 - 120;
    if (g.ticks <= 1) { camx = tx; camy = ty; }
    camx += (clampi(tx, 0, (int)g.w * 16 - 320) - camx) / 3; camy += (clampi(ty, 0, (int)g.h * 16 - 218) - camy) / 3;
    camx = clampi(camx, 0, (int)g.w * 16 - 320 < 0 ? 0 : (int)g.w * 16 - 320); camy = clampi(camy, 0, (int)g.h * 16 - 218 < 0 ? 0 : (int)g.h * 16 - 218);
    if(intro_is_active())intro_camera(&camx,&camy);
    draw_sky();
    DRAW_PHASE(0);
    int x0 = camx / 16, y0 = camy / 16, x1 = (camx + 320) / 16 + 1, y1 = (camy + 218) / 16 + 1;
    if (x1 > (int)g.w) x1 = g.w; if (y1 > (int)g.h) y1 = g.h;
    /* Keep immutable loop data local: drawing calls cannot force a reload and
     * software multiply of g.w for every single visible tile. */
    const unsigned width=g.w;
    const uint8_t *back=g.back,*solid=g.solid,*decor=g.decor,*good=g.good;
    for(int y=y0,sy=y0*16-camy+22;y<y1;y++,sy+=16){
        const uint8_t *b=back+y*width,*s=solid+y*width;
        for(int x=x0,sx=x0*16-camx;x<x1;x++,sx+=16){int t=b[x];if(t)tile(t,sx,sy);t=s[x];if(t)tile(t,sx,sy);}
    }
    DRAW_PHASE(1);
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
}
