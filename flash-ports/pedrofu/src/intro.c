/* Opening sequence ported from Monster/Blimp.as and PedroChute.as.
 *
 * Intro-only coordinates use Q8 pixels, independently of the gameplay engine's
 * Q4 coordinates. All motion and animation rates derive from FPS, so changing
 * the simulation cadence does not change the cinematic's duration.
 */
#include "game.h"
#include "intro.h"

#define Q8 256
#define FIRE_COUNT 48
#define BOOM_COUNT 12
#define BLIMP_HALF_BYTES (2 + 160 * 62)
#define BOOM_FRAME_BYTES (2 + 32 * 32)

typedef struct {
    int x, y;                 /* Q8 world pixels */
    int vy;                   /* Q8 pixels per second */
    unsigned age;             /* simulation ticks */
    uint8_t scale;            /* initial scale, units of 1/64 */
    bool active;
} IntroFire;

typedef struct {
    int x, y;                 /* world pixels, centre */
    unsigned age;
    bool active;
} IntroBoom;

typedef struct {
    int bx, by, chute_x, chute_y;
    int swing_angle, swing_velocity; /* degrees * 256, degrees/sec * 256 */
    int fire_spawn_remainder;
    uint32_t ticks;
    unsigned chute_age, collapse_age;
    uint8_t phase;
    bool blimp_alive;
    IntroFire fire[FIRE_COUNT];
    IntroBoom boom[BOOM_COUNT];
} IntroState;

static IntroState intro;
static const uint8_t *blimp_half[2], *boom_art;
/* GraphX's rotate routine requires square inputs. Pad the 31x39 parachute
 * artwork to 39x39 rather than passing an unsafe non-square sprite to it.
 */
static uint8_t chute_square[2 + 39 * 39];

static const uint8_t *intro_resource(const char *name, unsigned minimum) {
    unsigned size = 0;
    const uint8_t *p = bundle_find(name, &size);
    return p && size >= minimum ? p : NULL;
}

void intro_cancel(void) {
    intro.phase = 0;
    intro.blimp_alive = false;
}

void intro_start(void) {
    memset(&intro, 0, sizeof intro);
    /* BaseGuy.Reset: x=tx*16+8-width/2, y=ty*16+16-height.
     * Blimp.Init additionally subtracts 123 from y.
     */
    intro.bx = -312 * Q8;
    intro.by = -121 * Q8;
    intro.phase = 1;
    intro.blimp_alive = true;
    blimp_half[0] = intro_resource("PDBLIMP0", BLIMP_HALF_BYTES);
    blimp_half[1] = intro_resource("PDBLIMP1", BLIMP_HALF_BYTES);
    boom_art = intro_resource("PDBOOM", BOOM_FRAME_BYTES * 14);
    chute_square[0] = chute_square[1] = 39;
    memset(chute_square + 2, 0, 39 * 39);
    if (artdata[59]) {
        const uint8_t *source = artdata[59] + 2;
        for (int row = 0; row < 39; row++) {
            memcpy(chute_square + 2 + row * 39 + 4, source + row * 31, 31);
        }
    }
    g.action = PA_INACTIVE;
    g.vx = g.vy = 0;
}

bool intro_is_active(void) { return intro.phase != 0; }
uint8_t intro_phase(void) { return intro.phase; }
uint32_t intro_tick_count(void) { return intro.ticks; }

void intro_camera(int *x, int *y) {
    int target_x, target_y;
    if (intro.phase == 1) {
        /* Lock-on camera follows the 320x62 blimp's centre. */
        target_x = intro.bx / Q8;
        target_y = intro.by / Q8 + 31 - 120;
    } else {
        target_x = intro.chute_x / Q8 + 5 - 160;
        target_y = intro.chute_y / Q8 + 19 - 120;
    }
    int maxx = (int)g.w * 16 - 320, maxy = (int)g.h * 16 - 240;
    *x = clampi(target_x, 0, maxx < 0 ? 0 : maxx);
    *y = clampi(target_y, 0, maxy < 0 ? 0 : maxy);
}

static void spawn_fire(void) {
    for (unsigned i = 0; i < FIRE_COUNT; i++) {
        IntroFire *p = &intro.fire[i];
        if (p->active) continue;
        p->x = intro.bx + (103 + rand() % 99 - 3) * Q8;
        p->y = intro.by + (20 + rand() % 40 - 3) * Q8;
        p->vy = 0;
        p->age = 0;
        p->scale = 64 + rand() % 129; /* original random scale 1..3 */
        p->active = true;
        return;
    }
}

static void spawn_boom(void) {
    for (unsigned i = 0; i < BOOM_COUNT; i++) {
        IntroBoom *p = &intro.boom[i];
        if (p->active) continue;
        p->x = intro.bx / Q8 + 103 + rand() % 99;
        p->y = intro.by / Q8 + 20 + rand() % 40;
        p->age = 0;
        p->active = true;
        return;
    }
}

static void update_effects(void) {
    for (unsigned i = 0; i < FIRE_COUNT; i++) {
        IntroFire *p = &intro.fire[i];
        if (!p->active) continue;
        p->age++;
        p->x -= 80 * Q8 / FPS;
        p->vy += 150 * Q8 / FPS;
        p->y += p->vy / FPS;
        /* FireBit's crazy flag shrinks at 4 scale units/sec. */
        if ((unsigned)p->scale <= p->age * 256 / FPS) p->active = false;
    }
    for (unsigned i = 0; i < BOOM_COUNT; i++) {
        IntroBoom *p = &intro.boom[i];
        if (p->active && ++p->age * 20 >= FPS * 14) p->active = false;
    }
}

