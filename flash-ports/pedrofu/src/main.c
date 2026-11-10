/* Pedro Kicks Back CE: input, fixed-step simulation and the main loop. */
#include "game.h"
#include <sys/timers.h>
#include <sys/power.h>
#include "intro.h"
#include "render_cache.h"
#include "hwdiag.h"
#include "sky_runtime.h"

#define STEP_TICKS (32768 / FPS)

/* Native timing counters: frames/s, steps/s, simulation ms, draw ms, mode.
 * Optional profile overlay is a diagnostic build, not the shipped HUD. */
volatile uint32_t pedro_profile[6];
/* Cumulative counters permit paired-interval measurements without an overlay. */
volatile uint32_t pedro_totals[5];
#ifdef PEDRO_STEPHIST
volatile uint32_t pedro_step_hist[6]; /* PLAY-mode iterations that ran 0..4 simulation steps; [5] = iterations with left/right held */
#endif
#if defined(PEDRO_PROFILE)||defined(PEDRO_PATHSTAT)
volatile uint32_t pedro_path_cnt[4],pedro_path_period[4],pedro_path_slow[4],pedro_path_over[4],pedro_path_draw[4],pedro_path_n[4];
#endif /* frames, steps, wait ticks, draw ticks, sim ticks */

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
    DIAG_SUB(DS_INTRO);
    if (intro_update()) return;
    DIAG_SUB(DS_STORY);
    story_triggers();
    if (g.mode != PLAY) return;
    DIAG_SUB(DS_PLAYER);
    player_update();
    if (g.mode != PLAY) return;
    DIAG_SUB(DS_ENEMY);
    enemy_update();
    if (g.mode != PLAY) return;
    DIAG_SUB(DS_SHOT);
    projectile_update();
    DIAG_SUB(DS_PROP);
    prop_update();
    DIAG_SUB(DS_ARENA);
    arena_update();
    DIAG_SUB(DS_NONE);
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
    cache_hud(); pick_colors(); profile_load(); sky_runtime_start(); diag_start();
    g.mode = TITLE; g.level = 0; g.story_event = -1; g.arena = -1; g.carry = -1;
    timer_Set(1, 0); timer_Enable(1, TIMER_32K, TIMER_NOINT, TIMER_UP);
    uint32_t last = timer_GetSafe(1, TIMER_UP), accumulator = 0;
    uint32_t epoch = last, frames = 0, simsteps = 0, simtime = 0, drawtime = 0, waittime = 0;
    uint16_t pending_taps = 0;
    uint16_t previous = 0;
    while (1) {
        DIAG_PHASE(DP_INPUT);
        uint16_t keys = read_keys();
        if (keys & EXITKEY) break;
        pending_taps |= keys & ~previous;
        g.keys = keys; g.tap = pending_taps; previous = keys;
        uint32_t now = timer_GetSafe(1, TIMER_UP); accumulator += now - last; last = now;
        g.frame++;
        uint32_t simstart = timer_GetSafe(1, TIMER_UP);
        DIAG_PHASE(DP_SIM);
        if (g.mode == PLAY) {
            int steps = 0;
            while (accumulator >= STEP_TICKS && steps < 4) {
                game_step(); g.tap = 0; pending_taps = 0; accumulator -= STEP_TICKS; steps++; simsteps++;
                if (g.mode != PLAY) break;
            }
            if (steps == 4) accumulator = 0;
#ifdef PEDRO_STEPHIST
            pedro_step_hist[steps]++;if(keys&(LEFT|RIGHT))pedro_step_hist[5]++;
#endif
        } else if (g.mode == DIALOGUE) {
            DIAG_PHASE(DP_FRONTEND);
            story_update(); pending_taps = 0; accumulator = 0; if (g.mode == DIALOGUE) g.ticks++;
        } else { DIAG_PHASE(DP_FRONTEND); frontend_update(); pending_taps = 0; accumulator = 0; }
        uint32_t waitstart = timer_GetSafe(1, TIMER_UP);
        simtime += waitstart - simstart;pedro_totals[4]+=waitstart-simstart;
        DIAG_PHASE(DP_WAIT);
        gfx_Wait();
        DIAG_PHASE(DP_DRAW);
        uint32_t drawstart = timer_GetSafe(1, TIMER_UP);
        waittime += drawstart-waitstart;pedro_totals[2]+=drawstart-waitstart;
#ifdef PEDRO_PROFILE
        extern volatile uint32_t pedro_draw_profile[6];
        pedro_draw_profile[5]=drawstart-waitstart;
#endif
#if defined(PEDRO_PROFILE)||defined(PEDRO_PATHSTAT)
        {extern volatile uint8_t pedro_last_path;static uint32_t lastdraw;
         uint32_t period=drawstart-lastdraw;lastdraw=drawstart;uint8_t path=pedro_last_path&3; /* the draw inside this period */
         pedro_path_cnt[path]++;pedro_path_period[path]+=period;if(period>1130)pedro_path_slow[path]++;
         if(period>1130)pedro_path_over[path]+=period-1092;}
#endif
        if (g.mode == TITLE || g.mode == HELP || g.mode == MAP || g.mode == SKILLS || g.mode == ENDING) {invalidate_scene_cache();draw_frontend();}
        else { draw_game(); if (g.mode != PLAY && g.mode != DIALOGUE) draw_frontend(); }
        uint32_t drawn=timer_GetSafe(1, TIMER_UP)-drawstart;
        drawtime += drawn;pedro_totals[3]+=drawn;
#if defined(PEDRO_PROFILE)||defined(PEDRO_PATHSTAT)
        {extern volatile uint8_t pedro_last_path;uint8_t path=pedro_last_path&3;pedro_path_n[path]++;pedro_path_draw[path]+=drawn;}
#endif
        frames++;pedro_totals[0]++;pedro_totals[1]=g.ticks;
        if (now - epoch >= 32768) {
            uint32_t elapsed = now - epoch;
            pedro_profile[0] = frames * 32768 / elapsed;
            pedro_profile[1] = simsteps * 32768 / elapsed;
            pedro_profile[2] = simtime * 1000 / elapsed;
            pedro_profile[3] = drawtime * 1000 / elapsed;
            pedro_profile[4] = g.mode;
            pedro_profile[5] = waittime * 1000 / elapsed;
            epoch = now; frames = simsteps = simtime = drawtime = waittime = 0;
        }
#ifdef PEDRO_OVERLAY
        extern volatile uint32_t pedro_draw_profile[6];
        {char timing[64]; snprintf(timing, sizeof timing, "FPS%lu STEP%lu SIM%lu DRAW%lu", pedro_profile[0], pedro_profile[1], pedro_profile[2], pedro_profile[3]);
        gfx_SetColor(cBlack); gfx_FillRectangle(0, 32, 320, 20); gfx_SetTextFGColor(cWhite); print_fit(timing, 2, 33);
        snprintf(timing, sizeof timing, "SK%lu MAP%lu ACT%lu DEC%lu HUD%lu",pedro_draw_profile[0]/33,pedro_draw_profile[1]/33,pedro_draw_profile[2]/33,pedro_draw_profile[3]/33,pedro_draw_profile[4]/33);print_fit(timing,2,43);}
#endif
        update_diagnostics();
        diag_frame();
        DIAG_PHASE(DP_SWAP);
        gfx_SwapDraw();
    }
    profile_save(); sky_runtime_stop(); gfx_End();
    /* Archive only after rendering has stopped: flash garbage collection may
     * move resource banks, so retain RAM saves while their pointers are used. */
    {uint8_t save=ti_Open("PDPROG2","r");if(save){ti_SetArchiveStatus(true,save);ti_Close(save);}}
    ti_CloseAll();
    return 0;
}
