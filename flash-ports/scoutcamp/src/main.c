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
#include "engine.h"
#include "combat.h"
#include "tips.h"

enum { MODE_MENU = 0, MODE_PLAY = 1, MODE_LOST = 3, MODE_WON = 4, MODE_HELP = 5, MODE_SKILLS = 6 };
#define STEP_TICKS (32768 / HZ)
#define KEY_DOWN(k) (kb_Data[(k) >> 8] & ((k) & 0xFF))
#define KEY_PRESS(k) (KEY_DOWN(k) && !(prev[(k) >> 8] & ((k) & 0xFF)))

static uint8_t prev[8];
#ifdef QA_PERF
volatile uint16_t scout_perf[4],scout_render_ms[5];
static uint32_t renderStamp;
static void renderMark(int id){uint32_t n=timer_GetSafe(1,TIMER_UP);scout_render_ms[id]=(n-renderStamp)*1000/32768;renderStamp=n;}
#endif
static bool showTip;
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
/* GraphX does not clip text at the right edge (it wraps into the next scanline), so truncate to fit. */
static void printFit(const char *s, int x, int y) {
    if (y < 0 || y > 232 || x > 315) return;
    if (x < 0) x = 0;
    if (x + (int)gfx_GetStringWidth(s) <= 316) { gfx_PrintStringXY(s, x, y); return; }
    char buffer[96]; int n = 0;
    while (s[n] && n < 90) { buffer[n] = s[n]; buffer[n + 1] = 0; if (x + (int)gfx_GetStringWidth(buffer) > 316) { buffer[n] = 0; break; } n++; }
    gfx_PrintStringXY(buffer, x, y);
}
static void label(const char *s, int x, int y, int color) { gfx_SetTextFGColor(color); printFit(s, x, y); }
static void shadowLabel(const char *s, int x, int y, int color) { label(s, x + 1, y + 1, cBlack); label(s, x, y, color); }
static void centered(const char *s, int y, int color) { shadowLabel(s, (320 - gfx_GetStringWidth(s)) / 2, y, color); }
static void panel(int x, int y, int w, int h) { gfx_SetColor(cPanel); gfx_FillRectangle(x, y, w, h); gfx_SetColor(cWhite); gfx_Rectangle(x, y, w, h); }
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
    if (!flip) { gfx_TransparentSprite(sprite, x, y); return; }
    gfx_FlipSpriteY(sprite, (gfx_sprite_t *)flipBuffer);
    gfx_TransparentSprite((gfx_sprite_t *)flipBuffer, x, y);
}
static int skyFor(int stage) { return stage == 16 ? ART_SKY_CAVEIMAGE_LEFT : stage > 11 ? ART_SKY_DESERTIMAGE_LEFT : stage > 7 ? ART_SKY_CAVEIMAGE_LEFT : stage > 3 ? ART_SKY_SUNSETIMAGE_LEFT : ART_SKY_DESERTIMAGE_LEFT; }
static int xpNeeded(void) { return playerLevel * (playerLevel < 5 ? 50 : 100); }
static void xpBar(int x, int y, int w) {
    gfx_SetColor(cBlack); gfx_FillRectangle(x, y, w, 6);
    gfx_SetColor(cYellow); gfx_FillRectangle(x + 1, y + 1, (w - 2) * xp / xpNeeded(), 4);
    gfx_SetColor(cWhite); gfx_Rectangle(x, y, w, 6);
}

