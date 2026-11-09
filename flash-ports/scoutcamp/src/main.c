/* Scouts vs Aliens CE: keypad front end for the rules engine in engine.h/combat.h. */
#include <tice.h>
#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>
#include <sys/timers.h>
#include <sys/power.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "art.h"
#include "input.h"
#include "engine.h"
#include "combat.h"
#include "tips.h"
#include "menu_data.h"
#include "skill_text_index.h"

enum { MODE_MENU = 0, MODE_PLAY = 1, MODE_MAP = 2, MODE_LOST = 3, MODE_WON = 4, MODE_HELP = 5, MODE_SKILLS = 6, MODE_OPTIONS = 7, MODE_ENDING = 8 };
#define STEP_TICKS (32768 / HZ)
#define FRAME_MIN_TICKS 1092 /* 32768 Hz timer ticks per frame at most 30 FPS */
#define KEY_DOWN(k) (input_held[(k) >> 8] & ((k) & 0xFF))
#define KEY_PRESS(k) (input_pressed[(k) >> 8] & ((k) & 0xFF))

volatile uint32_t scout_totals[2]; /* rendered frames, simulation ticks; no overlay */
#ifdef QA_DAMAGECHECK
volatile uint32_t scout_damage[2]; /* frames compared, frames whose retained pixels differed from a full redraw */
static uint32_t frameHash(void) { /* Adler-style position-sensitive sums over the whole draw buffer */
    /* gfx_vbuffer is the visible screen; the draw buffer is the other VRAM half. */
    const uint8_t *p = (const uint8_t *)gfx_vbuffer == gfx_vram ? gfx_vram + 320 * 240 : gfx_vram;
    unsigned a = 1, b = 0;
    for (unsigned i = 0; i < 320u * 240u; i++) { a += p[i]; b += a; }
    return (uint32_t)b << 8 ^ a;
}
#endif

#ifdef QA_PERF
volatile uint16_t scout_perf[4],scout_render_ms[5];
static uint32_t renderStamp;
static void renderMark(int id){uint32_t n=timer_GetSafe(1,TIMER_UP);scout_render_ms[id]=(n-renderStamp)*1000/32768;renderStamp=n;}
#endif
static bool showTip;
static bool skillDetails;
static uint8_t titleChoice,optionChoice,resetStage,soundVolume=100,musicVolume=100;
static uint8_t skillReturn=MODE_MAP,helpReturn=MODE_MAP;
static uint32_t menuTicks;
static uint32_t mapEntered;
static uint8_t previousDrawMode=255;
typedef struct {int x,y,vy;uint8_t frame;} EndingFood;
static EndingFood endingFood[20];
static bool endingReady;
static uint8_t cBlack, cWhite, cYellow, cRed, cGreen, cCyan, cPanel;
static uint8_t flipBuffer[64 * 56 + 2], scaleBuffer[64 * 56 + 2];

typedef struct { const uint8_t *walk; uint8_t walkLength, jump; const uint8_t *disabled; uint8_t disabledLength, disabledJump; } Anim;
static const uint8_t seqLumpy[] = {0, 1, 2, 3, 0, 4, 5, 6}, seqFour[] = {0, 1, 2, 3}, seqBeefy[] = {0, 1, 2, 3, 4, 5, 6};
static const uint8_t seqBeasty[] = {1, 2, 3, 4, 5, 6}, seqWormy[] = {4, 5}, seqWormyOff[] = {0, 1, 2, 1};
static const uint8_t seqSpeedyOff[] = {5, 6, 7, 8}, seqScaryOff[] = {4, 5, 6, 7}, seqBlinkyOff[] = {8, 9, 10, 11};
static const uint8_t seqBlinky[] = {0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4};
static const uint8_t seqBaby[] = {0, 1, 2, 1}, seqZero[] = {0};
static const Anim anims[10] = {
    {seqLumpy, 8, 7, seqLumpy, 8, 7},   {seqFour, 4, 4, seqFour, 4, 4},       {seqBeefy, 7, 7, seqBeefy, 7, 7},
    {seqBeasty, 6, 7, seqBeasty, 6, 7}, {seqWormy, 2, 3, seqWormyOff, 4, 3},  {seqFour, 4, 4, seqSpeedyOff, 4, 9},
    {seqBlinky, 23, 0, seqBlinkyOff, 4, 8}, {seqFour, 4, 0, seqScaryOff, 4, 5}, {seqZero, 1, 0, seqZero, 1, 0},
    {seqBaby, 4, 3, seqBaby, 4, 3}};
static const uint8_t monsterArt[10] = {ART_LUMPY, ART_SQUIRMY, ART_BEEFY, ART_BEASTY, ART_WORMY, ART_SPEEDY, ART_BLINKY, ART_SCARY, ART_HUNGRY, ART_HUNGRYBABY};
static const uint8_t towerArt[12] = {ART_TOWER_ROCK, ART_TOWER_ROLL, ART_TOWER_SNOW, ART_TOWER_SHOCK, ART_TOWER_SLING, ART_TOWER_SOAPBOX,
                                      ART_TOWER_CRUSHER, ART_TOWER_QUAKE, ART_TOWER_ICE, ART_TOWER_SLUSHEE, ART_TOWER_CRIPPLER, ART_TOWER_LIGHTNINGROD};
static const uint8_t bulletArt[12] = {ART_BULLET_ROCK, ART_BULLET_BOULDER, ART_BULLET_SNOWBALL, ART_BULLET_ROCK, ART_BULLET_SLINGBULLET, ART_BULLET_ROCK,
                                       ART_BULLET_BOULDER, ART_BULLET_ROCK, ART_BULLET_ICEBULLET, ART_BULLET_SLUSHBALL, ART_BULLET_ROCK, ART_BULLET_ROCK};

static uint8_t nearestColor(int r, int g, int b) {
    int best = 1, bestDistance = 0x7fffff;
    for (int i = 1; i < 256; i++) {
        int p = artPalette[i], pr = ((p >> 10) & 31) * 255 / 31, pg = ((p >> 5) & 31) * 255 / 31, pb = (p & 31) * 255 / 31;
        int d = (pr - r) * (pr - r) + (pg - g) * (pg - g) + (pb - b) * (pb - b);
        if (d < bestDistance) { bestDistance = d; best = i; }
    }
    return (uint8_t)best;
}
static void pickColors(void) {
    cBlack = nearestColor(0, 0, 0); cWhite = nearestColor(255, 255, 255); cYellow = nearestColor(255, 230, 40);
    cRed = nearestColor(230, 30, 30); cGreen = nearestColor(40, 200, 60); cCyan = nearestColor(90, 220, 255); cPanel = nearestColor(24, 24, 48);
}
/* ---------- retained stage background ----------
 * Each of the two framebuffers keeps the stage background (sky + three tile layers).
 * Everything drawn over it during play records its rectangle; the next time that
 * buffer is drawn (two frames later) the sky is repainted exactly inside each recorded
 * rectangle, then every 16x16 map cell those rectangles touch gets its tile layers
 * redrawn once, from its topmost opaque tile. A camera move, a different stage or any
 * other screen forces the original full redraw. Rows y>=217 belong to the HUD panel,
 * which is repainted whenever anything (a sprite or a redrawn cell) reached it.
 * QA_DAMAGECHECK compares each retained frame with a full redraw. */