static void start_parachute(void) {
    intro.phase = 2;
    /* tx=24,ty=1; physical body width=11,height=38. */
    intro.chute_x = 386 * Q8 + Q8 / 2;
    intro.chute_y = -6 * Q8;
    intro.chute_age = 0;
    intro.swing_angle = 15 * Q8;
    intro.swing_velocity = 0;
}

static void finish_parachute(void) {
    g.px = intro.chute_x / (Q8 / 16);
    g.py = (intro.chute_y + 23 * Q8) / (Q8 / 16);
    g.safex = g.px;
    g.safey = g.py;
    g.vx = g.vy = 0;
    g.face = 1;
    g.action = PA_IDLE;
    g.ground = 1;
    intro_cancel();
    /* This is deliberately after the landing/collapse animation. */
    story_start(1, -1);
}

bool intro_update(void) {
    if (!intro_is_active()) return false;
    intro.ticks++;
    update_effects();

    if (intro.blimp_alive) {
        intro.bx += 60 * Q8 / FPS;
        intro.by += 15 * Q8 / FPS;
        if (intro.by >= 0) intro.by = 0;
        int camera_x, camera_y;
        intro_camera(&camera_x, &camera_y);
        (void)camera_y;
        if (intro.bx / Q8 > camera_x + 320) intro.blimp_alive = false;
        else {
            /* Original SWF emits once per 60Hz update. Keep that density if
             * native simulation is configured at a different fixed cadence.
             */
            intro.fire_spawn_remainder += 60;
            while (intro.fire_spawn_remainder >= FPS) {
                intro.fire_spawn_remainder -= FPS;
                spawn_fire();
            }
            if (rand() % FPS < 5) spawn_boom();
            if (intro.phase == 1 && intro.bx > 224 * Q8) start_parachute();
        }
    }

    if (intro.phase == 2) {
        intro.chute_age++;
        /* PedroChute oscillates under angular acceleration +/-40deg/sec^2. */
        if (intro.swing_angle > 0) intro.swing_velocity -= 40 * Q8 / FPS;
        else if (intro.swing_angle < 0) intro.swing_velocity += 40 * Q8 / FPS;
        intro.swing_angle += intro.swing_velocity / FPS;
        if (intro.chute_age < FPS) {
            /* Original collision grace period is exactly one second. */
            intro.chute_x -= 60 * Q8 / FPS;
            intro.chute_y += 60 * Q8 / FPS;
        } else {
            int x = intro.chute_x / (Q8 / 16);
            int y = intro.chute_y / (Q8 / 16);
            int velocity_y = 60 * 16 / FPS;
            int floor = 0;
            move_body(&x, &y, &velocity_y, -60 * 16 / FPS, 11, 38, &floor);
            intro.chute_x = x * (Q8 / 16);
            intro.chute_y = y * (Q8 / 16);
            if (floor) {
                intro.phase = 3;
                intro.collapse_age = 0;
            }
        }
    } else if (intro.phase == 3) {
        intro.collapse_age++;
        intro.swing_angle = intro.swing_angle * 4 / 5;
        if (intro.collapse_age * 10 >= FPS * 4) finish_parachute();
    }
    return true;
}

void intro_draw(int camera_x, int camera_y) {
    if (!intro_is_active()) return;
    /* Every call below uses clipping-capable GraphX routines. In particular,
     * the blimp must be safe when entering/leaving either screen edge.
     */
    if (intro.blimp_alive) {
        int x = intro.bx / Q8 - camera_x, y = intro.by / Q8 - camera_y;
        if (blimp_half[0]) gfx_TransparentSprite((gfx_sprite_t *)blimp_half[0], x, y);
        if (blimp_half[1]) gfx_TransparentSprite((gfx_sprite_t *)blimp_half[1], x + 160, y);
    }
    for (unsigned i = 0; i < FIRE_COUNT; i++) {
        const IntroFire *p = &intro.fire[i];
        if (!p->active || !artdata[55]) continue;
        int scale = (int)p->scale - (int)(p->age * 256 / FPS);
        if (scale <= 0) continue;
        gfx_RotatedScaledTransparentSprite((gfx_sprite_t *)artdata[55],
            p->x / Q8 - camera_x, p->y / Q8 - camera_y, 0, scale);
    }
    for (unsigned i = 0; i < BOOM_COUNT; i++) {
        const IntroBoom *p = &intro.boom[i];
        if (!p->active || !boom_art) continue;
        unsigned frame = p->age * 20 / FPS;
        if (frame >= 14) continue;
        gfx_TransparentSprite((gfx_sprite_t *)(boom_art + frame * BOOM_FRAME_BYTES),
            p->x - 16 - camera_x, p->y - 16 - camera_y);
    }
    if (intro.phase == 2) {
        int angle = intro.swing_angle / Q8;
        uint8_t byte_angle = (uint8_t)(angle * 256 / 360);
        /* x includes source offset.x=10 and the four transparent pad columns. */
        gfx_RotatedScaledTransparentSprite((gfx_sprite_t *)chute_square,
            intro.chute_x / Q8 - 14 - camera_x,
            intro.chute_y / Q8 - camera_y, byte_angle, 64);
    } else if (intro.phase == 3) {
        unsigned frame = 1 + intro.collapse_age * 10 / FPS;
        if (frame > 4) frame = 4;
        draw_sprite(59, frame, 1, intro.chute_x / Q8 - 10 - camera_x,
            intro.chute_y / Q8 - camera_y);
    }
}