/* ---------- menus ---------- */
static void renderMenu(void) {
    art_background(ART_TITLESTATE_TITLEIMAGE_LEFT);
    panel(12, 146, 296, 92);
    snprintf(textbuf, sizeof textbuf, "<  Stage %u / 17  >", level + 1);
    centered(textbuf, 150, cWhite);
    centered(stageTitles[level], 161, cYellow);
    if (level >= unlocked) centered("LOCKED - win the previous stage", 172, cRed);
    else centered(stageWon[level] ? "CAMP SAVED" : "THE CAMP NEEDS YOU", 172, stageWon[level] ? cGreen : cWhite);
    snprintf(textbuf, sizeof textbuf, "Level %d  Skill points %d", playerLevel, skillPoints);
    label(textbuf, 22, 184, cWhite); xpBar(210, 185, 88);
    label("ENTER play   STAT skills   ALPHA help", 22, 196, cWhite);
    label("LEFT/RIGHT stage            CLEAR quit", 22, 207, cCyan);
    centered("Original game: Hamumu Software, 2012", 224, cYellow);
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
        "+: send the next wave early (bonus)",
        "ALPHA: pause   MODE: back to stages",
        "STAT: skills (on the stage menu)",
        "CLEAR: save and exit",
        "Kill thieves to drop the food they carry;",
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
    label("MODE back", 130, 210, cCyan);
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
        gfx_ScaleSprite(src,dst);gfx_TransparentSprite(dst,x+8-art->width/2,y+16-dst->height);
        drawArt(ART_BUILD,(tick*3/4)%4,x-8+(tick%3)*4,y-7,false);return;
    }
    int frame = 0;
    if (t->animation && art->frames > 2) frame = 2 + (tick / 2) % (art->frames - 2);
    drawArt(id, frame, x + 8 - art->width / 2, y + 16 - art->height, t->facing < 0);
    if(t->buildTime)drawArt(ART_BUILD,(tick*3/4)%4,x-8+(tick%3)*4,y-7,false);
    for (int l = 0; l <= t->level && l < 6; l++) art_draw(ART_UPGRADE, 0, x + (l % 3) * 5, y - 5 - (l / 3) * 5);
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
    art_background(skyFor(level));
#ifdef QA_PERF
    renderMark(0);
#endif
    int theme=level==16?2:level>11?3:level>7?2:level>3?1:0;
    for (int layer = 0; layer < 3; layer++)
        for (int y = camy / 16; y < map->height && y * 16 - camy < 240; y++)
            for (int x = camx / 16; x < map->width && x * 16 - camx < 320; x++) {
                int tile = layers[layer][y * map->width + x];
                if (tile && tile < 128) art_draw(ART_TILES0+theme, tile, x * 16 - camx, y * 16 - camy);
            }
#ifdef QA_PERF
    renderMark(1);
#endif
    int fx = map->camp % map->width * 16 - camx, fy = map->camp / map->width * 16 - camy;
    art_draw(ART_TENT, 0, fx - 20, fy + 6); art_draw(ART_TENT, 0, fx + 20, fy + 6); art_draw(ART_FIRE, tick / 2, fx, fy - 3);
    for (int i = 0; i < 5; i++) {
        const Food *f = &foods[i];
        if (f->active) art_draw(ART_FOOD, i, f->x_pixel - 8 - camx, f->y_pixel - 16 - camy);
    }
    for (int i = 0; i < MAXTOWER; i++) {
        const Tower *t = &towers[i];
        if (t->active) drawTowerArt(t, t->cell % map->width * 16 - camx, t->cell / map->width * 16 - camy);
    }
    for (int i = 0; i < MAXEN; i++) {
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
            dst->width=w;dst->height=h;gfx_ScaleSprite(src,dst);
            if(e->facing<0){gfx_FlipSpriteY(dst,(gfx_sprite_t*)flipBuffer);dst=(gfx_sprite_t*)flipBuffer;}
            gfx_TransparentSprite(dst,x+(art->width-w)/2,y+art->height-h);
        }else drawArt(id,frame,x,y,e->facing<0);
        if (e->hp < e->maxhp) {
            gfx_SetColor(cBlack); gfx_FillRectangle(x, y - 3, art->width, 2);
            gfx_SetColor(cGreen); gfx_FillRectangle(x, y - 3, (uint32_t)art->width * e->hp / e->maxhp + 1, 2);
        }
        int pip = x;
        if (e->freeze) { gfx_SetColor(cCyan); gfx_FillRectangle(pip, y - 6, 3, 2); pip += 4; }
        if (e->slow) { gfx_SetColor(cWhite); gfx_FillRectangle(pip, y - 6, 3, 2); pip += 4; }
        if (e->shock) { gfx_SetColor(cYellow); gfx_FillRectangle(pip, y - 6, 3, 2); pip += 4; }
        if (e->poison) { gfx_SetColor(cGreen); gfx_FillRectangle(pip, y - 6, 3, 2); pip += 4; }
        if (e->crippled || e->disabled) { gfx_SetColor(cRed); gfx_FillRectangle(pip, y - 6, 3, 2); }
        if (e->immune) { gfx_SetColor(cWhite); gfx_Rectangle(x - 1, y - 1, art->width + 2, art->height + 2); }
    }