#define DIRTY_MAX 120 /* overflow falls back to the full redraw */
#define PANEL_TOP 217
#define GRID_W 21 /* screen columns of cells, for any camera offset */
#define GRID_H 15 /* cell rows that can reach above PANEL_TOP */
typedef struct { uint16_t x0, x1; uint8_t y0, y1; } Rect;
/* BSS is nearly full: the initializers place these tables in linker-guarded resident data. */
static Rect dirty[2][DIRTY_MAX] = {{{1, 1, 1, 1}}};
static uint8_t cellsToDraw[GRID_H][GRID_W] = {{1}};
static uint8_t dirtyCount[2], drawIndex;
static bool dirtyOverflow[2], tracking;
static uint32_t heldBackground[2] = {0xffffffff, 0xffffffff};
/* Retained HUD: each item remembers, per buffer, exactly what it last drew (text,
 * colour/value and rectangle). It is redrawn only when that changes (its old rectangle
 * is repaired first), when a repair or a sprite touched it, or when an item drawn
 * before it was redrawn over it. HUD items are not in the dirty list. */
enum { HUD_FRAME, HUD_MONEY, HUD_SLIDER, HUD_WAVE, HUD_TIMER, HUD_FOOD, HUD_LEVEL, HUD_PANEL, HUD_N };
#define HUD_KEY 24        /* longest one-line HUD text is "LV 99" / "$99999" / "W24/24" */
#define HUD_PANEL_KEY 128 /* the two panel lines, joined by a newline */
typedef struct { int16_t x0, y0, x1, y1; uint16_t extra; char key[HUD_KEY]; } HudItem;
static HudItem hudNow[HUD_N] = {{1, 1, 1, 1, 0, {0}}}, hudHeld[2][HUD_N] = {{{1, 1, 1, 1, 0, {0}}}}; /* resident data, not BSS */
static char panelNow[HUD_PANEL_KEY] = {1}, panelHeld[2][HUD_PANEL_KEY] = {{1}};
static bool hudNeed[HUD_N], panelTouched[2] = {true, true};
static int hudBottom = 240; /* lowest row any non-panel HUD item (now or held) reaches */
static bool overlaps(int x0, int y0, int x1, int y1, const HudItem *h) {
    return x0 < h->x1 && h->x0 < x1 && y0 < h->y1 && h->y0 < y1;
}
static void hudTouch(int x0, int y0, int x1, int y1) {
    if (y0 >= hudBottom) return; /* the panel item lies below PANEL_TOP, which marks never reach */
    for (int i = 0; i < HUD_N; i++)
        if (overlaps(x0, y0, x1, y1, &hudHeld[drawIndex][i]) || overlaps(x0, y0, x1, y1, &hudNow[i])) hudNeed[i] = true;
}
/* Record screen rectangle [x0,x1)x[y0,y1) (already clipped) for repair. */
static void pushRect(int x0, int y0, int x1, int y1) {
    uint8_t n = dirtyCount[drawIndex];
    if (n >= DIRTY_MAX) { dirtyOverflow[drawIndex] = true; return; }
    dirty[drawIndex][n] = (Rect){x0, x1, y0, y1}; dirtyCount[drawIndex] = n + 1;
}
static void mark(int x, int y, int w, int h) {
    if (!tracking) return;
    int x1 = x + w, y1 = y + h;
    if (y1 > PANEL_TOP && y < 240 && x < 320 && x1 > 0) panelTouched[drawIndex] = true;
    if (x < 0) x = 0;
    if (y < 0) y = 0;
    if (x1 > 320) x1 = 320;
    if (y1 > PANEL_TOP) y1 = PANEL_TOP;
    if (x >= x1 || y >= y1) return;
    hudTouch(x, y, x1, y1);
    pushRect(x, y, x1, y1);
}
static void artDraw(int id, int frame, int x, int y) {
    const Art *art = &artTable[id]; mark(x, y, art->width, art->height); art_draw(id, frame, x, y);
}
/* GraphX does not clip text at the right edge (it wraps into the next scanline), so truncate to fit. */
static void printFit(const char *s, int x, int y) {
    if (y < 0 || y > 232 || x > 315) return;
    if (x < 0) x = 0;
    if (tracking) { int w = gfx_GetStringWidth(s); mark(x, y, w < 316 - x ? w : 316 - x, 8); }
    if (x + (int)gfx_GetStringWidth(s) <= 316) { gfx_PrintStringXY(s, x, y); return; }
    char buffer[96]; int n = 0;
    while (s[n] && n < 90) { buffer[n] = s[n]; buffer[n + 1] = 0; if (x + (int)gfx_GetStringWidth(buffer) > 316) { buffer[n] = 0; break; } n++; }
    gfx_PrintStringXY(buffer, x, y);
}
static void label(const char *s, int x, int y, int color) { gfx_SetTextFGColor(color); printFit(s, x, y); }
static void shadowLabel(const char *s, int x, int y, int color) { label(s, x + 1, y + 1, cBlack); label(s, x, y, color); }
static void centered(const char *s, int y, int color) { int w=gfx_GetStringWidth(s);shadowLabel(s,w>=316?2:(320-w)/2,y,color); }
static void panel(int x, int y, int w, int h) { mark(x, y, w, h); gfx_SetColor(cPanel); gfx_FillRectangle(x, y, w, h); gfx_SetColor(cWhite); gfx_Rectangle(x, y, w, h); }
static void wrapText(const char *s, int x, int y, int width, int step, int color) {
    char line[96]; int n = 0; gfx_SetTextFGColor(color);
    while (*s && y <= 232) {
        if (*s == '\n') { line[n] = 0; printFit(line, x, y); n = 0; y += step; s++; continue; }
        if (*s == ' ') { if (n && n < 90) line[n++] = ' '; s++; continue; }
        int len = 0; while (s[len] && s[len] != ' ' && s[len] != '\n') len++;
        if (len > 40) len = 40;
        if (n + len >= (int)sizeof line) { line[n] = 0; printFit(line, x, y); n = 0; y += step; }
        memcpy(line + n, s, len); line[n + len] = 0;
        if (n && (int)gfx_GetStringWidth(line) > width) {
            while (n && line[n - 1] == ' ') n--;
            line[n] = 0; printFit(line, x, y); y += step; memcpy(line, s, len); n = len; line[n] = 0;
        } else n += len;
        s += len;
    }
    line[n] = 0; if (n) printFit(line, x, y);
}
static void drawArt(int id, int frame, int x, int y, bool flip) {
    gfx_sprite_t *sprite = art_sprite(id, frame);
    mark(x, y, sprite->width, sprite->height);
    if (!flip) { gfx_TransparentSprite(sprite, x, y); return; }
    gfx_FlipSpriteY(sprite, (gfx_sprite_t *)flipBuffer);
    gfx_TransparentSprite((gfx_sprite_t *)flipBuffer, x, y);
}
static int skyFor(int stage) { return stage == 16 ? ART_SKY_CAVEIMAGE_LEFT : stage > 11 ? ART_SKY_DESERTIMAGE_LEFT : stage > 7 ? ART_SKY_CAVEIMAGE_LEFT : stage > 3 ? ART_SKY_SUNSETIMAGE_LEFT : ART_SKY_DESERTIMAGE_LEFT; }
static int xpNeeded(void) { return playerLevel * (playerLevel < 5 ? 50 : 100); }
static void xpBar(int x, int y, int w) {
    mark(x, y, w, 6);
    gfx_SetColor(cBlack); gfx_FillRectangle(x, y, w, 6);
    gfx_SetColor(cYellow); gfx_FillRectangle(x + 1, y + 1, (w - 2) * xp / xpNeeded(), 4);
    gfx_SetColor(cWhite); gfx_Rectangle(x, y, w, 6);
}

