/* Pedro Kicks Back CE: input, fixed-step simulation and the main loop. */
#include "game.h"
#include <sys/timers.h>

#define STEP_TICKS (32768 / FPS)

#define KEY_DOWN(k) (kb_Data[(k) >> 8] & ((k) & 0xFF))
static uint16_t read_keys(void) {
    uint16_t k = 0;
    kb_Scan();
    if (KEY_DOWN(kb_KeyLeft)) k |= LEFT;
    if (KEY_DOWN(kb_KeyRight)) k |= RIGHT;
    if (KEY_DOWN(kb_KeyUp)) k |= UP;
    if (KEY_DOWN(kb_KeyDown)) k |= DOWN;
    if (KEY_DOWN(kb_Key2nd)) k |= JUMPKEY;
    if (KEY_DOWN(kb_KeyAlpha)) k |= HITKEY;
    if (KEY_DOWN(kb_KeyDel)) k |= FURYKEY;
    if (KEY_DOWN(kb_KeyEnter)) k |= ACCEPT;
    if (KEY_DOWN(kb_KeyMode)) k |= MENUKEY;
    if (KEY_DOWN(kb_KeyClear)) k |= EXITKEY;
    if (KEY_DOWN(kb_KeyStat)) k |= SKILLKEY;
    if (KEY_DOWN(kb_KeySub)) k |= MINUSKEY;
    if (KEY_DOWN(kb_KeyVars)) k |= QAKEY; /* QA only: hold VARS on the map to open any stage */
    return k;
}
void game_step(void) {
    g.ticks++;
    if (g.notice_timer) g.notice_timer--;
    story_triggers();
    if (g.mode != PLAY) return;
    player_update();
    if (g.mode != PLAY) return;
    enemy_update();
    if (g.mode != PLAY) return;
    projectile_update();
    prop_update();
    arena_update();
    if (g.mode == VICTORY && g.level == 14) g.mode = ENDING;
}
static void update_diagnostics(void) {
    int alive = 0;
    for (int i = 0; i < g.enemies; i++) alive += g.enemy[i].active;
    pedro_diag[0] = g.mode; pedro_diag[1] = g.level; pedro_diag[2] = g.hp / 100; pedro_diag[3] = g.mailleft;
    pedro_diag[4] = progress.points; pedro_diag[5] = alive; pedro_diag[6] = g.px / 16 / 16; pedro_diag[7] = progress.rank;
}
static void missing_resources(void) {
    gfx_FillScreen(1); gfx_SetTextFGColor(255);
    center_text(70, "PEDRO KICKS BACK CE"); center_text(100, "Missing game data AppVars.");
    center_text(120, "Send every PD*.8xv file."); center_text(160, "Press CLEAR to exit.");
    gfx_SwapDraw();
    do { kb_Scan(); } while (!KEY_DOWN(kb_KeyClear));
}
int main(void) {
    ti_CloseAll(); gfx_Begin(); gfx_SetDrawBuffer(); gfx_SetTransparentColor(0); gfx_SetTextTransparentColor(0); gfx_SetTextBGColor(0);
    if (!load_resources()) { missing_resources(); gfx_End(); ti_CloseAll(); return 0; }
    pick_colors(); profile_load();
    g.mode = TITLE; g.level = 0; g.story_event = -1; g.arena = -1; g.carry = -1;
    timer_Set(1, 0); timer_Enable(1, TIMER_32K, TIMER_NOINT, TIMER_UP);
    uint32_t last = timer_GetSafe(1, TIMER_UP), accumulator = 0;
    uint16_t previous = 0;
    while (1) {
        uint16_t keys = read_keys();
        if (keys & EXITKEY) break;
        g.keys = keys; g.tap = keys & ~previous; previous = keys;
        uint32_t now = timer_GetSafe(1, TIMER_UP); accumulator += now - last; last = now;
        g.frame++;
        if (g.mode == PLAY) {
            int steps = 0;
            while (accumulator >= STEP_TICKS && steps < 4) {
                game_step(); g.tap = 0; accumulator -= STEP_TICKS; steps++;
                if (g.mode != PLAY) break;
            }
            if (steps == 4) accumulator = 0;
        } else if (g.mode == DIALOGUE) {
            story_update(); accumulator = 0; if (g.mode == DIALOGUE) g.ticks++;
        } else { frontend_update(); accumulator = 0; }
        if (g.mode == TITLE || g.mode == HELP || g.mode == MAP || g.mode == SKILLS || g.mode == ENDING) draw_frontend();
        else { draw_game(); if (g.mode != PLAY && g.mode != DIALOGUE) draw_frontend(); }
        update_diagnostics();
        gfx_SwapDraw();
    }
    profile_save(); gfx_End(); ti_CloseAll();
    return 0;
}
