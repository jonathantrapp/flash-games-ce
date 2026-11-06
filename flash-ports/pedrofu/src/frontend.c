/* Title, stage map, skill, pause, result and ending screens. */
#include "game.h"

static const int map_x[15] = {42, 93, 139, 174, 209, 247, 286, 280, 234, 189, 142, 95, 58, 42, 62};
static const int map_y[15] = {100, 110, 100, 87, 75, 103, 136, 175, 186, 198, 192, 198, 190, 169, 147};
static int menu_selection, skill_cursor;
static char text[64];

static void panel(int x, int y, int w, int h) { gfx_SetColor(cPanel); gfx_FillRectangle(x, y, w, h); gfx_SetColor(cWhite); gfx_Rectangle(x, y, w, h); }
static void shadow(const char *s, int x, int y, int color) { gfx_SetTextFGColor(cBlack); print_fit(s, x + 1, y + 1); gfx_SetTextFGColor(color); print_fit(s, x, y); }
static void centered(int y, const char *s, int color) { int w = gfx_GetStringWidth(s); shadow(s, w >= 316 ? 2 : (320 - w) / 2, y, color); }
static int available_levels(void) { int n = levels_passed(); return n > 14 ? 14 : n; }
static void start_stage(int level) { if (load_level(level)) g.previousmode = MAP; }

/* ---- skill screen geometry follows the original SkillState ---- */
static int skill_x(int id) { int group = skillgrid[id][0], rank = skillgrid[id][1], col = skillgrid[id][2]; return 27 + group * 103 + col * 23 + (group > 1) + (rank > 0 && rank < 4) - (rank == 4); }
static int skill_y(int id) { return 36 + skillgrid[id][1] * 23; }
static int skill_state(int id) { return !progress.have[id] ? -1 : skill_need(id) > 0 ? 0 : 1; }
static void move_skill(int dx, int dy) {
    int best = -1, best_score = 0x7fffff;
    for (int i = 0; i < 45; i++) {
        if (i == skill_cursor) continue;
        int ddx = skill_x(i) - skill_x(skill_cursor), ddy = skill_y(i) - skill_y(skill_cursor);
        if (dx && ddx * dx <= 0) continue;
        if (dy && ddy * dy <= 0) continue;
        int score = dx ? absi(ddx) + absi(ddy) * 3 : absi(ddy) + absi(ddx) * 3;
        if (score < best_score) { best_score = score; best = i; }
    }
    if (best >= 0) skill_cursor = best;
}
static void draw_skills(void) {
    gfx_Sprite((gfx_sprite_t *)uidata[2][0], 0, 0); gfx_Sprite((gfx_sprite_t *)uidata[2][1], 160, 0);
    centered(1, "SKILLS", cWhite);
    snprintf(text, sizeof text, "Points left: %d", progress.points); shadow(text, 4, 12, cWhite);
    snprintf(text, sizeof text, "Level %d", progress.rank + 1); shadow(text, 250, 12, cWhite);
    for (int group = 0; group < 3; group++) draw_ui(UI_SKB, 0, 11 + group * 103, 26);
    for (int id = 0; id < 45; id++) {
        int x = skill_x(id), y = skill_y(id), state = skill_state(id), group = skillgrid[id][0];
        if (state > 0) draw_ui(UI_SKF, 0, x - 3, y - 3);
        draw_ui(UI_SKI, state < 0 ? 6 : group + (state == 0 ? 3 : 0), x, y);
        if (state > 0) { draw_ui(UI_SKT, 0, x, y + 15); for (int k = 0; k < progress.skills[id]; k++) draw_ui(UI_SKP, group, x + 1 + k * 3, y + 16); }
    }
    gfx_SetColor(cYellow); gfx_Rectangle(skill_x(skill_cursor) - 4, skill_y(skill_cursor) - 4, 24, 24); gfx_Rectangle(skill_x(skill_cursor) - 5, skill_y(skill_cursor) - 5, 26, 26);
    panel(4, 168, 312, 44);
    int state = skill_state(skill_cursor);
    if (state < 0) centered(173, "Find an Ancient Technique first", cWhite);
    else {
        snprintf(text, sizeof text, "%s   rank %d / 5", skillnames[skill_cursor], progress.skills[skill_cursor]); centered(173, text, cYellow);
        int need = skill_need(skill_cursor);
        if (need > 0) snprintf(text, sizeof text, "Needs %d more points in earlier ranks", need); else snprintf(text, sizeof text, "ENTER learns   DEL unlearns one rank");
        centered(187, text, cWhite);
    }
    centered(218, "Arrows move   MODE back", cCyan);
    if (g.notice_timer && g.notice) centered(230, g.notice, cWhite);
}