/* ---------- menus ---------- */
static void renderMenu(void) {
    art_background(ART_TITLESTATE_TITLEIMAGE_LEFT);
    for(int i=0;i<2;i++){
        art_draw(ART_BUTTON,titleChoice==i,89,174+i*30);
        centered(i?"Options":"Play Game",184+i*30,cWhite);
    }
    centered("UP/DOWN choose   ENTER select",148,cWhite);
    centered("Hamumu Software, 2012",230,cWhite);
}
static void renderMap(void) {
    art_background(ART_MENUS_MAPSTATE_MAPIMAGE_LEFT);
    int top=KEY_DOWN(kb_KeyVars)?17:unlocked;
    for(int i=0;i<top;i++){
        for(unsigned d=mapDotStarts[i];d<mapDotStarts[i+1];d++){
            int size=5;
            if(i==top-1)size=(int)(menuTicks-mapEntered)-(d-mapDotStarts[i])*5;
            if(size<=0)continue;
            if(size>=5)art_draw(ART_MAP_X,3,mapDots[d][0]-9,mapDots[d][1]-9);
            else{gfx_sprite_t *dst=(gfx_sprite_t *)scaleBuffer;dst->width=19*size/5;dst->height=18*size/5;gfx_ScaleSprite(art_sprite(ART_MAP_X,3),dst);gfx_TransparentSprite(dst,mapDots[d][0]-dst->width/2,mapDots[d][1]-dst->height/2);}
        }
        int size=i==top-1?(int)(menuTicks-mapEntered)-(mapDotStarts[i+1]-mapDotStarts[i])*5:5;
        if(size>=5)art_draw(ART_MAP_X,i==level?1:0,mapNodes[i][0]-9,mapNodes[i][1]-9);
        else if(size>0){gfx_sprite_t *dst=(gfx_sprite_t *)scaleBuffer;dst->width=19*size/5;dst->height=18*size/5;gfx_ScaleSprite(art_sprite(ART_MAP_X,i==level?1:0),dst);gfx_TransparentSprite(dst,mapNodes[i][0]-dst->width/2,mapNodes[i][1]-dst->height/2);}
    }
    art_draw(ART_MAP_BUTTON,2,198,1);art_draw(ART_MAP_BUTTON,4,253,1);
    label("SKILLS",201,6,cWhite);label("TITLE",260,6,cWhite);
    panel(124,186,192,52);
    snprintf(textbuf,sizeof textbuf,"%u. %s",level+1,stageTitles[level]);label(textbuf,129,190,cYellow);
    snprintf(textbuf,sizeof textbuf,"Level %d  Points %d",playerLevel,skillPoints);label(textbuf,129,201,cWhite);
    label("Arrows stage  ENTER play",129,213,cWhite);
    label("STAT skills  MODE title",129,226,cCyan);
}
static void renderOptions(void) {
    static const char *const resetText[]={"Reset Progress","Really reset?","Are you sure!?","You'll lose everything!","One more click...","Really, one more resets!","PROGRESS IS CLEARED!"};
    art_background(ART_SKY_SUNSETIMAGE_LEFT);centered("OPTIONS",4,cWhite);
    for(int i=0;i<4;i++){
        art_draw(ART_BUTTON,optionChoice==i,89,40+i*34);
        if(i<2)snprintf(textbuf,sizeof textbuf,"%s: %u%%",i?"Music":"Sound",i?musicVolume:soundVolume);
        else snprintf(textbuf,sizeof textbuf,"%s",i==2?resetText[resetStage]:"Exit");
        centered(textbuf,50+i*34,cWhite);
    }
    centered("Calculator audio is not implemented",184,cWhite);
    centered("UP/DOWN choose  ENTER select",205,cCyan);
    centered("MODE returns to the title",220,cCyan);
}
static void initEnding(void) {
    if(endingReady)return;
    for(int i=0;i<20;i++)endingFood[i]=(EndingFood){(-40+i*30)*FP,(180+rand()%40-20)*FP,(rand()%60-30)*FP/HZ,rand()%5};
    endingReady=true;
}
static void stepEnding(void) {
    for(int i=0;i<20;i++){
        EndingFood *f=&endingFood[i];
        if(f->x< -20*FP){f->x+=600*FP;f->y=(180+rand()%40-20)*FP;f->vy=(rand()%60-30)*FP/HZ;}
        else if(f->y<160*FP)f->vy+=20*FP/(HZ*HZ);
        else if(f->y>200*FP)f->vy-=20*FP/(HZ*HZ);
        f->x-=40*FP/HZ;f->y+=f->vy;
    }
}
static void renderEnding(void) {
    static const uint8_t fire[]={0,1,0,2,3,4,5,6,7,6,5,4,3,2};
    art_background(ART_SKY_SUNSETIMAGE_LEFT);centered("YOU WIN!",4,cWhite);
    wrapText(endingText,10,40,300,10,cWhite);
    initEnding();
    for(int i=0;i<20;i++)art_draw(ART_FOOD,endingFood[i].frame,endingFood[i].x/FP,endingFood[i].y/FP);
    art_draw(ART_TOWER_SOAPBOX,fire[(menuTicks*18/HZ)%14],10,216);
    drawArt(ART_TOWER_SOAPBOX,fire[(menuTicks*18/HZ)%14],297,216,true);
    art_draw(ART_BUTTON,0,89,210);centered("Yay!",220,cWhite);
}
static void renderHelp(void) {
    gfx_FillScreen(cPanel);
    shadowLabel("DEFEND THE CAMP'S FIVE MEALS", 40, 4, cYellow);
    static const char *const lines[] = {
        "Arrows: move the building cursor",
        "1 Rock  2 Roly Poly  3 Snow  4 Shock",
        "2nd: build the chosen tower here",
        "ENTER: upgrade the tower (5 levels)",
        "MATH / APPS: branch a base tower into",
        "  its two specializations (needs skill)",
        "DEL: sell for half of all money spent",
        "+/-: speed 0-4x; 0 freezes/resumes",
        "ALPHA: pause   MODE: back to stages",
        "STAT: focus alien; VARS clears focus",
        "CLEAR: save and exit",
        "GRAPH sends the next wave early.",
        "dropped food can be grabbed again."};
    for (int i = 0; i < 13; i++) label(lines[i], 10, 22 + i * 14, cWhite);
    centered("Original game: Hamumu Software, 2012", 208, cYellow);
    label("Press ENTER or MODE to return", 50, 224, cCyan);
}

