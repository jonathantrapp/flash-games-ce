#include "game.h"

/* Per-actor state that is not part of the shared renderer/level layout. */
typedef struct {
 int saved_vx,saved_vy,aimx,aimy,accumx,accumy;
 uint16_t flattened,shocking,shock_tick,dizzy;
 uint8_t saved_state,plan,armor,teleport,quickslash;
} EnemyExtra;
static EnemyExtra extra[MAX_ENEMIES];
static uint8_t death_queue[MAX_ENEMIES];
static unsigned death_read,death_write;
static bool resolving_deaths;
void combat_vector(int dx,int dy,int speed,int *vx,int *vy);

static EnemyExtra *more(Enemy *e){return &extra[e-g.enemy];}
static bool no_reaction(const Enemy *e){return e->type==39||e->type==40||e->type==42||e->type==46;}
static bool near_point(int dx,int dy,int range){if(absi(dx)>=range||absi(dy)>=range)return false;return (long)dx*dx+(long)dy*dy<(long)range*range;}
/* A tile ray is also used for the master's original line-of-sight teleport. */
bool enemy_line_of_sight(const Enemy *e){
 int x=e->x/16+e->bw/2,y=e->y/16+e->bh/2,tx=g.px/16+4,ty=g.py/16+7;
 int dx=absi(tx-x),dy=absi(ty-y),sx=x<tx?1:-1,sy=y<ty?1:-1,err=dx-dy;
 for(int steps=0;steps<600;steps++){
  if(x==tx&&y==ty)return true;if(blocked(x,y))return false;
  int twice=err*2;if(twice>-dy){err-=dy;x+=sx;}if(twice<dx){err+=dx;y+=sy;}
 }return false;
}
void enemy_flatten(Enemy *e,int ticks){if(!e||!e->active||no_reaction(e)||more(e)->flattened)return;EnemyExtra *m=more(e);m->flattened=ticks;if(!e->freeze){m->saved_state=e->state;m->saved_vx=e->vx;m->saved_vy=e->vy;}e->vx=e->vy=0;}
void enemy_freeze(Enemy *e,int ticks,int hits){if(!e||!e->active||e->type==42||e->freeze)return;EnemyExtra *m=more(e);e->freeze=ticks;e->freezehits=hits;if(!m->flattened){m->saved_state=e->state;m->saved_vx=e->vx;m->saved_vy=e->vy;}e->vx=e->vy=0;}
int enemy_status_value(const Enemy *e,int which){if(e<g.enemy||e>=g.enemy+MAX_ENEMIES)return 0;const EnemyExtra *m=&extra[e-g.enemy];return which==0?m->flattened:which==1?m->shocking:0;}
void enemy_shock(Enemy *e,int ticks){if(!e||!e->active)return;EnemyExtra *m=more(e);if(!m->shocking)m->shock_tick=0;m->shocking=ticks;}