#ifdef QA_PERF
    renderMark(2);
#endif
    for (int i = 0; i < MAXBULLET; i++) {
        const Bullet *b = &bullets[i]; if (!b->active) continue;
        int bx = b->x_pixel - camx, by = b->y_pixel - camy;
        int id=bulletArt[b->type];const Art*art=&artTable[id];
        static const uint8_t slushFrames[6]={0,1,2,3,2,1};
        int frame=b->pop?b->pop:b->type==SLUSHEE?slushFrames[b->age%6]:0;
        art_draw(id,frame,bx-art->width/2,by-art->height/2);
    }
    for (int i = 0; i < MAXTOWER; i++) {
        const Tower *t = &towers[i];
        if (!t->active || t->born) continue;
        int x = t->cell % map->width * 16 + 8 - camx, y = t->cell / map->width * 16 + 8 - camy;
        if (t->animation && (t->type == SHOCK || t->type == CRIPPLER || t->type == LIGHTNING)) {
            gfx_SetColor(t->type == CRIPPLER ? cRed : cYellow);
            if (t->type == LIGHTNING) gfx_VertLine(x, 0, y); else gfx_Circle(x, y, t->range / 2);
        }
    }
#ifdef QA_PERF
    renderMark(3);
#endif
    int x = cx * 16 - camx, y = cy * 16 - camy;
    int ti = towerAt(cy * map->width + cx);
    if (ti >= 0 && towers[ti].range) { gfx_SetColor(cWhite); gfx_Circle(x + 8, y + 8, towers[ti].range); }
    art_draw(ART_BOX, valid(cx, cy) || ti >= 0 ? 1 : 0, x - 4, y - 4);
    art_draw(ART_CURSOR, (valid(cx, cy) || ti >= 0) ? 1 : 0, x, y);
    art_draw(ART_HUD, 0, 195, 0);
    snprintf(textbuf, sizeof textbuf, "$%d", money); label(textbuf, 267, 23, cWhite);
    snprintf(textbuf, sizeof textbuf, "W%u/%u", wave, waveCounts[level]); label(textbuf, 204, 5, cWhite);
    if (wave < waveCounts[level] && waveDue[wave] > 0) { snprintf(textbuf, sizeof textbuf, "%ds", (waveDue[wave] + HZ - 1) / (sendFast ? HZ * HZ : HZ)); label(textbuf, 204, 23, cYellow); }
    snprintf(textbuf, sizeof textbuf, "FOOD %d", foodLeft()); shadowLabel(textbuf, 3, 3, foodLeft() < 3 ? cRed : cWhite);
    snprintf(textbuf, sizeof textbuf, "LV %d", playerLevel); shadowLabel(textbuf, 3, 13, cWhite); xpBar(33, 14, 50);
    gfx_SetColor(cPanel); gfx_FillRectangle(0, 217, 320, 23);
    if (statusTicks) shadowLabel(status, 3, 219, cYellow);
    else if (ti >= 0) {
        const Tower *t = &towers[ti];
        snprintf(textbuf, sizeof textbuf, "%s L%d  upgrade $%d  sell $%d", towerNames[t->type], t->level + 1, t->level >= 5 ? 0 : upgradeCost((Tower *)t), t->spent / 2);
        label(textbuf, 3, 219, cWhite);
    } else {
        snprintf(textbuf, sizeof textbuf, "%d %s $%d   2nd = build", selection + 1, towerNames[baseTypes[selection]], (int)rule_BasePrice(baseTypes[selection], 0));
        label(textbuf, 3, 219, cWhite);
    }
    if (ti >= 0 && towers[ti].type <= SHOCK) {
        snprintf(textbuf, sizeof textbuf, "MATH %s  APPS %s", towerNames[branchTypes[towers[ti].type][0]], towerNames[branchTypes[towers[ti].type][1]]);
        label(textbuf, 3, 229, cCyan);
    } else label("+ wave  DEL sell  ALPHA pause  MODE menu", 3, 229, cCyan);
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
}