/* Skill grid positions follow the original SkillState layout. */
static int skillX(const SkillRule *r) { return 7 + r->group * 81 + r->column * 23 + (r->group > 1); }
static int skillY(const SkillRule *r) { return 33 + r->rank * 25; }
static void moveSkill(int dx, int dy) {
    const SkillRule *c = &skillRules[skillCursor]; int best = -1, bestScore = 0x7fffff;
    for (int i = 0; i < 48; i++) {
        if (i == skillCursor) continue;
        int ddx = skillX(&skillRules[i]) - skillX(c), ddy = skillY(&skillRules[i]) - skillY(c);
        if (dx && ddx * dx <= 0) continue;
        if (dy && ddy * dy <= 0) continue;
        int score = dx ? abs(ddx) + abs(ddy) * 3 : abs(ddy) + abs(ddx) * 3;
        if (score < bestScore) { bestScore = score; best = i; }
    }
    if (best >= 0) skillCursor = best;
}
static void buySkill(void) {
    int id = skillRules[skillCursor].icon;
    if (skills[id] >= 5) { say("Already at maximum rank"); return; }
    if (skillNeeded(skillCursor) > 0) { say("Spend more points in earlier ranks first"); return; }
    if (!skillPoints) { say("No skill points - win battles for XP"); return; }
    skills[id]++; skillPoints--; save(); say("Skill learned");
}
static void resetSkills(void) {
    int refund = 0;
    for (int i = 0; i < 48; i++) refund += skills[i];
    refund -= 1; skillPoints += refund; memset(skills, 0, sizeof skills); skills[SK_ROCKTOWER] = 1; save(); say("Skills reset - full refund");
}
static void renderSkills(void) {
    art_background(ART_SKY_DESERTIMAGE_LEFT);
    shadowLabel("SKILLS", 140, 1, cWhite);
    snprintf(textbuf, sizeof textbuf, "Points left: %d", skillPoints); shadowLabel(textbuf, 3, 12, cWhite);
    snprintf(textbuf, sizeof textbuf, "Level %d", playerLevel); shadowLabel(textbuf, 250, 12, cWhite); xpBar(190, 13, 56);
    for (int g = 0; g < 4; g++) art_draw(ART_SKILL_BACK, g, g * 81 + (g > 1), 26);
    for (int i = 0; i < 48; i++) {
        const SkillRule *r = &skillRules[i]; int x = skillX(r), y = skillY(r), id = r->icon; bool enabled = skillNeeded(i) <= 0;
        art_draw(ART_SKILL_FRAME, enabled ? r->group + 1 : 0, x - 3, y - 3);
        art_draw(ART_SKILL_ICON, id + (enabled ? 0 : 48), x, y);
        if (enabled) {
            art_draw(ART_SKILL_TRAY, r->group, x, y + 15);
            for (int k = 0; k < skills[id]; k++) art_draw(ART_SKILL_POINT, r->group, x + 1 + k * 3, y + 16);
        }
    }
    const SkillRule *c = &skillRules[skillCursor];
    gfx_SetColor(cYellow); gfx_Rectangle(skillX(c) - 4, skillY(c) - 4, 24, 24); gfx_Rectangle(skillX(c) - 5, skillY(c) - 5, 26, 26);
    panel(4, 164, 312, 40);
    snprintf(textbuf, sizeof textbuf, "%s   rank %d / 5", c->name, skills[c->icon]); centered(textbuf, 168, cYellow);
    int need = skillNeeded(skillCursor);
    if (need >= 999) snprintf(textbuf, sizeof textbuf, "Requires the tower's base skill first");
    else if (need > 0) snprintf(textbuf, sizeof textbuf, "Needs %d more points in earlier ranks", need);
    else snprintf(textbuf, sizeof textbuf, "Available - ENTER spends a point");
    centered(textbuf, 180, cWhite);
    label("Arrows move   ENTER learn   DEL reset all", 36, 192, cCyan);
    label("ALPHA details   MODE back", 80, 210, cCyan);
    if(skillDetails){
        const char *blob=(const char *)(artBanks[ART_SKILL_BANK]+ART_SKILL_OFFSET);
        int rank=skills[c->icon];panel(8,52,304,136);
        snprintf(textbuf,sizeof textbuf,"%s (%d/5)",c->name,rank);centered(textbuf,57,cYellow);
        label("CURRENT",16,71,cCyan);
        wrapText(rank?blob+skillTextOffsets[c->icon][rank-1]:"Not learned yet.",16,82,286,10,cWhite);
        label("NEXT RANK",16,125,cYellow);
        wrapText(rank<5?blob+skillTextOffsets[c->icon][rank]:"Maximum rank reached.",16,136,286,10,cWhite);
    }
    if (statusTicks) shadowLabel(status, (320 - gfx_GetStringWidth(status)) / 2, 224, cWhite);
}