/* ---- frontend update ---- */
void frontend_update(void) {
    int tap = g.tap;
    switch (g.mode) {
    case TITLE:
        if (tap & ACCEPT) { g.mode = MAP; menu_selection = available_levels(); }
        else if (tap & HITKEY) g.mode = HELP;
        break;
    case HELP:
        if (tap & (ACCEPT | MENUKEY | HITKEY)) g.mode = TITLE;
        break;
    case MAP: {
        int top = (g.keys & QAKEY) ? 14 : available_levels();
        if (menu_selection > top) menu_selection = top;
        if (tap & (LEFT | UP)) menu_selection = menu_selection ? menu_selection - 1 : top;
        if (tap & (RIGHT | DOWN)) menu_selection = menu_selection < top ? menu_selection + 1 : 0;
        if (tap & ACCEPT) start_stage(menu_selection);
        if (tap & SKILLKEY) { g.mode = SKILLS; g.previousmode = MAP; }
        if (tap & MENUKEY) g.mode = TITLE;
        break; }
    case SKILLS:
        if (tap & LEFT) move_skill(-1, 0);
        if (tap & RIGHT) move_skill(1, 0);
        if (tap & UP) move_skill(0, -1);
        if (tap & DOWN) move_skill(0, 1);
        if (tap & ACCEPT) { if (skill_adjust(skill_cursor, 1)) notice("Skill learned"); else notice(progress.have[skill_cursor] ? (progress.points ? "Spend points in earlier ranks first" : "No skill points - gain levels") : "Not discovered yet"); }
        if (tap & (FURYKEY | MINUSKEY)) { if (skill_adjust(skill_cursor, -1)) notice("Rank refunded"); }
        if (tap & MENUKEY) g.mode = g.previousmode == PAUSE ? PAUSE : MAP;
        if (g.notice_timer) g.notice_timer--;
        break;
    case PAUSE:
        if (tap & ACCEPT) g.mode = PLAY;
        if (tap & MENUKEY) { g.mode = MAP; menu_selection = g.level; }
        if (tap & SKILLKEY) { g.mode = SKILLS; g.previousmode = PAUSE; }
        break;
    case DEFEAT:
        if (tap & ACCEPT) start_stage(g.level);
        if (tap & MENUKEY) { g.mode = MAP; menu_selection = g.level; }
        break;
    case VICTORY:
        if (tap & ACCEPT) { int next = g.level + 1; if (next > 14) next = 14; menu_selection = next; start_stage(next); }
        if (tap & MENUKEY) { g.mode = MAP; menu_selection = available_levels(); }
        if (tap & SKILLKEY) { g.mode = SKILLS; g.previousmode = MAP; }
        break;
    case ENDING:
        if (tap & (ACCEPT | MENUKEY)) g.mode = TITLE;
        break;
    }
}