static int original_life(int type){switch(type){case 16:case 35:case 38:case 41:case 42:return 2000;case 39:return 20000;case 40:return 15000;case 45:case 47:return 3000;case 46:return 10000;default:return 500;}}
static int original_xp(int type){switch(type){case 16:case 35:return 50;case 38:return 20;case 39:return 150;case 40:return 500;case 41:return 70;case 42:return 5;case 45:return 30;case 46:return 200;case 47:return 80;default:return 10;}}
Enemy *spawn_enemy(int type,int tx,int ty,int tag){
 int i;for(i=0;i<MAX_ENEMIES;i++)if(!g.enemy[i].active)break;if(i==MAX_ENEMIES)return NULL;Enemy *e=&g.enemy[i];memset(e,0,sizeof *e);memset(&extra[i],0,sizeof extra[i]);
 const ArtDef *a=&artdef[type];e->bw=a->bw?a->bw:11;e->bh=a->bh?a->bh:14;e->x=(tx*16+8-e->bw/2)*16;e->y=(ty*16+16-e->bh)*16;e->type=type;e->tag=tag;e->face=rand()%2?1:-1;e->hp=e->maxhp=original_life(type);e->active=1;e->reload=type==2?150:30;e->aux=300;
 if(type==35){e->state=5;e->timer=20;}if(type==40){e->state=2;e->timer=90;e->face=-1;e->aux=0;}if(type==42)e->vy=0;
 if(type==39)e->reload=120;if(type==46){e->reload=90;extra[i].armor=5;}if(type==45||type==47)e->reload=120;extra[i].aimy=e->y;
 if(i>=g.enemies)g.enemies=i+1;return e;
}
static bool orbs_alive(void){for(int i=0;i<g.enemies;i++)if(g.enemy[i].active&&g.enemy[i].type==42)return true;return false;}
static void clear_tag(int tag){if(!tag)return;for(int i=0;i<g.enemies;i++)if(g.enemy[i].active&&g.enemy[i].tag==tag)return;
 for(int i=0;i<g.props;i++)if(g.prop[i].active&&g.prop[i].tag==tag&&(g.prop[i].type==13||g.prop[i].type==14||g.prop[i].type==44))return;
 for(unsigned i=0;i<g.n;i++)if(g.solid[i]==55+tag)g.solid[i]=0;
}
static void apply_hit(Enemy *e,int damage,int force,bool shatter){
 if(!e||!e->active||e->cool>6||e->ghost)return;
 if(e->type==40&&(g.level!=14||orbs_alive()||e->state!=3))return;
 if(e->type==16||e->type==41||e->type==47){if(shatter){int type=e->type==16?38:e->type==41?17:45;e->type=type;}else damage=damage/4;}
 EnemyExtra *m=more(e);
 if(e->type==46){damage/=4;if(shatter||(e->hp-damage)<m->armor*e->maxhp/6){if(m->armor)m->armor--;if(!m->armor){e->type=39;e->maxhp=20000;e->hp*=2;}}}
 if(e->freeze){if(--e->freezehits<=0){damage=damage*(100+20*progress.skills[DEEPFREEZE])/100;e->freeze=0;e->vx=m->saved_vx;e->vy=m->saved_vy;e->state=m->saved_state;}}
 if(rand()%100<progress.skills[CRUSHINGBLOW]*2)e->hp=e->hp*80/100;
 e->hp-=damage;e->cool=6;e->stun=6;e->vx=force*g.face;e->vy=-20;
 if(e->type==35){if(e->state==3||e->state==4)m->dizzy=60;if(!m->dizzy){e->ghost=30;e->state=0;e->timer=0;e->stun=0;}else{e->state=100;e->stun=60;}}
 else if(!no_reaction(e))e->state=100;
 if(e->hp>0)return;
 e->active=0;g.kills++;
 /* Mark dead before queueing: each actor is queued once, even in a dense
  * Combo Bombo chain. No recursive enemy_hit calls consume the eZ80 stack. */
 if(death_write<MAX_ENEMIES)death_queue[death_write++]=(uint8_t)(e-g.enemy);
}
static void resolve_death(Enemy *e){
 profile_xp(original_xp(e->type));add_fury(2*progress.skills[FURIOUSBLOOD]);
 if(rand()%100<6*progress.skills[RECOVERY])g.hp=clampi(g.hp+100,0,maxlife());
 if(rand()%3==0)drop_power(7,e->x/16,e->y/16);
 if(e->type==42){bool remaining=false;for(int i=0;i<g.enemies;i++)if(g.enemy[i].active&&g.enemy[i].type==42&&g.enemy[i].tag==e->tag){remaining=true;break;}if(!remaining)for(int i=0;i<g.props;i++)if(g.prop[i].type==43&&g.prop[i].tag==e->tag)g.prop[i].active=0;}
 if(e->type==40&&g.level==14)drop_power(5,e->x/16,e->y/16);
 clear_tag(e->tag);
 if(progress.skills[COMBOBOMBO])for(int i=0;i<g.enemies;i++){Enemy *v=&g.enemy[i];if(v->active&&near_point(v->x-e->x,v->y-e->y,25*16))apply_hit(v,progress.skills[COMBOBOMBO]*200,0,false);}
}
void enemy_hit(Enemy *e,int damage,int force,bool shatter){
 if(!resolving_deaths){death_read=death_write=0;resolving_deaths=true;apply_hit(e,damage,force,shatter);while(death_read<death_write){unsigned id=death_queue[death_read++];resolve_death(&g.enemy[id]);}resolving_deaths=false;}
 else apply_hit(e,damage,force,shatter);
}
static void player_in_range(Enemy *e,int range,int damage,int kx,int ky){if(absi(g.px-e->x)<range*16&&absi(g.py-e->y)<e->bh*16)player_hurt(damage,e->face,kx,ky);}
static void basic_yak(Enemy *e,int distance,int mark){
 bool bruise=e->type==38;
 if(e->state==100){e->fr=15;if(!e->stun)e->state=0;return;}
 if(e->state==2){e->vx=0;e->fr=4+(e->age/3)%4;if(!e->timer){e->state=3;e->vx=e->face*80;}return;}
 if(e->state==3){e->fr=8+(e->age/2)%4;e->vx=approach(e->vx,0,3);player_in_range(e,15,100,100,-150);if(!e->vx){e->state=0;e->reload=bruise?90:150;}return;}
 if(e->state==4){e->fr=12+clampi((18-e->timer)/3,0,2);e->vx=bruise?e->face*26:e->face*5;if(e->timer==12)player_in_range(e,bruise?25:15,100,20,-40);if(!e->timer)e->state=0;return;}
 if(e->state==1){e->fr=e->vy<0?16:17;e->vx=e->face*26;return;}
 if(mark==10)e->face=1;else if(mark==11)e->face=-1;
 e->vx=e->face*16;e->fr=(e->age/3)%4;
 if((mark==3&&e->face<0)||(mark==4&&e->face>0)||mark==5){e->vy=-96;e->state=1;return;}
 if(distance<50*16&&((g.px>e->x)==(e->face>0))){if(distance<(bruise?25:15)*16&&!e->reload){e->state=4;e->timer=18;e->reload=30;}else if(!e->reload){e->state=2;e->timer=bruise?15:30;}}
}
static void archer(Enemy *e,int distance){
 e->vx=0;e->face=g.px<e->x?-1:1;e->fr=e->cool?7:(e->timer?1+(e->age/3)%6:0);
 if(distance>230*16)return;
 if(e->type==41&&e->aux>0)e->aux--;
 if(e->type==41&&!e->aux){if(e->timer==0)e->timer=30;if(e->timer%3==0)fire_shot(49,1,e->x/16+5,e->y/16+7,e->face*75,0,100);if(e->timer==1)e->aux=300;return;}
 if(!e->reload){fire_shot(49,1,e->x/16+5,e->y/16+7,e->face*72,-18+rand()%15,100);e->reload=e->type==41?60:90;e->timer=15;}
}
static void armor(Enemy *e,int distance,int mark){
 if(e->state==100){e->fr=15;if(!e->stun)e->state=0;return;}
 if(e->state==2){e->vx=0;e->fr=4+clampi((30-e->timer)/3,0,9);if(e->timer==12){player_in_range(e,30,100,60,-60);fire_shot(54,2,e->x/16+e->face*12,e->y/16-12,0,0,0);}if(!e->timer){e->state=0;e->reload=30;}return;}
 if(mark==10)e->face=1;else if(mark==11)e->face=-1;
 e->vx=e->face*16;e->fr=(e->age/3)%4;
 if((mark==3&&e->face<0)||(mark==4&&e->face>0)||mark==5)e->vy=-96;
 if(distance<30*16&&((g.px>e->x)==(e->face>0))&&!e->reload){e->state=2;e->timer=30;}
}
static void ninja(Enemy *e,int distance){
 EnemyExtra *m=more(e);(void)distance;
 if(e->state==5){e->vx=0;if(near_point(e->x-g.px,e->y-g.py,80*16)&&enemy_line_of_sight(e)){e->state=0;e->timer=15;
  if(g.level==4){story_start(4,e-g.enemy);for(int i=0;i<g.enemies;i++)if(g.enemy[i].active&&g.enemy[i].type==35&&g.enemy[i].state==5){g.enemy[i].state=0;g.enemy[i].timer=15;}if(g.w>60&&g.h>19){g.solid[19*g.w+59]=56;g.solid[19*g.w+60]=56;}}
 }return;}
 if(e->state==100){e->fr=9;if(!e->stun){e->state=m->dizzy?2:0;e->timer=15;}return;}
 if(e->state==2){e->vx=0;e->fr=10+(e->age/3)%2;if(!m->dizzy){e->state=0;e->timer=3;}return;}
 if(e->state==3){e->vx=e->vy=0;e->fr=5;if(e->aux>0)e->aux--;if(!e->timer){e->state=4;e->timer=6;}if(!e->aux){e->state=1;e->vx=e->face*16;}return;}
 if(e->state==4){e->vx=e->vy=0;e->fr=6+clampi((6-e->timer)/2,0,2);if(e->timer==2){int vx,vy;combat_vector(g.px-e->x,g.py-e->y,140,&vx,&vy);fire_shot(50,1,e->x/16+5,e->y/16+7,vx,vy,100);}if(!e->timer){e->state=3;e->timer=30;}return;}
 if(e->state==0){e->fr=0;e->vx=0;if(!e->timer){if(rand()%4==0)e->face=-e->face;e->state=1;e->vx=e->face*42;e->vy=-106;}return;}
 e->fr=4;
}
static void priest(Enemy *e,int distance,int mark){
 if(e->state==100){e->fr=9;if(!e->stun)e->state=0;return;}
 if(e->state==2){e->fr=clampi((30-e->timer)/3,1,9);e->vx=0;if(e->timer==6){if(e->type==47){fire_shot(51,1,e->x/16+6,e->y/16+2,-22,-22,100);fire_shot(51,1,e->x/16+6,e->y/16+2,22,-22,100);}else{fire_shot(53,1,g.px/16,g.py/16+8,0,0,100);}}if(!e->timer){e->state=0;e->reload=120;}return;}
 if(mark==10)e->face=1;else if(mark==11)e->face=-1;e->vx=e->face*10;e->fr=(e->age/3)%4;
 if(distance<150*16&&!e->reload){e->state=2;e->timer=30;}
}
static void giant(Enemy *e,int distance){
 static const uint8_t torgo[]={0,120,1,0,3,60,1,0,3,60,1,0,3,60,0,60,2,0,0,60,2,0};
 static const uint8_t robot[]={0,90,1,0,3,45,1,0,3,45,1,0,3,45};
 EnemyExtra *m=more(e);const uint8_t *plan=e->type==46?robot:torgo;unsigned count=e->type==46?COUNT(robot):COUNT(torgo);(void)distance;
 if(e->state==0&&!e->reload){m->plan=(m->plan+2)%count;e->state=plan[m->plan];e->reload=plan[m->plan+1];if(e->state!=3)e->face=g.px<e->x?-1:1;
  if(e->state==1){e->vy=-106;e->vx=e->face*42;}else if(e->state==2){e->timer=30;e->vx=0;}
 }
 if(e->state==3){e->vx=0;e->fr=9;if(!e->reload)e->state=0;return;}
 if(e->state==1){e->vx=e->face*42;e->fr=e->vy<0?2:1;return;}
 if(e->state==2){static const uint8_t smash[]={8,7,6,6,6,6,6,5,4,3};e->vx=0;e->fr=smash[clampi((30-e->timer)/3,0,9)];if(e->timer==9)fire_shot(52,1,e->x/16+e->bw/2,e->y/16+e->bh-9,e->face>0?1:2,0,200);if(!e->timer)e->state=0;return;}
 static const uint8_t walk[]={0,1,0,2};e->fr=walk[(e->age/3)%4];e->vx=e->face*10;if(e->age%30==0)e->face=g.px<e->x?-1:1;
}
static void master(Enemy *e,int distance){
 EnemyExtra *m=more(e);e->fr=(e->age/3)%2;
 if(g.level!=14){
  e->vx=0;e->vy=e->y>m->aimy?-1:e->y<m->aimy?1:e->vy;
  e->y=clampi(e->y,m->aimy-6*16,m->aimy+6*16);
  if(!e->aux&&((g.level==10||g.level==11||g.level==13)||distance<100*16)){int ev=g.level==8?5:g.level==10?8:g.level==11?9:10;story_start(ev,e-g.enemy);e->aux=1;}return;
 }
 if(e->state==2){e->vx=e->vy=0;if(distance<100*16){story_start(11,e-g.enemy);e->state=0;}return;}
 if(!orbs_alive()&&e->state!=3&&e->state!=4){e->state=3;e->timer=240;}
 if(e->state==3){e->vx=e->vy=0;e->fr=e->cool?8:4+(e->age/2)%4;if(!e->timer){static const uint8_t orb[]={7,24,7,18,15,15,24,17,24,20};for(unsigned i=0;i<COUNT(orb);i+=2)spawn_enemy(42,orb[i],orb[i+1],0);e->state=4;e->timer=18;}return;}
 if(e->state==4){e->vx=e->vy=0;e->fr=9+(e->age/3)%2;if(!e->timer){e->state=0;e->vy=-16;}return;}
 e->face=g.px<e->x?-1:1;
 int ax,ay;combat_vector(g.px-e->x,g.py-e->y,30,&ax,&ay);
 /* Original acceleration=30px/s^2, maximum component speed=70px/s. */
 m->accumx+=ax;m->accumy+=ay;
 e->vx=clampi(e->vx+m->accumx/FPS,-37,37);e->vy=clampi(e->vy+m->accumy/FPS,-37,37);m->accumx%=FPS;m->accumy%=FPS;
 bool los=enemy_line_of_sight(e);if(!los)m->teleport=1;
 if(!e->reload){int vx,vy;combat_vector(g.px-e->x,g.py-e->y,60,&vx,&vy);fire_shot(51,1,e->x/16+5,e->y/16+7,vx,vy,100);e->reload=90;
  if(m->teleport&&!los){e->x=g.px+4*16-e->bw*8;e->y=g.py+7*16-e->bh*8;e->vx=e->vy=0;m->teleport=0;fire_shot(56,2,e->x/16,e->y/16,0,0,0);}
 }
 if(e->age%300==0){int alive=0;for(int i=0;i<g.enemies;i++)alive+=g.enemy[i].active;if(alive<10){spawn_enemy(45,13,24,0);spawn_enemy(45,18,24,0);}}
}
void enemy_update(void){
 for(int i=0;i<g.enemies;i++){
  Enemy *e=&g.enemy[i];if(!e->active)continue;
  int distance=absi(e->x-g.px)+absi(e->y-g.py);if(distance>450*16&&e->type!=40)continue;
  EnemyExtra *m=more(e);e->age++;if(e->timer)e->timer--;if(e->reload)e->reload--;if(e->cool)e->cool--;if(e->stun)e->stun--;if(e->ghost)e->ghost--;if(m->dizzy)m->dizzy--;
  if(m->shocking){m->shocking--;if(++m->shock_tick>=8){m->shock_tick=0;fire_shot(56,2,e->x/16+e->bw/2,e->y/16+e->bh/2,0,0,0);}}
  if(e->freeze){e->freeze--;e->fr=0;if(m->flattened)m->flattened--;if(!e->freeze){e->vx=m->saved_vx;e->vy=m->saved_vy;e->state=m->saved_state;}continue;}
  if(m->flattened){m->flattened--;e->fr=0;e->vx=0;int floor;e->vy+=7;move_body(&e->x,&e->y,&e->vy,0,e->bw,e->bh,&floor);if(!m->flattened){e->vx=m->saved_vx;e->vy=m->saved_vy;e->state=100;}continue;}
  if(g.carry==i){e->x=g.px;e->y=g.py-e->bh*8;continue;}
  if(e->thrown){e->thrown--;int floor;e->vy+=4;move_body(&e->x,&e->y,&e->vy,e->vx,e->bw,e->bh,&floor);if(floor||!e->thrown){e->thrown=0;enemy_hit(e,skill_damage(PA_CARRY),0,false);}for(int j=0;j<g.enemies;j++)if(j!=i&&g.enemy[j].active&&absi(g.enemy[j].x-e->x)+absi(g.enemy[j].y-e->y)<20*16)enemy_hit(&g.enemy[j],skill_damage(PA_CARRY)*progress.skills[COCONUTBONK]/10,20,false);continue;}
  int tx=(e->x/16+e->bw/2)/16,ty=(e->y/16+e->bh/2)/16,mark=tx>=0&&tx<(int)g.w&&ty>=0&&ty<(int)g.h?g.good[ty*g.w+tx]:0;
  switch(e->type){case 2:case 38:basic_yak(e,distance,mark);break;case 16:armor(e,distance,mark);break;case 17:case 41:archer(e,distance);break;case 35:ninja(e,distance);break;case 39:case 46:giant(e,distance);break;case 45:case 47:priest(e,distance,mark);break;case 40:master(e,distance);break;case 42:e->vx=e->vy=0;e->fr=(e->age/3)%3;break;case 29:e->vx=e->face*16;e->fr=(e->age/3)%4;player_in_range(e,12,100,40,-40);break;}
  if(g.mode!=PLAY)return;
  int oldx=e->x,floor=0,oldstate=e->state;
  bool hanging=e->type==35&&(e->state==3||e->state==4);
  if(e->type!=40&&e->type!=42&&!hanging){m->accumy+=400*16;e->vy=clampi(e->vy+m->accumy/(FPS*FPS),-200,426);m->accumy%=FPS*FPS;}
  move_body(&e->x,&e->y,&e->vy,e->vx,e->bw,e->bh,&floor);
  if(e->vx&&oldx==e->x){if(e->type==35&&e->state==1){e->state=3;e->timer=30;e->aux=96;e->vx=e->vy=0;e->face=-e->face;}else{e->face=-e->face;if(e->state==3&&e->type!=40){e->state=0;e->reload=150;}}}
  if(floor&&e->state==1){if(e->type==39){e->state=0;for(int j=0;j<6;j++)fire_shot(52,1,e->x/16+e->bw/2-30+j*12,e->y/16+e->bh-9,0,0,200);}else if(e->type==46){e->state=0;for(int spread=1;spread<=2;spread++)fire_shot(52,1,e->x/16+e->bw/2,e->y/16+e->bh-9,spread,0,200);}else{e->state=0;e->timer=15;}}
  if(e->y/16>(int)g.h*16+32&&e->type!=40){e->cool=0;enemy_hit(e,99900,0,false);}
  (void)oldstate;
 }
}
