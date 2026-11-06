#include "game.h"
void combat_vector(int dx,int dy,int speed,int *vx,int *vy);
void enemy_flatten(Enemy *e,int ticks);
void enemy_freeze(Enemy *e,int ticks,int hits);
bool enemy_line_of_sight(const Enemy *e);
static uint8_t attack_hit[(MAX_ENEMIES+7)/8];
static bool uppercut_burns,reflection,retaliating,lightning_used;
static int gravity_remainder,walk_remainder,last_level=-1,last_action=-1;
static uint32_t last_tick;
static void clear_hits(void){memset(attack_hit,0,sizeof attack_hit);lightning_used=false;}
static bool already_hit(int i){return (attack_hit[i/8]&(1u<<(i%8)))!=0;}
static void mark_hit(int i){attack_hit[i/8]|=1u<<(i%8);}
bool player_reflects(void){bool reflected=reflection;reflection=false;return reflected;}
bool player_is_burning(void){return uppercut_burns&&g.action==PA_PEDROKEN&&g.vy<0;}
static void begin_uppercut(void){
 g.action=PA_PEDROKEN;g.actiontime=30;g.vy=-59;g.vx=g.face*21;g.dodge=0;clear_hits();uppercut_burns=false;
 int cost=2*progress.skills[FISTSOFFLAME];if(cost&&g.fury>=cost){add_fury(-cost);uppercut_burns=true;}
}
static void begin_charge(bool counter){
 Enemy *target=NULL;long best=0x7fffffffL;
 for(int i=0;i<g.enemies;i++){Enemy *e=&g.enemy[i];if(!e->active||((e->x>g.px)!=(g.face>0))||!enemy_line_of_sight(e))continue;int dx=e->x+e->bw*8-g.px-4*16,dy=e->y+e->bh*8-g.py-7*16;if(absi(dx)>=70*16||absi(dy)>=70*16)continue;long d=(long)dx*dx+(long)dy*dy;if(d<best){best=d;target=e;}}
 int dx=target?target->x+target->bw*8-g.px-4*16:g.face*40*16,dy=target?target->y+target->bh*8-g.py-7*16:40*16;
 combat_vector(dx,dy,200,&g.vx,&g.vy);g.action=PA_CHARGEKICK;g.actiontime=30;g.attackcool=30;retaliating=counter;clear_hits();
}
static bool nearby(Enemy *e,int range,int yrange){return e->active&&absi(e->x-g.px)<range*16&&absi(e->y-g.py)<yrange*16;}
void player_hurt(int amount,int facing,int knockx,int knocky){
 reflection=false;
 if(g.invul||g.dodge||g.action==PA_PILEDRIVE||g.action==PA_HITSTUN)return;
 if((g.action==PA_FURYHEAL&&rand()%100<progress.skills[FURIOUSSHIELD]*20)||player_is_burning()){reflection=true;return;}
 g.hp-=amount;g.invul=6;g.vx=facing*knockx*16/FPS;g.vy=knocky*16/FPS;g.action=PA_HITSTUN;g.actiontime=6;g.rage=progress.skills[RAGINGBURRO]*FPS;add_fury(2*progress.skills[HEARTOFFURY]);
 if(g.carry>=0){Enemy *e=&g.enemy[g.carry];e->thrown=0;e->state=0;e->vx=e->vy=0;g.carry=-1;}
 if(g.hp<=0){g.hp=0;g.mode=DEFEAT;}
}
static void area_hit(int damage,int range,bool shatter){for(int i=0;i<g.enemies;i++)if(nearby(&g.enemy[i],range,range))enemy_hit(&g.enemy[i],damage,30,shatter);}
static bool attack_overlaps(const Enemy *e,int action){
 int x=g.px,y=g.py,w=8,h=15;
 if(action==PA_PUNCH){w=14+progress.skills[GALEFIST]*3;x+=g.face>0?4*16:(4-w)*16;y-=3*16;h=18;}
 else if(action==PA_JUMPKICK||action==PA_CHARGEKICK||action==PA_TORNADO){w=12;x+=g.face>0?2*16:-6*16;}
 else if(action==PA_DIVEKICK){w=16;h=8;x+=g.face>0?4*16:-12*16;y+=11*16;}
 else if(action==PA_PEDROKEN){w=uppercut_burns?24:16;h=uppercut_burns?19:15;x+=g.face>0?(uppercut_burns?-4:2)*16:(uppercut_burns?-12:-10)*16;y-=(uppercut_burns?12:8)*16;}
 return x<e->x+e->bw*16&&x+w*16>e->x&&y<e->y+e->bh*16&&y+h*16>e->y;
}
static void strike(void){
 int action=g.action;
 for(int i=0;i<g.enemies;i++){
  Enemy *e=&g.enemy[i];if(!e->active||!attack_overlaps(e,action)||e->cool>=6||e->ghost||already_hit(i))continue;
  int damage=skill_damage(action);bool shatter=false;mark_hit(i);
  if(action==PA_PUNCH&&rand()%100<progress.skills[PRESSUREPOINTS]*4){damage*=3;add_fury(progress.skills[PRESSUREPOINTS]);}
  if(action==PA_PEDROKEN&&uppercut_burns){damage+=progress.skills[FISTSOFFLAME]*fury_bonus();shatter=rand()%100<progress.skills[FISTSOFFLAME]*20;}
  if(action==PA_JUMPKICK||action==PA_DIVEKICK||action==PA_CHARGEKICK){if(rand()%100<progress.skills[LEADFOOT]*3){damage*=3;shatter=true;}}
  if(action==PA_CHARGEKICK&&retaliating){damage=(100+100*progress.skills[RETALIATE])*(kick_bonus()+fury_bonus()-100)/100;}
  if(g.action==PA_DASH&&progress.skills[MIGHTYGRAB]&&(g.keys&HITKEY)&&e->type!=39&&e->type!=40&&e->type!=46&&e->type!=42){g.carry=i;g.action=PA_CARRY;g.dash=0;break;}
  enemy_hit(e,damage,g.action==PA_PEDROKEN?42:g.action==PA_DASH?36:18,shatter);
  fire_shot(56,2,(g.px+e->x)/32,(g.py+e->y)/32,0,0,0);
  if(action==PA_PUNCH){if(rand()%100<progress.skills[FISTOFFURY]*10)add_fury(2);if(!lightning_used){lightning_used=true;int chain=progress.skills[LIGHTNINGFIST];for(int j=0;j<g.enemies&&chain;j++)if(j!=i&&g.enemy[j].active){int dx=(g.enemy[j].x+g.enemy[j].bw*8)-(e->x+e->bw*8),dy=(g.enemy[j].y+g.enemy[j].bh*8)-(e->y+e->bh*8),range=progress.skills[LIGHTNINGFIST]*15*16;if(absi(dx)<range&&absi(dy)<range&&(long)dx*dx+(long)dy*dy<(long)range*range){enemy_hit(&g.enemy[j],20+20*progress.skills[LIGHTNINGFIST],0,false);fire_shot(56,2,g.enemy[j].x/16,g.enemy[j].y/16,0,0,0);chain--;}}}}
  else if(action!=PA_TORNADO)add_fury(progress.skills[FEETOFFURY]);
  if(action==PA_DIVEKICK){g.vy=-67;g.action=PA_JUMP;enemy_flatten(e,12*progress.skills[KOKICK]);}
  if(action==PA_JUMPKICK&&(g.keys&HITKEY)&&progress.skills[TORNADOKICK]){g.action=PA_TORNADO;g.actiontime=54;g.combo=0;}
  if(action==PA_CHARGEKICK){g.action=PA_JUMP;g.vy=-17;g.vx=-g.face*32;g.attackcool=8;}
 }
}
static void fury_update(void){
 if(!(g.keys&FURYKEY)){g.action=PA_IDLE;return;}
 g.vx=g.vy=0;
 if((g.tap&DOWN)&&progress.skills[FURIOUSBLAST]&&g.fury>=100){add_fury(-100);area_hit(skill_damage(PA_FURYPICK),190,true);for(int i=0;i<MAX_SHOTS;i++)if(g.shot[i].active&&g.shot[i].side==1&&rand()%100<progress.skills[FURIOUSROAR]*20)g.shot[i].active=0;g.action=PA_IDLE;}
 else if((g.tap&LEFT)&&progress.skills[FURIOUSFREEZE]&&g.fury>=100){add_fury(-100);for(int i=0;i<g.enemies;i++)if(nearby(&g.enemy[i],190,150))enemy_freeze(&g.enemy[i],45*progress.skills[FURIOUSFREEZE],progress.skills[DEEPFREEZE]+1);g.action=PA_IDLE;}
 else if((g.tap&RIGHT)&&progress.skills[FURIOUSFRENZY]&&g.fury>=100){add_fury(-100);g.berserk=progress.skills[FURIOUSFRENZY]*60;g.action=PA_IDLE;}
 else if((g.keys&UP)&&progress.skills[FURIOUSFIX]&&g.fury>=100){g.action=PA_FURYHEAL;g.healspent=0;g.actiontime=0;}
}
void player_update(void){
 if(last_level!=g.level||g.ticks<last_tick){last_level=g.level;last_action=-1;uppercut_burns=reflection=retaliating=false;gravity_remainder=walk_remainder=0;clear_hits();}last_tick=g.ticks;
 if(g.action!=last_action){clear_hits();last_action=g.action;}
 if(g.tap&MENUKEY){g.mode=PAUSE;return;}
 if(g.invul)g.invul--;if(g.dodge)g.dodge--;if(g.attackcool)g.attackcool--;if(g.taptime)g.taptime--;if(g.canjump)g.canjump--;if(g.actiontime)g.actiontime--;if(g.berserk)g.berserk--;if(g.rage)g.rage--;
 if(progress.skills[INNERFURY]&&++g.inner>=90-15*progress.skills[INNERFURY]){g.inner=0;add_fury(1);}
 if(g.action==PA_FURYPICK){fury_update();return;}
 if(g.action==PA_FURYHEAL){g.vx=0;if(!(g.keys&UP)||!g.fury){g.action=PA_IDLE;}else if(!g.actiontime&&g.fury>=5){g.actiontime=3;add_fury(-5);g.healspent+=5;while(g.healspent>=20-3*progress.skills[FURIOUSFIX]){g.healspent-=20-3*progress.skills[FURIOUSFIX];g.hp=clampi(g.hp+100,0,maxlife());}}return;}
 if((g.tap&FURYKEY)&&g.fury>=100&&(progress.skills[FURIOUSBLAST]||progress.skills[FURIOUSFREEZE]||progress.skills[FURIOUSFIX]||progress.skills[FURIOUSFRENZY])){g.action=PA_FURYPICK;return;}
 if(g.berserk&&(g.tap&HITKEY)&&progress.skills[BURNINGFURY])fire_shot(57,0,g.px/16+4,g.py/16+8,g.face*55,0,progress.skills[BURNINGFURY]*50*fury_bonus()/100);
 bool normal=g.action==PA_IDLE||g.action==PA_JUMP||g.action==PA_DUCK||g.action==PA_CARRY||g.action==PA_CARRYJUMP;
 if(normal){
  int direction=(g.keys&LEFT)?-1:(g.keys&RIGHT)?1:0;
  if(direction){g.face=direction;g.vx=approach(g.vx,direction*37,5);}else g.vx=approach(g.vx,0,5);
  bool was_duck=g.action==PA_DUCK;
  if(was_duck&&!(g.keys&DOWN))g.py-=3*16;
  if(g.ground){g.doublejump=0;g.canjump=3;g.kicks=0;g.safex=g.px;g.safey=g.py;g.action=g.carry>=0?PA_CARRY:PA_IDLE;}
  else g.action=g.carry>=0?PA_CARRYJUMP:PA_JUMP;
  if((g.tap&(LEFT|RIGHT))&&progress.skills[BURROBASH]&&g.ground&&g.carry<0){if(g.taptime&&g.lastdir==direction){g.action=PA_DASH;g.dash=15*progress.skills[BURROBASH];g.vx=g.face*80;clear_hits();}g.lastdir=direction;g.taptime=6;}
  /* The original's canJump grace window permits held/variable-height jumps;
   * its unused dblJump field does not grant an extra airborne jump. */
  if((g.keys&(UP|JUMPKEY))&&g.canjump){g.vy=-67;gravity_remainder=300;g.ground=0;g.action=g.carry>=0?PA_CARRYJUMP:PA_JUMP;}
  if((g.keys&DOWN)&&g.ground){g.action=PA_DUCK;g.vx=approach(g.vx,0,10);if(!was_duck){g.py+=3*16;g.dodge=6*progress.skills[DODGE];}}
  if(g.carry>=0){Enemy *e=&g.enemy[g.carry];if(!(g.keys&HITKEY)){e->thrown=90;e->vx=g.face*43;e->vy=-27;g.carry=-1;g.action=PA_IDLE;g.attackcool=15;}else if((g.tap&DOWN)&&!g.ground&&progress.skills[PILEDRIVER]){g.action=PA_PILEDRIVE;g.vy=27;g.vx=0;}}
  else if((g.tap&DOWN)&&!g.ground&&g.kicks<progress.skills[DIVEKICK]){g.kicks++;g.action=PA_DIVEKICK;g.vy=53;g.vx=g.face*32;clear_hits();}
  else if((g.keys&HITKEY)&&!g.attackcool){
   if(g.action==PA_DUCK&&progress.skills[PEDROKEN]){g.py-=3*16;begin_uppercut();}
   else if(g.ground){g.action=PA_PUNCH;g.actiontime=10;g.combo=1;g.vx=g.face*13;clear_hits();}
   else if(g.tap&HITKEY){g.action=PA_JUMPKICK;g.actiontime=12;clear_hits();}
  }
 }
 if(g.action==PA_DASH){g.vx=g.face*80*(g.dash+15)/(15*progress.skills[BURROBASH]+15);if((g.face<0&&(g.keys&RIGHT))||(g.face>0&&(g.keys&LEFT)))g.dash=0;if(--g.dash<=0){g.action=g.ground?PA_IDLE:PA_JUMP;g.vx=0;}else strike();}
 else if(g.action==PA_PUNCH){g.vx=approach(g.vx,0,5);if(g.actiontime==6)strike();if(g.actiontime<6&&(g.keys&HITKEY)&&g.combo<1+progress.skills[PEDROPUNCH]){if((g.keys&DOWN)&&progress.skills[PEDROKEN])begin_uppercut();else{g.combo++;g.actiontime=10;g.vx=g.face*13;clear_hits();}}if(!g.actiontime){g.action=g.ground?PA_IDLE:PA_JUMP;g.attackcool=6;}}
 else if(g.action==PA_JUMPKICK){strike();if((g.tap&HITKEY)&&g.actiontime<8&&progress.skills[CHARGEKICK])begin_charge(false);if(!g.actiontime)g.action=PA_JUMP;}
 else if(g.action==PA_CHARGEKICK){strike();if(!g.actiontime){g.action=PA_JUMP;g.vx=g.vy=0;g.attackcool=8;}}
 else if(g.action==PA_DIVEKICK){g.vx=g.face*32;strike();if(g.ground)g.action=PA_IDLE;}
 else if(g.action==PA_TORNADO){g.vx=0;g.vy=-5;if(g.actiontime%5==0){g.face=-g.face;clear_hits();strike();g.combo++;}if(progress.skills[WHIRLWIND])for(int i=0;i<g.enemies;i++)if(nearby(&g.enemy[i],progress.skills[WHIRLWIND]*10,progress.skills[WHIRLWIND]*10)){g.enemy[i].x=approach(g.enemy[i].x,g.px,53);g.enemy[i].y=approach(g.enemy[i].y,g.py,53);}if(!g.actiontime||g.combo>=6||!(g.keys&HITKEY))g.action=PA_JUMP;}
 else if(g.action==PA_PEDROKEN){if(g.vy<0)strike();if(g.ground&&g.vy>=0)g.action=PA_IDLE;}
 else if(g.action==PA_HITSTUN){if((g.tap&DOWN)&&progress.skills[RECOVERY]){g.action=PA_JUMP;g.vx=0;if(g.vy<160)g.vy=160;}else if((g.tap&HITKEY)&&progress.skills[RETALIATE]&&g.fury>=20-3*progress.skills[RETALIATE]){add_fury(-(20-3*progress.skills[RETALIATE]));begin_charge(true);}else if(!g.actiontime&&g.ground)g.action=PA_IDLE;}
 bool water=tile_at(g.px/16+4,g.py/16+8)==62;
 if(g.action!=PA_TORNADO&&(g.action!=PA_CHARGEKICK||g.vy<0)){gravity_remainder+=(g.action==PA_CHARGEKICK?150:water?105:300)*16;g.vy+=gravity_remainder/(FPS*FPS);gravity_remainder%=FPS*FPS;}
 g.vy=clampi(g.vy,-200,426);int oldx=g.px,oldy=g.py,dx=g.vx;
 if(normal&&absi(g.vx)==37){walk_remainder+=10;if(walk_remainder>=30){walk_remainder-=30;dx+=g.face;}}
 move_body(&g.px,&g.py,&g.vy,dx,8,g.action==PA_DUCK?12:15,&g.ground);
 if(g.action==PA_CHARGEKICK&&((g.px==oldx&&g.vx)||(g.py==oldy&&g.vy)||g.ground)){g.action=PA_JUMP;g.vx=g.vy=0;g.attackcool=8;}
 if(g.action==PA_DASH&&g.px==oldx){g.action=PA_HITSTUN;g.actiontime=12;g.vx=-g.face*27;g.vy=-40;}
 if(g.action==PA_PILEDRIVE&&g.ground&&g.carry>=0){Enemy *e=&g.enemy[g.carry];e->cool=0;enemy_hit(e,skill_damage(PA_PILEDRIVE),0,false);e->stun=15*progress.skills[PILEDRIVER];if(progress.skills[ATOMICPILEDRIVER]&&g.fury>=progress.skills[ATOMICPILEDRIVER]){add_fury(-progress.skills[ATOMICPILEDRIVER]);area_hit(progress.skills[ATOMICPILEDRIVER]*200*fury_bonus()/100,10+progress.skills[ATOMICPILEDRIVER]*6,false);}g.carry=-1;g.action=PA_JUMP;g.vy=-32;}
 if(g.py/16>(int)g.h*16+32){g.invul=0;player_hurt(100,0,0,0);g.px=g.safex;g.py=g.safey;g.vx=g.vy=0;}
 if(g.ground&&tile_at(g.px/16+4,g.py/16+17)==63)player_hurt(100,-g.face,40,-40);
 if(g.hp<=0)g.mode=DEFEAT;
 last_action=g.action;
}
