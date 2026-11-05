#ifndef GAME_H
#define GAME_H
#include <stdint.h>
#include <stdbool.h>
#include <tice.h>
#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "resources.h"
#include "skill_meta.h"

#define FPS 30
#define FX 16
#define MAX_ENEMIES 96
#define MAX_PROPS 96
#define MAX_SHOTS 48
#define COUNT(a) (sizeof(a)/sizeof((a)[0]))
enum { TITLE, PLAY, PAUSE, DEFEAT, VICTORY, MAP, SKILLS, DIALOGUE, ENDING, HELP };
enum { LEFT=1,RIGHT=2,UP=4,DOWN=8,JUMPKEY=16,HITKEY=32,FURYKEY=64,ACCEPT=128,MENUKEY=256,EXITKEY=512,SKILLKEY=1024,MINUSKEY=2048 };
enum { PA_IDLE,PA_JUMP,PA_DUCK,PA_DASH,PA_GLIDE,PA_DIE,PA_JUMPKICK,PA_CARRY,PA_CARRYJUMP,PA_PUNCH,PA_HITSTUN,PA_TORNADO,PA_FURYPICK,PA_INACTIVE,PA_DIVEKICK,PA_FURYHEAL,PA_PEDROKEN,PA_CHARGEKICK,PA_PILEDRIVE };
typedef struct {uint8_t skills[45],have[45],hearts[15],souls[15],passed[15],rank,points;uint16_t xp;uint32_t best[15];} Progress;
typedef struct {int x,y,vx,vy,hp,maxhp;int timer,reload,cool,freeze,freezehits,ghost,aux,age,stun,thrown;uint8_t type,tag,state,fr,active,bw,bh;int8_t face;} Enemy;
typedef struct {int x,y,timer;uint8_t type,tag,state,count,active;int8_t face;} Prop;
typedef struct {int x,y,vx,vy,damage,ttl;uint8_t type,side,active,frame;int8_t face;} Shot;
typedef struct {
 uint8_t mapdata[21000];uint8_t *back,*solid,*decor,*good;
 unsigned w,h,n;int level,selected,mode,previousmode;
 int px,py,vx,vy,face,ground,canjump,doublejump,safex,safey,hp,fury;
 int action,actiontime,attackcool,invul,dodge,dash,combo,kicks,carry,berserk,rage,inner,healspent;
 int lastdir,taptime,anim,frame,mailleft,totalmail,kills;
 int enemies,props,arena,arenaround,arenatime,skillpick,skillgroup,notice_timer;
 int story_event,story_page,story_enemy;uint16_t story_done;
 uint32_t ticks;uint16_t keys,tap,previouskeys;
 Enemy enemy[MAX_ENEMIES];Prop prop[MAX_PROPS];Shot shot[MAX_SHOTS];
 const char *notice;
} Game;
extern Game g;
extern Progress progress;
extern volatile uint8_t pedro_diag[8];
extern const uint8_t *artdata[60],*tiledata[2],*uidata[3][2];
int absi(int v);int clampi(int v,int lo,int hi);int approach(int v,int target,int amount);
bool load_resources(void);void draw_sprite(int id,int frame,int face,int x,int y);
bool load_level(int level);int tile_at(int x,int y);bool blocked(int x,int y);bool body_collides(int x,int y,int bw,int bh);
void move_body(int *x,int *y,int *vy,int dx,int bw,int bh,int *floor);
void profile_load(void);void profile_save(void);void profile_xp(int n);int maxlife(void);int maxfury(void);int skill_need(int id);bool skill_adjust(int id,int change);void collect_power(int which);void add_fury(int n);void notice(const char *s);
int skill_damage(int type);int punch_bonus(void);int kick_bonus(void);int fury_bonus(void);
Enemy *spawn_enemy(int type,int tx,int ty,int tag);void enemy_update(void);void enemy_hit(Enemy *e,int damage,int force,bool shatter);void player_hurt(int amount,int facing,int knockx,int knocky);
void player_update(void);void projectile_update(void);void fire_shot(int type,int side,int x,int y,int vx,int vy,int damage);
void prop_update(void);void arena_setup(void);void arena_update(void);void drop_power(int which,int x,int y);
void story_start(int event,int enemy);void story_update(void);void story_draw(void);void story_triggers(void);
void draw_game(void);void draw_frontend(void);void frontend_update(void);void wrap_text(int x,int y,int width,const char *s,int lineheight);void center_text(int y,const char *s);
#endif
