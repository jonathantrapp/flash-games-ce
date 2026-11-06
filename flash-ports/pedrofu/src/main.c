/* Pedro Kicks Back CE: input, fixed-step simulation and the main loop. */
#include "game.h"
#include <sys/timers.h>
#include <sys/power.h>
#include "intro.h"

#define STEP_TICKS (32768 / FPS)

/* Native timing counters: frames/s, steps/s, simulation ms, draw ms, mode.
 * Optional profile overlay is a diagnostic build, not the shipped HUD. */
volatile uint32_t pedro_profile[5];

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
    if (intro_is_active() && (g.tap & MENUKEY)) { g.mode=PAUSE;return; }
    if (intro_update()) return;
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
    center_text(70, "PEDRO KICKS BACK CE"); center_text(100, "Game data missing or incompatible.");
    center_text(120, "Replace ALL PD*.8xv from this ZIP."); center_text(160, "Press CLEAR to exit.");
    gfx_SwapDraw();
    do { kb_Scan(); } while (!KEY_DOWN(kb_KeyClear));
}
int main(void) {
    boot_Set48MHzMode();
    ti_CloseAll(); gfx_Begin(); gfx_SetDrawBuffer(); gfx_SetTransparentColor(0); gfx_SetTextTransparentColor(0); gfx_SetTextBGColor(0);
    if (!load_resources()) { missing_resources(); gfx_End(); ti_CloseAll(); return 0; }
    pick_colors(); profile_load();
    g.mode = TITLE; g.level = 0; g.story_event = -1; g.arena = -1; g.carry = -1;
    timer_Set(1, 0); timer_Enable(1, TIMER_32K, TIMER_NOINT, TIMER_UP);
    uint32_t last = timer_GetSafe(1, TIMER_UP), accumulator = 0;
    uint32_t epoch = last, frames = 0, simsteps = 0, simtime = 0, drawtime = 0;
    uint16_t pending_taps = 0;
    uint16_t previous = 0;
    while (1) {
        uint16_t keys = read_keys();
        if (keys & EXITKEY) break;
        pending_taps |= keys & ~previous;
        g.keys = keys; g.tap = pending_taps; previous = keys;
        uint32_t now = timer_GetSafe(1, TIMER_UP); accumulator += now - last; last = now;
        g.frame++;
        uint32_t simstart = timer_GetSafe(1, TIMER_UP);
        if (g.mode == PLAY) {
            int steps = 0;
            while (accumulator >= STEP_TICKS && steps < 4) {
                game_step(); g.tap = 0; pending_taps = 0; accumulator -= STEP_TICKS; steps++; simsteps++;
                if (g.mode != PLAY) break;
            }
            if (steps == 4) accumulator = 0;
        } else if (g.mode == DIALOGUE) {
            story_update(); pending_taps = 0; accumulator = 0; if (g.mode == DIALOGUE) g.ticks++;
        } else { frontend_update(); pending_taps = 0; accumulator = 0; }
        uint32_t drawstart = timer_GetSafe(1, TIMER_UP);
        simtime += drawstart - simstart;
        if (g.mode == TITLE || g.mode == HELP || g.mode == MAP || g.mode == SKILLS || g.mode == ENDING) draw_frontend();
        else { draw_game(); if (g.mode != PLAY && g.mode != DIALOGUE) draw_frontend(); }
        drawtime += timer_GetSafe(1, TIMER_UP) - drawstart;
        frames++;
        if (now - epoch >= 32768) {
            uint32_t elapsed = now - epoch;
            pedro_profile[0] = frames * 32768 / elapsed;
            pedro_profile[1] = simsteps * 32768 / elapsed;
            pedro_profile[2] = simtime * 1000 / elapsed;
            pedro_profile[3] = drawtime * 1000 / elapsed;
            pedro_profile[4] = g.mode;
            epoch = now; frames = simsteps = simtime = drawtime = 0;
        }
#ifdef PEDRO_PROFILE
        extern volatile uint32_t pedro_draw_profile[6];
        {char timing[64]; snprintf(timing, sizeof timing, "FPS%lu STEP%lu SIM%lu DRAW%lu", pedro_profile[0], pedro_profile[1], pedro_profile[2], pedro_profile[3]);
        gfx_SetColor(cBlack); gfx_FillRectangle(0, 32, 320, 20); gfx_SetTextFGColor(cWhite); print_fit(timing, 2, 33);
        snprintf(timing, sizeof timing, "SK%lu MAP%lu ACT%lu DEC%lu HUD%lu",pedro_draw_profile[0]/33,pedro_draw_profile[1]/33,pedro_draw_profile[2]/33,pedro_draw_profile[3]/33,pedro_draw_profile[4]/33);print_fit(timing,2,43);}
#endif
        update_diagnostics();
        gfx_SwapDraw();
    }
    profile_save(); gfx_End();
    /* Archive only after rendering has stopped: flash garbage collection may
     * move resource banks, so retain RAM saves while their pointers are used. */
    {uint8_t save=ti_Open("PDPROG2","r");if(save){ti_SetArchiveStatus(true,save);ti_Close(save);}}
    ti_CloseAll();
    return 0;
}