/* ---------- gameplay rendering ---------- */
static int monsterFrame(const Enemy *e, int index) {
    const Anim *a = &anims[e->type]; bool off = e->disabled || e->crippled; int t = tick / 2 + index;
    if (e->action == 1 || !e->ground) return off ? a->disabledJump : a->jump;
    return off ? a->disabled[t % a->disabledLength] : a->walk[t % a->walkLength];
}
static void drawTowerArt(const Tower *t, int x, int y) {
    int id = towerArt[t->type]; const Art *art = &artTable[id];
    if(t->born){
        gfx_sprite_t*src=art_sprite(id,0);gfx_sprite_t*dst=(gfx_sprite_t*)scaleBuffer;
        dst->width=art->width;dst->height=art->height*(HZ-t->born)/HZ+1;
        gfx_ScaleSprite(src,dst);mark(x+8-art->width/2,y+16-dst->height,dst->width,dst->height);gfx_TransparentSprite(dst,x+8-art->width/2,y+16-dst->height);
        drawArt(ART_BUILD,(tick*3/4)%4,x-8+(tick%3)*4,y-7,false);return;
    }
    int frame = 0;
    if (t->animation && art->frames > 2) frame = 2 + (tick / 2) % (art->frames - 2);
    drawArt(id, frame, x + 8 - art->width / 2, y + 16 - art->height, t->facing < 0);
    if(t->buildTime)drawArt(ART_BUILD,(tick*3/4)%4,x-8+(tick%3)*4,y-7,false);
    for (int l = 0; l <= t->level && l < 6; l++) artDraw(ART_UPGRADE, 0, x + (l % 3) * 5, y - 5 - (l / 3) * 5);
}
static void hudSet(int i, int x0, int y0, int x1, int y1, unsigned extra, const char *key) {
    HudItem *h = &hudNow[i];
    h->x0 = x0; h->y0 = y0; h->x1 = x1; h->y1 = y1; h->extra = extra;
    strncpy(h->key, key, HUD_KEY - 1); h->key[HUD_KEY - 1] = 0;
}
static int fitWidth(const char *s, int x) { int w = gfx_GetStringWidth(s); return w < 316 - x ? w : 316 - x; }
/* Work out what every HUD item will show this frame (same text as the original code). */
static void hudCompute(int ti) {
    const Art *a = &artTable[ART_HUD];
    hudSet(HUD_FRAME, 195, 0, 195 + a->width, a->height, 0, "");
    snprintf(textbuf, sizeof textbuf, "$%d", money); hudSet(HUD_MONEY, 267, 23, 267 + fitWidth(textbuf, 267), 31, 0, textbuf);
    a = &artTable[ART_SPEED_SLIDER]; hudSet(HUD_SLIDER, 210 + speedThirds * 5, 2, 210 + speedThirds * 5 + a->width, 2 + a->height, speedThirds, "");
    snprintf(textbuf, sizeof textbuf, "W%u/%u", wave, waveCounts[level]); hudSet(HUD_WAVE, 3, 25, 3 + fitWidth(textbuf, 3), 33, 0, textbuf);
    if (wave < waveCounts[level] && waveDue[wave] > 0) {
        snprintf(textbuf, sizeof textbuf, "%ds", (waveDue[wave] + HZ - 1) / (sendFast ? HZ * HZ : HZ)); hudSet(HUD_TIMER, 64, 25, 64 + fitWidth(textbuf, 64), 33, 0, textbuf);
    } else hudSet(HUD_TIMER, 0, 0, 0, 0, 0, "");
    snprintf(textbuf, sizeof textbuf, "FOOD %d", foodLeft()); hudSet(HUD_FOOD, 3, 3, 4 + fitWidth(textbuf, 4), 12, foodLeft() < 3 ? cRed : cWhite, textbuf);
    snprintf(textbuf, sizeof textbuf, "LV %d", playerLevel); { int w = 4 + fitWidth(textbuf, 4); hudSet(HUD_LEVEL, 3, 13, w > 83 ? w : 83, 22, (50 - 2) * xp / xpNeeded(), textbuf); }
    char *k = textbuf;
    if (statusTicks) { strncpy(k, status, 80); k[80] = 0; }
    else if (ti >= 0) {
        const Tower *t = &towers[ti];
        snprintf(k, 81, "%s L%d  upgrade $%d  sell $%d", towerNames[t->type], t->level + 1, t->level >= 5 ? 0 : upgradeCost((Tower *)t), t->spent / 2);
    } else snprintf(k, 81, "%d %s $%d   2nd = build", selection + 1, towerNames[baseTypes[selection]], (int)rule_BasePrice(baseTypes[selection], 0));
    char second[48];
    if (ti >= 0 && towers[ti].type <= SHOCK) snprintf(second, sizeof second, "MATH %s  APPS %s", towerNames[branchTypes[towers[ti].type][0]], towerNames[branchTypes[towers[ti].type][1]]);
    else strcpy(second, "GRAPH wave  +/- speed  STAT focus");
    hudSet(HUD_PANEL, 0, PANEL_TOP, 320, 240, statusTicks != 0, "");
    snprintf(panelNow, sizeof panelNow, "%s\n%s", second, k);
    hudBottom = 0;
    for (int i = 0; i < HUD_PANEL; i++) {
        if (hudNow[i].y1 > hudBottom) hudBottom = hudNow[i].y1;
        for (int b = 0; b < 2; b++) if (hudHeld[b][i].y1 > hudBottom) hudBottom = hudHeld[b][i].y1;
    }
}
static bool hudSame(const HudItem *a, const HudItem *b) {
    return a->x0 == b->x0 && a->y0 == b->y0 && a->x1 == b->x1 && a->y1 == b->y1 && a->extra == b->extra && !strcmp(a->key, b->key);
}
static void hudDraw(int i) {
    const HudItem *h = &hudNow[i];
    switch (i) {
    case HUD_FRAME: art_draw(ART_HUD, 0, 195, 0); break;
    case HUD_MONEY: label(h->key, 267, 23, cWhite); break;
    case HUD_SLIDER: art_draw(ART_SPEED_SLIDER, 0, h->x0, 2); break;
    case HUD_WAVE: label(h->key, 3, 25, cWhite); break;
    case HUD_TIMER: if (h->key[0]) label(h->key, 64, 25, cYellow); break;
    case HUD_FOOD: shadowLabel(h->key, 3, 3, h->extra); break;
    case HUD_LEVEL: shadowLabel(h->key, 3, 13, cWhite); xpBar(33, 14, 50); break;
    default: {
        gfx_SetColor(cPanel); gfx_FillRectangle(0, 217, 320, 23);
        const char *line1 = strchr(panelNow, '\n') + 1;
        char second[48]; size_t n = line1 - 1 - panelNow; memcpy(second, panelNow, n); second[n] = 0;
        if (h->extra) shadowLabel(line1, 3, 219, cYellow); else label(line1, 3, 219, cWhite);
        label(second, 3, 229, cCyan);
    }
    }
}
static void renderGame(void) {
    camx = cx * 16 + 8 - 160; camy = cy * 16 + 8 - 110;
    if (camx > map->width * 16 - 320) camx = map->width * 16 - 320;
    if (camy > map->height * 16 - 240) camy = map->height * 16 - 240;
    if (camx < 0) camx = 0;
    if (camy < 0) camy = 0;
#ifdef QA_PERF
    renderStamp=timer_GetSafe(1,TIMER_UP);
#endif
    int theme=level==16?2:level>11?3:level>7?2:level>3?1:0;
    uint32_t backgroundKey=(uint32_t)camx|(uint32_t)camy<<11|(uint32_t)level<<21;
    int ti = towerAt(cy * map->width + cx);
    hudCompute(ti);
    bool full = heldBackground[drawIndex] != backgroundKey || dirtyOverflow[drawIndex];
    /* A HUD item whose content changed gets its old rectangle repaired with the sprites'. */
    for (int i = 0; i < HUD_N && !full; i++) {
        const HudItem *h = &hudHeld[drawIndex][i];
        hudNeed[i] = !hudSame(&hudNow[i], h) || (i == HUD_PANEL && strcmp(panelNow, panelHeld[drawIndex]));
        if (hudNeed[i] && h->x0 < h->x1 && h->y0 < PANEL_TOP) pushRect(h->x0, h->y0, h->x1, h->y1 < PANEL_TOP ? h->y1 : PANEL_TOP);
    }
    full |= dirtyOverflow[drawIndex];
    if (full) {
        for (int i = 0; i < HUD_N; i++) { hudNeed[i] = true; hudHeld[drawIndex][i].x0 = hudHeld[drawIndex][i].x1 = 0; hudHeld[drawIndex][i].key[0] = 1; }
        panelHeld[drawIndex][0] = 1;
        panelTouched[drawIndex] = true;
        art_background(skyFor(level));
        input_poll();
#ifdef QA_PERF
        renderMark(0);
#endif
        for (int layer = 0; layer < 3; layer++)
            for (int y = camy / 16; y < map->height && y * 16 - camy < 240; y++) {
                const uint8_t *row=layers[layer]+y*map->width+camx/16;
                int screenY=y*16-camy,screenX=-(camx%16);
                for (int x = camx / 16; x < map->width && screenX < 320; x++,screenX+=16) {
                    int tile = *row++;
                    if (tile && tile < 128) art_draw(ART_TILES0+theme, tile, screenX, screenY);
                }
                input_poll();
            }
        heldBackground[drawIndex] = backgroundKey;
    } else {
        /* Sky exactly inside each recorded rectangle, then the tile layers of every cell
         * they touch, once per cell, from its topmost opaque tile. Tiles are exactly one
         * cell; over correct sky they reproduce the full redraw, and any stale pixel lies
         * inside a rectangle whose sky was just repaired. A cell crossing PANEL_TOP forces
         * the panel to be repainted. */
        int sky=skyFor(level), ox=camx&15, oy=camy&15, cellX=camx>>4, cellY=camy>>4;
        for (unsigned i = 0; i < dirtyCount[drawIndex]; i++) {
            const Rect *r = &dirty[drawIndex][i];
            hudTouch(r->x0, r->y0, r->x1, r->y1);
            art_sky_rect(sky, r->x0, r->y0, r->x1, r->y1);
            unsigned gx0 = (r->x0 + ox) >> 4, gx1 = (r->x1 - 1 + ox) >> 4, gy0 = (r->y0 + oy) >> 4, gy1 = (r->y1 - 1 + oy) >> 4;
            for (unsigned gy = gy0; gy <= gy1; gy++) memset(&cellsToDraw[gy][gx0], 1, gx1 - gx0 + 1);
            if (!(i & 7)) input_poll();
        }
        for (int gy = 0; gy < GRID_H; gy++) {
            int sy = gy * 16 - oy, ty = cellY + gy;
            uint8_t *cells = cellsToDraw[gy];
            for (int gx = 0; gx < GRID_W; gx++) {
                if (!cells[gx]) continue;
                cells[gx] = 0;
                int sx = gx * 16 - ox, tx = cellX + gx;
                if (tx >= map->width || ty >= map->height) continue;
                if (sy + 16 > PANEL_TOP) panelTouched[drawIndex] = true;
                int at = ty * map->width + tx;
                uint8_t tile[3] = {layers[0][at], layers[1][at], layers[2][at]};
                int first = 0;
                for (int layer = 2; layer > 0; layer--)
                    if (tile[layer] && tile[layer] < 128 && art_tile_opaque(tile[layer])) { first = layer; break; }
                for (int layer = first; layer < 3; layer++)
                    if (tile[layer] && tile[layer] < 128) art_draw(ART_TILES0+theme, tile[layer], sx, sy);
            }
        }
        input_poll();
    }
    dirtyCount[drawIndex] = 0; dirtyOverflow[drawIndex] = false; tracking = true;
#ifdef QA_PERF
    renderMark(1);
#endif
    int fx = map->camp % map->width * 16 - camx, fy = map->camp / map->width * 16 - camy;
    artDraw(ART_TENT, 0, fx - 20, fy + 6); artDraw(ART_TENT, 0, fx + 20, fy + 6); artDraw(ART_FIRE, tick / 2, fx, fy - 3);
    for (int i = 0; i < 5; i++) {
        const Food *f = &foods[i];
        if (f->active) artDraw(ART_FOOD, i, f->x_pixel - 8 - camx, f->y_pixel - 16 - camy);
    }
    for (int i = 0; i < MAXTOWER; i++) {
        if(!(i&7))input_poll();
        const Tower *t = &towers[i];
        if (t->active) drawTowerArt(t, t->cell % map->width * 16 - camx, t->cell / map->width * 16 - camy);
    }
    for (int i = 0; i < enemyTop; i++) {
        if(!(i&7))input_poll();
        const Enemy *e = &enemies[i]; if (!e->active) continue;
        int id = monsterArt[e->type]; const Art *art = &artTable[id];
        static const uint8_t offsetY[10]={0,0,6,8,0,0,0,0,31,3};
        int x=e->x_pixel-art->width/2-camx-((e->type==1||e->type==5)?2:0);
        int y=e->y_pixel-monsterHeight[e->type]-offsetY[e->type]-camy;
        if (x > 320 || x + art->width < 0 || y > 240 || y + art->height < 0) continue;
        int frame=monsterFrame(e,i)%art->frames;
        if(e->type==8||e->born||e->flat) {
            gfx_sprite_t*src=art_sprite(id,frame);gfx_sprite_t*dst=(gfx_sprite_t*)scaleBuffer;
            int w=art->width,h=art->height;
            if(e->type==8){w=(uint32_t)w*e->scale/10000;h=(uint32_t)h*e->scale/10000;w=w*e->wobble/1000;h=h*(1500-e->wobble/2)/1000;}
            if(e->born){int total=e->birthLength?e->birthLength:HZ,progress=total-e->born;if(progress<1)progress=1;if(e->type!=9)w=w*progress/total;h=h*progress/total;}
            if(e->flat)h=art->height/10+1;
            if(w<1)w=1;if(h<1)h=1;if(w>64)w=64;if(h>56)h=56;
            dst->width=w;dst->height=h;gfx_ScaleSprite(src,dst);mark(x+(art->width-w)/2,y+art->height-h,w,h);
            if(e->facing<0){gfx_FlipSpriteY(dst,(gfx_sprite_t*)flipBuffer);dst=(gfx_sprite_t*)flipBuffer;}
            gfx_TransparentSprite(dst,x+(art->width-w)/2,y+art->height-h);
        }else drawArt(id,frame,x,y,e->facing<0);
        if (e->hp < e->maxhp) {
            mark(x, y - 3, art->width + 1, 2);
            gfx_SetColor(cBlack); gfx_FillRectangle(x, y - 3, art->width, 2);
            gfx_SetColor(cGreen); gfx_FillRectangle(x, y - 3, (uint32_t)art->width * e->hp / e->maxhp + 1, 2);
        }
        int pip = x;
        if (e->freeze || e->slow || e->shock || e->poison || e->crippled || e->disabled) mark(x, y - 6, 19, 2);
        if (e->freeze) { gfx_SetColor(cCyan); gfx_FillRectangle(pip, y - 6, 3, 2); pip += 4; }
        if (e->slow) { gfx_SetColor(cWhite); gfx_FillRectangle(pip, y - 6, 3, 2); pip += 4; }
        if (e->shock) { gfx_SetColor(cYellow); gfx_FillRectangle(pip, y - 6, 3, 2); pip += 4; }
        if (e->poison) { gfx_SetColor(cGreen); gfx_FillRectangle(pip, y - 6, 3, 2); pip += 4; }
        if (e->crippled || e->disabled) { gfx_SetColor(cRed); gfx_FillRectangle(pip, y - 6, 3, 2); }
        if (e->immune) { mark(x - 1, y - 1, art->width + 2, art->height + 2); gfx_SetColor(cWhite); gfx_Rectangle(x - 1, y - 1, art->width + 2, art->height + 2); }
    }
    if(focusEnemy>=0&&enemies[focusEnemy].active){const Enemy *e=&enemies[focusEnemy];artDraw(ART_BOX,4,ex(e)-12-camx,e->y_pixel-monsterHeight[e->type]-24-camy);}
#ifdef QA_PERF
    renderMark(2);
#endif
    for (int i = 0; i < bulletTop; i++) {
        if(!(i&7))input_poll();
        const Bullet *b = &bullets[i]; if (!b->active) continue;
        int bx = b->x_pixel - camx, by = b->y_pixel - camy;
        int id=bulletArt[b->type];const Art*art=&artTable[id];
        static const uint8_t slushFrames[6]={0,1,2,3,2,1};
        int frame=b->pop?b->pop:b->type==SLUSHEE?slushFrames[b->age%6]:0;
        artDraw(id,frame,bx-art->width/2,by-art->height/2);
    }
    for (int i = 0; i < MAXTOWER; i++) {
        if(!(i&7))input_poll();
        const Tower *t = &towers[i];
        if (!t->active || t->born) continue;
        int x = t->cell % map->width * 16 + 8 - camx, y = t->cell / map->width * 16 + 8 - camy;
        if (t->animation && (t->type == SHOCK || t->type == CRIPPLER || t->type == LIGHTNING)) {
            gfx_SetColor(t->type == CRIPPLER ? cRed : cYellow);
            if (t->type == LIGHTNING) { mark(x, 0, 1, y); gfx_VertLine(x, 0, y); } else { int r = t->range / 2; mark(x - r, y - r, 2 * r + 1, 2 * r + 1); gfx_Circle(x, y, r); }
        }
    }
#ifdef QA_PERF
    renderMark(3);
#endif
    int x = cx * 16 - camx, y = cy * 16 - camy;
    if (ti >= 0 && towers[ti].range) { int r = towers[ti].range; mark(x + 8 - r, y + 8 - r, 2 * r + 1, 2 * r + 1); gfx_SetColor(cWhite); gfx_Circle(x + 8, y + 8, r); }
    artDraw(ART_BOX, valid(cx, cy) || ti >= 0 ? 1 : 0, x - 4, y - 4);
    artDraw(ART_CURSOR, (valid(cx, cy) || ti >= 0) ? 1 : 0, x, y);
    tracking = false;
    for (int i = 0; i < HUD_N; i++) {
        if (!hudNeed[i] && !(i == HUD_PANEL && panelTouched[drawIndex])) continue;
        hudDraw(i);
        const HudItem *h = &hudNow[i];
        for (int j = i + 1; j < HUD_N; j++)
            if (overlaps(h->x0, h->y0, h->x1, h->y1, &hudNow[j]) || overlaps(h->x0, h->y0, h->x1, h->y1, &hudHeld[drawIndex][j])) hudNeed[j] = true;
        hudHeld[drawIndex][i] = hudNow[i];
        if (i == HUD_PANEL) strcpy(panelHeld[drawIndex], panelNow);
    }
    panelTouched[drawIndex] = false;
    tracking = true;
    if(!speedThirds&&!paused&&!showTip){panel(81,84,158,26);centered("TIME FROZEN",90,cYellow);}
#ifdef QA_PERF
    renderMark(4);
#endif
    if (paused && !showTip) { panel(70, 90, 180, 40); centered("PAUSED", 98, cYellow); centered("ALPHA resumes", 112, cWhite); }
    if (showTip) {
        panel(2, 4, 316, 232); snprintf(textbuf, sizeof textbuf, "- %s -", stageTitles[level]); centered(textbuf, 11, cYellow);
        wrapText(stageTips[level], 12, 26, 296, 9, cWhite);
        label("Arrows move, 2nd builds, ENTER upgrades", 12, 208, cCyan);
        label("ENTER: DEFEND!", 112, 221, cYellow);
    }
    if (mode == MODE_WON || mode == MODE_LOST) {
        panel(30, 70, 260, 96);
        centered(mode == MODE_WON ? "CAMP SAVED!" : "THE FOOD IS GONE", 78, mode == MODE_WON ? cGreen : cRed);
        snprintf(textbuf, sizeof textbuf, "Level %d   Skill points %d", playerLevel, skillPoints); centered(textbuf, 98, cWhite);
        xpBar(110, 112, 100);
        centered(mode == MODE_WON ? "ENTER next stage" : "ENTER try again", 128, cWhite);
        centered("STAT skills   MODE stage menu", 142, cCyan);
    }
    tracking = false;
}