static void beginStage(bool bypass) {
    if (level >= unlocked && !bypass) { say("Locked - win the previous stage first"); return; }
    startLevel(); showTip = true; paused = true; statusTicks = 0;
}
static void updateDiagnostics(void) {
    int count = 0;
    for (int i = 0; i < MAXTOWER; i++) count += towers[i].active;
    scout_diag[0] = mode; scout_diag[1] = level; scout_diag[2] = wave; scout_diag[3] = count; scout_diag[4] = alive(); scout_diag[5] = escaped;
    scout_diag[6] = paused; scout_diag[7] = stageWon[level]; scout_diag[8] = skillPoints; scout_diag[9] = playerLevel; scout_diag[10] = foodLeft(); scout_diag[11] = showTip;
}
static void handleMenu(void) {
    if (KEY_PRESS(kb_KeyLeft)) level = (level + 16) % 17;
    if (KEY_PRESS(kb_KeyRight)) level = (level + 1) % 17;
    if (KEY_PRESS(kb_KeyEnter)) beginStage(KEY_DOWN(kb_KeyVars));
    if (KEY_PRESS(kb_KeyAlpha)) mode = MODE_HELP;
    if (KEY_PRESS(kb_KeyStat)) mode = MODE_SKILLS;
}
static void handleSkills(void) {
    if (KEY_PRESS(kb_KeyLeft)) moveSkill(-1, 0);
    if (KEY_PRESS(kb_KeyRight)) moveSkill(1, 0);
    if (KEY_PRESS(kb_KeyUp)) moveSkill(0, -1);
    if (KEY_PRESS(kb_KeyDown)) moveSkill(0, 1);
    if (KEY_PRESS(kb_KeyEnter)) buySkill();
    if (KEY_PRESS(kb_KeyDel)) resetSkills();
    if (KEY_PRESS(kb_KeyMode)) { mode = MODE_MENU; save(); }
    if (statusTicks) statusTicks--;
}
static void handlePlay(void) {
    static int repeat;
    if (showTip) {
        if (KEY_PRESS(kb_KeyEnter) || KEY_PRESS(kb_KeyAlpha) || KEY_PRESS(kb_Key2nd)) { showTip = false; paused = false; }
        if (KEY_PRESS(kb_KeyMode)) mode = MODE_MENU;
        return;
    }
    if (KEY_PRESS(kb_KeyMode)) { mode = MODE_MENU; return; }
    if (KEY_PRESS(kb_KeyAlpha)) paused = !paused;
    bool move = kb_Data[7] & (kb_Left | kb_Right | kb_Up | kb_Down);
    if (move) {
        if (!repeat || repeat >= 4) {
            if (kb_Data[7] & kb_Left) cx--;
            if (kb_Data[7] & kb_Right) cx++;
            if (kb_Data[7] & kb_Up) cy--;
            if (kb_Data[7] & kb_Down) cy++;
            if (cx < 1) cx = 1;
            if (cx > map->width - 2) cx = map->width - 2;
            if (cy < 1) cy = 1;
            if (cy > map->height - 2) cy = map->height - 2;
            repeat = 1;
        } else repeat++;
    } else repeat = 0;
    if (KEY_DOWN(kb_Key1)) selection = 0;
    if (KEY_DOWN(kb_Key2)) selection = 1;
    if (KEY_DOWN(kb_Key3)) selection = 2;
    if (KEY_DOWN(kb_Key4)) selection = 3;
    if (KEY_PRESS(kb_Key2nd)) build();
    if (KEY_PRESS(kb_KeyEnter)) upgrade();
    if (KEY_PRESS(kb_KeyDel)) sellTower();
    if (KEY_PRESS(kb_KeyMath)) convertTower(0);
    if (KEY_PRESS(kb_KeyApps)) convertTower(1);
    if (KEY_PRESS(kb_KeyAdd)) { if (wave < waveCounts[level]) { sendWave(); say("Wave sent early"); } }
}
static void handleResult(void) {
    if (KEY_PRESS(kb_KeyMode)) mode = MODE_MENU;
    else if (KEY_PRESS(kb_KeyStat)) mode = MODE_SKILLS;
    else if (KEY_PRESS(kb_KeyEnter)) {
        if (mode == MODE_WON && level < 16) level++;
        beginStage(true);
    }
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
    uint32_t last = timer_GetSafe(1, TIMER_UP), accumulator = 0;
    mode = MODE_MENU;
#ifdef QA_PERF
    uint32_t perfStart=last,drawTotal=0,simTotal=0;unsigned frameCount=0;
#endif
    while (1) {
        kb_Scan();
        if (kb_Data[6] & kb_Clear) break;
        uint32_t now = timer_GetSafe(1, TIMER_UP); accumulator += now - last; last = now;
        if (mode == MODE_MENU) handleMenu();
        else if (mode == MODE_HELP) { if (KEY_PRESS(kb_KeyEnter) || KEY_PRESS(kb_KeyMode) || KEY_PRESS(kb_KeyAlpha)) mode = MODE_MENU; }
        else if (mode == MODE_SKILLS) handleSkills();
        else if (mode == MODE_PLAY) {
            handlePlay();
            if (mode == MODE_PLAY && !paused) {
#ifdef QA_PERF
                uint32_t simStart=timer_GetSafe(1,TIMER_UP);
#endif
                int steps = 0;
                while (accumulator >= STEP_TICKS && steps < 6) { update(); accumulator -= STEP_TICKS; steps++; if (mode != MODE_PLAY) break; }
                if (steps == 6 && accumulator > 32768) accumulator = 32768;
#ifdef QA_PERF
                simTotal+=timer_GetSafe(1,TIMER_UP)-simStart;
#endif
            } else accumulator = 0;
        } else handleResult();
        if (mode != MODE_PLAY || paused) accumulator = 0;
#ifdef QA_PERF
        uint32_t drawStart=timer_GetSafe(1,TIMER_UP);
#endif
        if (mode == MODE_MENU) renderMenu();
        else if (mode == MODE_HELP) renderHelp();
        else if (mode == MODE_SKILLS) renderSkills();
        else renderGame();
#ifdef QA_PERF
        drawTotal+=timer_GetSafe(1,TIMER_UP)-drawStart;frameCount++;
        uint32_t perfNow=timer_GetSafe(1,TIMER_UP),span=perfNow-perfStart;
        if(span>=32768){scout_perf[0]=(uint32_t)frameCount*32768/span;scout_perf[1]=drawTotal*1000/span;scout_perf[2]=simTotal*1000/span;scout_perf[3]=accumulator;perfStart=perfNow;drawTotal=simTotal=frameCount=0;}
        snprintf(textbuf,sizeof textbuf,"FPS%u D%u S%u",scout_perf[0],scout_perf[1],scout_perf[2]);label(textbuf,2,204,cYellow);
        snprintf(textbuf,sizeof textbuf,"SK%u MP%u EN%u FX%u HU%u",scout_render_ms[0],scout_render_ms[1],scout_render_ms[2],scout_render_ms[3],scout_render_ms[4]);label(textbuf,2,193,cYellow);
#endif
        updateDiagnostics();
        for (int k = 0; k < 8; k++) prev[k] = kb_Data[k];
        gfx_SwapDraw();
    }
    save(); gfx_End();
    return 0;
}