/* ---- frontend drawing ---- */
void draw_frontend(void) {
    switch (g.mode) {
    case TITLE:
        gfx_Sprite((gfx_sprite_t *)uidata[0][0], 0, 0); gfx_Sprite((gfx_sprite_t *)uidata[0][1], 160, 0);
        shadow("v3 checkpoint",4,4,cWhite);
        panel(70, 193, 180, 36);
        centered(197, "ENTER  Play game", cWhite); centered(207, "ALPHA  Controls", cWhite); centered(217, "CLEAR  Quit", cCyan);
        shadow("Game copyright 2012, Hamumu Software", 60, 231, cWhite);
        break;
    case HELP:
        gfx_FillScreen(cPanel);
        centered(4, "PEDRO KICKS BACK - CONTROLS", cYellow);
        gfx_SetTextFGColor(cWhite);
        wrap_text(8, 20, 304,
                  "Arrows: run; hold Down to duck; double-tap a direction for Burro Bash.\n"
                  "Up or 2nd: jump.\n"
                  "Alpha: punch; in the air, kick; duck + Alpha: Pedroken; Down in the air: dive kick; hold Alpha after a Burro Bash hit to grab.\n"
                  "Del: Fury. With a full bar, hold Del and press Down (blast), Left (freeze), Right (frenzy) or Up (fix).\n"
                  "MODE: pause. STAT: skills. CLEAR: save and quit.\n"
                  "Collect all the lost mail to finish a stage. Find Ancient Techniques, hearts and Fury Souls; level up for skill points.",
                  11);
        centered(204, "Original game: Hamumu Software, 2012", cYellow);
        centered(224, "ENTER returns", cCyan);
        break;
    case MAP: {
        gfx_Sprite((gfx_sprite_t *)uidata[1][0], 0, 0); gfx_Sprite((gfx_sprite_t *)uidata[1][1], 160, 0);
        int top = available_levels(), blink = (g.frame / 8) & 1;
        for (int i = 0; i < 15; i++) {
            int x = map_x[i], y = map_y[i];
            gfx_SetColor(progress.passed[i] ? cGreen : i <= top ? (blink ? cYellow : cGold) : cPanel);
            gfx_FillRectangle(x - 3, y - 3, 7, 7); gfx_SetColor(cBlack); gfx_Rectangle(x - 3, y - 3, 7, 7);
        }
        gfx_SetColor(cWhite); gfx_Rectangle(map_x[menu_selection] - 6, map_y[menu_selection] - 6, 13, 13);
        panel(40, 4, 240, 38);
        snprintf(text, sizeof text, "Stage %d / 15", menu_selection + 1); centered(8, text, cYellow);
        if (progress.best[menu_selection]) snprintf(text, sizeof text, "Best time %d s", (int)(progress.best[menu_selection] / FPS)); else snprintf(text, sizeof text, progress.passed[menu_selection] ? "Delivered" : "Mail still undelivered");
        centered(20, text, cWhite);
        snprintf(text, sizeof text, "Level %d   points %d   life %d   fury %d", progress.rank + 1, progress.points, maxlife() / 100, maxfury() / 100); shadow(text, 8, 214, cWhite);
        shadow("ENTER play   STAT skills   MODE title", 8, 228, cCyan);
        break; }
    case SKILLS: draw_skills(); break;
    case PAUSE: panel(60, 80, 200, 70); centered(86, "PAUSED", cYellow); centered(104, "ENTER resume", cWhite); centered(116, "STAT skills", cWhite); centered(128, "MODE back to the map", cWhite); break;
    case DEFEAT: panel(50, 80, 220, 66); centered(86, "PEDRO WAS DEFEATED", cRed); centered(106, "ENTER try again", cWhite); centered(120, "MODE back to the map", cCyan); break;
    case VICTORY:
        panel(40, 66, 240, 100); centered(72, "MAIL DELIVERED!", cGreen);
        snprintf(text, sizeof text, "Time %d s   Level %d   points %d", (int)(g.ticks / FPS), progress.rank + 1, progress.points); centered(92, text, cWhite);
        centered(112, "ENTER next stage", cWhite); centered(126, "STAT skills   MODE map", cCyan);
        break;
    case ENDING:
        gfx_FillScreen(cPanel); centered(6, "YOU WIN!", cYellow);
        gfx_SetTextFGColor(cWhite);
        wrap_text(14, 48, 292, "And so Pedro defeated the Yak Clan and recovered every last fan letter.\n\nBut with the Boys' Life Mail Blimp destroyed, Pedro had no way to get back home from the Himalayas.\n\n...Well, that's a story for another day!", 12);
        centered(214, "ENTER returns to the title", cCyan);
        break;
    default: break;
    }
}