static void beginStage(bool bypass) {
    if (level >= unlocked && !bypass) { say("Locked - win the previous stage first"); return; }
    startLevel();showTip = true; paused = true; statusTicks = 0;
#ifdef QA_FOCUS /* fixed fixture for verifying the keyboard selection path */
    Enemy *fixture=spawnEnemy(0,1,map->routes[0].cells[0]);
    if(fixture){fixture->born=0;fixture->freeze=1200;fixture->x=(cx*16+8)*FP;fixture->y=(cy*16+8+monsterHeight[0]/2)*FP;}
#endif
}
static void updateDiagnostics(void) {
    int count = 0;
    for (int i = 0; i < MAXTOWER; i++) count += towers[i].active;
    scout_diag[0] = mode; scout_diag[1] = level; scout_diag[2] = wave; scout_diag[3] = count; scout_diag[4] = alive(); scout_diag[5] = escaped;
    scout_diag[6] = paused; scout_diag[7] = stageWon[level]; scout_diag[8] = skillPoints; scout_diag[9] = playerLevel; scout_diag[10] = foodLeft(); scout_diag[11] = showTip;
    scout_diag[12]=speedThirds;scout_diag[13]=focusEnemy+1;scout_diag[14]=tick;scout_diag[15]=tick>>8;
}
static void handleMenu(void) {
    if(KEY_PRESS(kb_KeyUp)||KEY_PRESS(kb_KeyDown))titleChoice^=1;
    if(KEY_PRESS(kb_KeyEnter)){mode=titleChoice?MODE_OPTIONS:MODE_MAP;resetStage=0;}
    if(KEY_PRESS(kb_KeyAlpha)){mode=MODE_HELP;helpReturn=MODE_MENU;}
}
static void handleMap(void) {
    int count=KEY_DOWN(kb_KeyVars)?17:unlocked;
    if(level>=count)level=count-1;
    if (KEY_PRESS(kb_KeyLeft)||KEY_PRESS(kb_KeyUp)) level = (level + count-1) % count;
    if (KEY_PRESS(kb_KeyRight)||KEY_PRESS(kb_KeyDown)) level = (level + 1) % count;
    if (KEY_PRESS(kb_KeyEnter)) beginStage(KEY_DOWN(kb_KeyVars));
    if (KEY_PRESS(kb_KeyAlpha)){mode=MODE_HELP;helpReturn=MODE_MAP;}
    if (KEY_PRESS(kb_KeyStat)){mode=MODE_SKILLS;skillReturn=MODE_MAP;}
    if (KEY_PRESS(kb_KeyMode))mode=MODE_MENU;
}
static void handleOptions(void) {
    if(KEY_PRESS(kb_KeyUp))optionChoice=(optionChoice+3)%4;
    if(KEY_PRESS(kb_KeyDown))optionChoice=(optionChoice+1)%4;
    if(KEY_PRESS(kb_KeyMode))mode=MODE_MENU;
    if(KEY_PRESS(kb_KeyEnter)){
        if(optionChoice<2){uint8_t *v=optionChoice?&musicVolume:&soundVolume;*v=*v==100?0:*v+25;}
        else if(optionChoice==3)mode=MODE_MENU;
        else if(resetStage<6){
            resetStage++;
            if(resetStage==6){memset(skills,0,sizeof skills);skills[SK_ROCKTOWER]=1;memset(stageWon,0,sizeof stageWon);playerLevel=1;skillPoints=xp=level=0;unlocked=1;save();}
        }
    }
}
static void handleSkills(void) {
    if (KEY_PRESS(kb_KeyLeft)) moveSkill(-1, 0);
    if (KEY_PRESS(kb_KeyRight)) moveSkill(1, 0);
    if (KEY_PRESS(kb_KeyUp)) moveSkill(0, -1);
    if (KEY_PRESS(kb_KeyDown)) moveSkill(0, 1);
    if (KEY_PRESS(kb_KeyEnter)) buySkill();
    if (KEY_PRESS(kb_KeyDel)) resetSkills();
    if(KEY_PRESS(kb_KeyAlpha))skillDetails=!skillDetails;
    if (KEY_PRESS(kb_KeyMode)) { mode = skillReturn; save(); }
    if (statusTicks) statusTicks--;
}
static void handlePlay(void) {
    static uint32_t nextMove;
    if (showTip) {
        if (KEY_PRESS(kb_KeyEnter) || KEY_PRESS(kb_KeyAlpha) || KEY_PRESS(kb_Key2nd)) { showTip = false; paused = false; }
        if (KEY_PRESS(kb_KeyMode)) mode = MODE_MAP;
        return;
    }
    if (KEY_PRESS(kb_KeyMode)) { mode = MODE_MAP; return; }
    if (KEY_PRESS(kb_KeyAlpha)) paused = !paused;
    if(KEY_PRESS(kb_KeySub)&&speedThirds)speedThirds--;
    if(KEY_PRESS(kb_KeyAdd)&&speedThirds<12)speedThirds++;
    if(KEY_PRESS(kb_Key0)){if(speedThirds){previousSpeedThirds=speedThirds;speedThirds=0;}else speedThirds=previousSpeedThirds;}
    if(KEY_PRESS(kb_KeyStat))say(focusAt(cx*16+8,cy*16+8)>=0?"Focus fire selected":"No alien near the cursor");
    if(KEY_PRESS(kb_KeyVars)){focusEnemy=-1;say("Focus fire cleared");}
    bool move = input_held[7] & (kb_Left | kb_Right | kb_Up | kb_Down);
    if (move) {
        uint32_t now=timer_GetSafe(1,TIMER_UP);
        if (input_pressed[7] || !nextMove || (int32_t)(now-nextMove)>=0) {
            if (input_held[7] & kb_Left) cx--;
            if (input_held[7] & kb_Right) cx++;
            if (input_held[7] & kb_Up) cy--;
            if (input_held[7] & kb_Down) cy++;
            if (cx < 1) cx = 1;
            if (cx > map->width - 2) cx = map->width - 2;
            if (cy < 1) cy = 1;
            if (cy > map->height - 2) cy = map->height - 2;
            nextMove=now+32768/5; /* 200 ms, independent of draw/simulation rate */
        }
    } else nextMove = 0;
    if (KEY_DOWN(kb_Key1)) selection = 0;
    if (KEY_DOWN(kb_Key2)) selection = 1;
    if (KEY_DOWN(kb_Key3)) selection = 2;
    if (KEY_DOWN(kb_Key4)) selection = 3;
    if (KEY_PRESS(kb_Key2nd)){focusEnemy=-1;build();}
    if (KEY_PRESS(kb_KeyEnter)){focusEnemy=-1;upgrade();}
    if (KEY_PRESS(kb_KeyDel)) sellTower();
    if (KEY_PRESS(kb_KeyMath)) convertTower(0);
    if (KEY_PRESS(kb_KeyApps)) convertTower(1);
    if (KEY_PRESS(kb_KeyGraph)) { if (wave < waveCounts[level]) { sendWave(); say("Wave sent early"); } }
}
static void handleResult(void) {
    if (KEY_PRESS(kb_KeyMode)) mode = MODE_MAP;
    else if (KEY_PRESS(kb_KeyStat)){mode=MODE_SKILLS;skillReturn=MODE_MAP;}
    else if (KEY_PRESS(kb_KeyEnter)) {
        if(mode==MODE_WON&&level==16){mode=MODE_ENDING;return;}
        if (mode == MODE_WON && level < 16) level++;
        beginStage(true);
    }
}

