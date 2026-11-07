#include "../src/game.h"
Game g;
static int parity_rand(void){return 99;}
#define rand parity_rand
#include "../src/profile.c"
void sky_runtime_refresh(void){}
#define near_point enemy_near_point
#include "../src/enemies.c"
#undef near_point
#include "../src/player.c"
#include "../src/projectiles.c"
int absi(int v){return v<0?-v:v;}
int clampi(int v,int lo,int hi){return v<lo?lo:v>hi?hi:v;}
int approach(int v,int target,int amount){return v<target?clampi(v+amount,v,target):clampi(v-amount,target,v);}
int tile_at(int x,int y){(void)x;(void)y;return 0;}
bool blocked(int x,int y){(void)x;(void)y;return false;}
void move_body(int*x,int*y,int*v,int dx,int bw,int bh,int*floor){(void)bw;(void)bh;*x+=dx;*y+=*v;*floor=0;}
void drop_power(int a,int b,int c){(void)a;(void)b;(void)c;}
void story_start(int a,int b){(void)a;(void)b;}
static void reset(void){memset(&g,0,sizeof g);memset(&progress,0,sizeof progress);g.mode=PLAY;g.w=120;g.h=40;g.back=g.mapdata;g.solid=g.mapdata+4800;g.decor=g.mapdata+9600;g.good=g.mapdata+14400;g.px=g.py=200*16;g.hp=500;g.face=1;g.carry=-1;g.ground=1;player_update();g.ground=1;g.py=200*16;g.vx=g.vy=0;}
static void result(const char*n,int actual,int expected){printf("R %s %d %d\n",n,actual,expected);}
static Enemy* victim(int dx){Enemy*e=spawn_enemy(2,12,12,0);e->x=g.px+dx*16;e->y=g.py;e->hp=e->maxhp=10000;return e;}
int main(void){
 int actions[]={PA_DASH,PA_CHARGEKICK,PA_PEDROKEN,PA_PILEDRIVE,PA_HITSTUN};const char*labels[]={"dash_is_vulnerable","chargekick_is_vulnerable","nonburning_pedroken_is_vulnerable","piledrive_is_invulnerable","hitstun_is_invulnerable"};
 for(int i=0;i<5;i++){reset();g.action=actions[i];g.invul=g.dodge=0;g.vy=-60;player_hurt(100,1,0,0);result(labels[i],g.hp,i<3?400:500);}
 reset();g.action=PA_HITSTUN;g.actiontime=9;g.ground=0;g.tap=DOWN;progress.skills[RECOVERY]=1;player_update();result("recovery_downward_speed_at_least_300pxs",g.vy>=160,1);result("recovery_ends_hitstun",g.action,PA_JUMP);
 reset();progress.skills[PEDROKEN]=1;progress.skills[FISTSOFFLAME]=2;g.fury=100;g.action=PA_DUCK;g.keys=DOWN|HITKEY;g.tap=HITKEY;player_update();result("burning_pedroken_initial_cost",g.fury,96);g.tap=0;for(int i=0;i<5;i++)player_update();result("burning_pedroken_cost_once_per_move",g.fury,96);g.invul=g.dodge=0;player_hurt(100,1,0,0);result("burning_rising_pedroken_is_invulnerable",g.hp,500);
 reset();progress.skills[PEDROKEN]=1;progress.skills[FISTSOFFLAME]=2;g.fury=0;g.action=PA_DUCK;g.keys=DOWN|HITKEY;g.tap=HITKEY;player_update();g.invul=g.dodge=0;player_hurt(100,1,0,0);result("unaffordable_flame_does_not_grant_invulnerability",g.hp,400);
 reset();g.action=PA_DASH;g.dash=30;Enemy*e=victim(4);for(int i=0;i<5;i++){e->cool=0;e->x=g.px+4*16;e->y=g.py;player_update();}result("dash_hits_each_enemy_once",e->hp,9800);
 reset();progress.skills[LIGHTNINGFIST]=1;g.action=PA_PUNCH;g.actiontime=7;victim(8);e=victim(25);player_update();result("lightning_rank1_stops_at_15px",e->hp,10000);
 reset();progress.skills[LIGHTNINGFIST]=2;g.action=PA_PUNCH;g.actiontime=7;victim(8);e=victim(43);player_update();result("lightning_rank2_stops_at_30px",e->hp,10000);
 reset();progress.skills[KOKICK]=2;progress.skills[DIVEKICK]=1;g.action=PA_DIVEKICK;g.ground=0;g.vy=53;e=victim(8);player_update();result("KO_kick_flatten_status_ticks",enemy_status_value(e,0),24);
 reset();fire_shot(57,0,0,0,53,0,100);result("friendly_fireball_eight_second_lifetime",g.shot[0].ttl,240);
 reset();fire_shot(51,1,0,0,32,0,100);result("bad_fireball_six_second_lifetime",g.shot[0].ttl,180);
 reset();progress.skills[DEEPFREEZE]=2;e=victim(8);enemy_freeze(e,60,3);int x=e->x,y=e->y;for(int i=0;i<10;i++)enemy_update();result("frozen_enemy_holds_x",e->x,x);result("frozen_enemy_holds_y",e->y,y);result("frozen_enemy_hit_budget",e->freezehits,3);
 return 0;}