static void handleInput(void) {
    if (mode == MODE_MENU) handleMenu();
    else if (mode == MODE_MAP) handleMap();
    else if (mode == MODE_OPTIONS) handleOptions();
    else if (mode == MODE_ENDING) { if(KEY_PRESS(kb_KeyEnter)||KEY_PRESS(kb_KeyMode))mode=MODE_MENU; }
    else if (mode == MODE_HELP) { if(KEY_PRESS(kb_KeyEnter)||KEY_PRESS(kb_KeyMode)||KEY_PRESS(kb_KeyAlpha))mode=helpReturn; }
    else if (mode == MODE_SKILLS) handleSkills();
    else if (mode == MODE_PLAY) handlePlay();
    else handleResult();
}

int main(void) {
    boot_Set48MHzMode();
    if (!art_open()) { os_ClrHome(); os_PutStrFull(art_error);os_NewLine();os_PutStrFull("Send all SCA resource files"); while (!os_GetCSC()) { } return 1; }
    load();
#ifdef QA_MAXED /* test builds only (see tests/README.md): every skill at rank 5, spare points, all stages open */
    memset(skills, 5, sizeof skills); skillPoints = 6; playerLevel = 30; unlocked = 17;
#endif
    gfx_Begin(); gfx_SetPalette(artPalette, sizeof artPalette, 0); gfx_SetTransparentColor(0); gfx_SetTextTransparentColor(0); gfx_SetTextBGColor(0); gfx_SetDrawBuffer();
    pickColors();
    timer_Set(1, 0); timer_Enable(1, TIMER_32K, TIMER_NOINT, TIMER_UP);
    uint32_t last = timer_GetSafe(1, TIMER_UP), accumulator = 0, frameStart = last;
    mode = MODE_MENU;
#ifdef QA_ENDING /* diagnostic entry, never enabled for production */
    mode = MODE_ENDING;
#endif
#ifdef QA_PERF
    uint32_t perfStart=last,drawTotal=0,simTotal=0;unsigned frameCount=0;
#endif
    while (1) {
        input_poll();
        uint32_t now = timer_GetSafe(1, TIMER_UP); accumulator += (now-last)*(mode==MODE_PLAY?speedThirds:3); last = now;
        menuTicks=(now>>15)*HZ+((now&32767)*HZ>>15);
        if(mode!=MODE_ENDING)endingReady=false;
        bool exitRequested=false;
        if(input_next()) {
            do {if(KEY_DOWN(kb_KeyClear)){exitRequested=true;break;}handleInput();} while(input_next());
        } else { if(KEY_DOWN(kb_KeyClear))exitRequested=true;else handleInput(); }
        if(exitRequested)break;
        if (mode == MODE_ENDING) {initEnding();int steps=0;while(accumulator>=STEP_TICKS*3&&steps<6){stepEnding();accumulator-=STEP_TICKS*3;steps++;}}
        else if (mode == MODE_PLAY) {
            if (mode == MODE_PLAY && !paused) {
                if(!speedThirds)accumulator=0;
#ifdef QA_PERF
                uint32_t simStart=timer_GetSafe(1,TIMER_UP);
#endif
                int steps = 0;
                while (accumulator >= STEP_TICKS*3 && steps < 12) { update(); accumulator -= STEP_TICKS*3; steps++; input_poll(); if (mode != MODE_PLAY || input_pending()) break; }
                if (steps == 12 && accumulator > 32768*3) accumulator = 32768*3;
#ifdef QA_PERF
                simTotal+=timer_GetSafe(1,TIMER_UP)-simStart;
#endif
            } else accumulator = 0;
        }
        if ((mode != MODE_PLAY && mode != MODE_ENDING) || (mode==MODE_PLAY&&paused)) accumulator = 0;
        /* Consume queued controls before starting another expensive redraw. */
        if(input_pending())continue;
#ifdef QA_PERF
        uint32_t drawStart=timer_GetSafe(1,TIMER_UP);
#endif
        if(mode==MODE_MAP&&previousDrawMode!=MODE_MAP)mapEntered=menuTicks;
        previousDrawMode=mode;
        if (mode == MODE_MENU) renderMenu();
        else if (mode == MODE_MAP) renderMap();
        else if (mode == MODE_OPTIONS) renderOptions();
        else if (mode == MODE_ENDING) renderEnding();
        else if (mode == MODE_HELP) renderHelp();
        else if (mode == MODE_SKILLS) renderSkills();
        else {
            renderGame();
#ifdef QA_DAMAGECHECK /* diagnostic only: retained frame must equal a full redraw */
            uint32_t retained = frameHash();
            heldBackground[drawIndex] = 0xffffffff; renderGame();
            scout_damage[0]++; if (frameHash() != retained) scout_damage[1]++;
#endif
        }
        /* Any other screen overwrote this buffer's stage background. */
        if (mode != MODE_PLAY && mode != MODE_WON && mode != MODE_LOST) heldBackground[drawIndex] = 0xffffffff;
#ifdef QA_OVERLAY
        heldBackground[drawIndex] = 0xffffffff;
#endif
#ifdef QA_PERF
        drawTotal+=timer_GetSafe(1,TIMER_UP)-drawStart;frameCount++;
        uint32_t perfNow=timer_GetSafe(1,TIMER_UP),span=perfNow-perfStart;
        if(span>=32768){scout_perf[0]=(uint32_t)frameCount*32768/span;scout_perf[1]=drawTotal*1000/span;scout_perf[2]=simTotal*1000/span;scout_perf[3]=accumulator;perfStart=perfNow;drawTotal=simTotal=frameCount=0;}
#ifdef QA_OVERLAY /* text overlay distorts timing; counters alone stay in scout_perf */
        snprintf(textbuf,sizeof textbuf,"FPS%u D%u S%u",scout_perf[0],scout_perf[1],scout_perf[2]);label(textbuf,2,204,cYellow);
        snprintf(textbuf,sizeof textbuf,"SK%u MP%u EN%u FX%u HU%u",scout_render_ms[0],scout_render_ms[1],scout_render_ms[2],scout_render_ms[3],scout_render_ms[4]);label(textbuf,2,193,cYellow);
#endif
#endif
        updateDiagnostics();
        scout_totals[0]++;scout_totals[1]=(unsigned)tick;
        /* 30 FPS cap: frames that finish early wait (still polling keys) so the picture
         * changes at a steady rate instead of swinging between ~30 and ~55 FPS. */
        while ((uint32_t)(timer_GetSafe(1, TIMER_UP) - frameStart) < FRAME_MIN_TICKS) input_poll();
        gfx_SwapDraw(); drawIndex ^= 1; frameStart = timer_GetSafe(1, TIMER_UP);
    }
    save(); gfx_End();
    return 0;
}
