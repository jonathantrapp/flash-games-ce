#include "game.h"
static bool nearby(Enemy *e,int range,int yrange){return e->active&&absi(e->x-g.px)<range*16&&absi(e->y-g.py)<yrange*16;}
void player_hurt(int amount,int facing,int knockx,int knocky){
 if(g.invul||g.dodge||g.action==PA_DASH||g.action==PA_CHARGEKICK||g.action==PA_PEDROKEN)return;
 if(g.action==PA_FURYHEAL&&rand()%100<progress.skills[FURIOUSSHIELD]*20)return;
 g.hp-=amount;g.invul=15;g.vx=facing*knockx*16/30;g.vy=knocky*16/30;g.action=PA_HITSTUN;g.actiontime=12;g.rage=progress.skills[RAGINGBURRO]*30;add_fury(2*progress.skills[HEARTOFFURY]);
 if(g.carry>=0){Enemy *e=&g.enemy[g.carry];e->thrown=30;e->vx=facing*40;e->vy=-25;g.carry=-1;}
 if(g.hp<=0){g.hp=0;g.mode=DEFEAT;}
}
static void area_hit(int damage,int range,bool shatter){for(int i=0;i<g.enemies;i++)if(nearby(&g.enemy[i],range,range))enemy_hit(&g.enemy[i],damage,30,shatter);}
static void strike(void){
 int range=20,yrange=20,damage=skill_damage(g.action);bool shatter=false;
 if(g.action==PA_PUNCH){range+=progress.skills[GALEFIST]*4;if(rand()%100<progress.skills[PRESSUREPOINTS]*4){damage*=3;add_fury(progress.skills[PRESSUREPOINTS]);}}
 if(g.action==PA_PEDROKEN){range=24;yrange=32;if(progress.skills[FISTSOFFLAME]&&g.fury>=2*progress.skills[FISTSOFFLAME]){add_fury(-2*progress.skills[FISTSOFFLAME]);damage+=progress.skills[FISTSOFFLAME]*fury_bonus();shatter=rand()%100<progress.skills[FISTSOFFLAME]*20;}}
 if(g.action==PA_JUMPKICK||g.action==PA_DIVEKICK||g.action==PA_CHARGEKICK){if(rand()%100<progress.skills[LEADFOOT]*3){damage*=3;shatter=true;}}
 for(int i=0;i<g.enemies;i++){
  Enemy *e=&g.enemy[i];if(!nearby(e,range,yrange)||e->cool||e->ghost)continue;
  if(g.action!=PA_TORNADO&&((e->x>g.px)!=(g.face>0))&&absi(e->x-g.px)>8*16)continue;
  if(g.action==PA_DASH&&progress.skills[MIGHTYGRAB]&&(g.keys&HITKEY)&&e->type!=39&&e->type!=40&&e->type!=46&&e->type!=42){g.carry=i;g.action=PA_CARRY;g.dash=0;break;}
  enemy_hit(e,damage,g.action==PA_PEDROKEN?42:g.action==PA_DASH?36:18,shatter);
  fire_shot(56,2,(g.px+e->x)/32,(g.py+e->y)/32,0,0,0);
  if(g.action==PA_PUNCH){if(rand()%100<progress.skills[FISTOFFURY]*10)add_fury(2);int chain=progress.skills[LIGHTNINGFIST];for(int j=0;j<g.enemies&&chain;j++)if(j!=i&&g.enemy[j].active&&absi(g.enemy[j].x-e->x)+absi(g.enemy[j].y-e->y)<progress.skills[LIGHTNINGFIST]*20*16){enemy_hit(&g.enemy[j],20+20*progress.skills[LIGHTNINGFIST],0,false);chain--;}}
  else if(g.action!=PA_TORNADO)add_fury(progress.skills[FEETOFFURY]);
  if(g.action==PA_DIVEKICK){g.vy=-67;g.action=PA_JUMP;e->stun=12*progress.skills[KOKICK];}
  if(g.action==PA_JUMPKICK&&(g.keys&HITKEY)&&progress.skills[TORNADOKICK]){g.action=PA_TORNADO;g.actiontime=9*progress.skills[TORNADOKICK];}
 }
}
static void fury_update(void){
 if(!(g.keys&FURYKEY)){g.action=PA_IDLE;return;}
 g.vx=g.vy=0;
 if((g.tap&DOWN)&&progress.skills[FURIOUSBLAST]&&g.fury>=100){add_fury(-100);area_hit(skill_damage(PA_FURYPICK),190,true);for(int i=0;i<MAX_SHOTS;i++)if(g.shot[i].active&&g.shot[i].side==1&&rand()%100<progress.skills[FURIOUSROAR]*20)g.shot[i].active=0;g.action=PA_IDLE;}
 else if((g.tap&LEFT)&&progress.skills[FURIOUSFREEZE]&&g.fury>=100){add_fury(-100);for(int i=0;i<g.enemies;i++)if(nearby(&g.enemy[i],190,150)){g.enemy[i].freeze=45*progress.skills[FURIOUSFREEZE];g.enemy[i].freezehits=progress.skills[DEEPFREEZE]+1;}g.action=PA_IDLE;}
 else if((g.tap&RIGHT)&&progress.skills[FURIOUSFRENZY]&&g.fury>=100){add_fury(-100);g.berserk=progress.skills[FURIOUSFRENZY]*60;g.action=PA_IDLE;}
 else if((g.keys&UP)&&progress.skills[FURIOUSFIX]&&g.fury>=100){g.action=PA_FURYHEAL;g.healspent=0;g.actiontime=0;}
}
void player_update(void){
 if(g.tap&MENUKEY){g.mode=PAUSE;return;}
 if(g.invul)g.invul--;if(g.dodge)g.dodge--;if(g.attackcool)g.attackcool--;if(g.taptime)g.taptime--;if(g.canjump)g.canjump--;if(g.actiontime)g.actiontime--;if(g.berserk)g.berserk--;if(g.rage)g.rage--;
 if(progress.skills[INNERFURY]&&++g.inner>=90-15*progress.skills[INNERFURY]){g.inner=0;add_fury(1);}
 if(g.action==PA_FURYPICK){fury_update();return;}
 if(g.action==PA_FURYHEAL){g.vx=0;if(!(g.keys&UP)||!g.fury){g.action=PA_IDLE;}else if(++g.actiontime>=3){g.actiontime=0;add_fury(-5);g.healspent+=5;if(g.healspent>=20-3*progress.skills[FURIOUSFIX]){g.healspent-=20-3*progress.skills[FURIOUSFIX];g.hp=clampi(g.hp+100,0,maxlife());}}return;}
 if((g.tap&FURYKEY)&&g.fury>=100&&(progress.skills[FURIOUSBLAST]||progress.skills[FURIOUSFREEZE]||progress.skills[FURIOUSFIX]||progress.skills[FURIOUSFRENZY])){g.action=PA_FURYPICK;return;}
 if(g.berserk&&(g.tap&HITKEY)&&progress.skills[BURNINGFURY])fire_shot(57,0,g.px/16+4,g.py/16+8,g.face*55,0,progress.skills[BURNINGFURY]*50*fury_bonus()/100);
 bool normal=g.action==PA_IDLE||g.action==PA_JUMP||g.action==PA_DUCK||g.action==PA_CARRY||g.action==PA_CARRYJUMP;
 if(normal){
  int direction=(g.keys&LEFT)?-1:(g.keys&RIGHT)?1:0;
  if(direction){g.face=direction;g.vx=approach(g.vx,direction*37,5);}else g.vx=approach(g.vx,0,5);
  if(g.ground){g.doublejump=1;g.canjump=3;g.kicks=0;g.safex=g.px;g.safey=g.py;g.action=g.carry>=0?PA_CARRY:PA_IDLE;}
  else g.action=g.carry>=0?PA_CARRYJUMP:PA_JUMP;
  if((g.tap&(LEFT|RIGHT))&&progress.skills[BURROBASH]&&g.ground&&g.carry<0){if(g.taptime&&g.lastdir==direction){g.action=PA_DASH;g.dash=15*progress.skills[BURROBASH];g.vx=g.face*80;}g.lastdir=direction;g.taptime=6;}
  if((g.tap&(UP|JUMPKEY))&&(g.canjump||g.doublejump)){if(!g.canjump)g.doublejump=0;g.vy=-67;g.canjump=0;g.ground=0;g.action=g.carry>=0?PA_CARRYJUMP:PA_JUMP;}
  if((g.keys&DOWN)&&g.ground){g.action=PA_DUCK;g.vx=approach(g.vx,0,5);if(g.tap&DOWN)g.dodge=6*progress.skills[DODGE];}
  if(g.carry>=0){Enemy *e=&g.enemy[g.carry];if(!(g.keys&HITKEY)){e->thrown=90;e->vx=g.face*43;e->vy=-27;g.carry=-1;g.action=PA_IDLE;g.attackcool=15;}else if((g.tap&DOWN)&&!g.ground&&progress.skills[PILEDRIVER]){g.action=PA_PILEDRIVE;g.vy=27;g.vx=0;}}
  else if((g.tap&DOWN)&&!g.ground&&g.kicks<progress.skills[DIVEKICK]){g.kicks++;g.action=PA_DIVEKICK;g.vy=53;g.vx=g.face*32;}
  else if((g.keys&HITKEY)&&!g.attackcool){
   if(g.action==PA_DUCK&&progress.skills[PEDROKEN]){g.action=PA_PEDROKEN;g.actiontime=30;g.vy=-90;g.vx=g.face*21;}
   else if(g.ground){g.action=PA_PUNCH;g.actiontime=10;g.combo=1;g.vx=g.face*13;}
   else if(g.tap&HITKEY){g.action=PA_JUMPKICK;g.actiontime=12;g.vx=g.face*53;}
  }
 }
 if(g.action==PA_DASH){g.vx=g.face*80;if(--g.dash<=0)g.action=PA_IDLE;strike();}
 else if(g.action==PA_PUNCH){g.vx=approach(g.vx,0,1);if(g.actiontime==6)strike();if(!g.actiontime){if((g.keys&HITKEY)&&g.combo<1+progress.skills[PEDROPUNCH]){g.combo++;g.actiontime=10;}else{g.action=PA_IDLE;g.attackcool=12;}}}
 else if(g.action==PA_JUMPKICK){if(g.actiontime==8)strike();if((g.tap&HITKEY)&&g.actiontime<8&&progress.skills[CHARGEKICK]){g.action=PA_CHARGEKICK;g.actiontime=12;}if(!g.actiontime)g.action=PA_JUMP;}
 else if(g.action==PA_CHARGEKICK){Enemy *near=NULL;int best=999999;for(int i=0;i<g.enemies;i++)if(g.enemy[i].active){int d=absi(g.enemy[i].x-g.px)+absi(g.enemy[i].y-g.py);if(d<best){best=d;near=&g.enemy[i];}}if(near){int dx=near->x-g.px,dy=near->y-g.py,n=absi(dx)+absi(dy);if(!n)n=1;g.face=dx<0?-1:1;g.vx=dx*100/n;g.vy=dy*100/n;}strike();if(!g.actiontime)g.action=PA_JUMP;}
 else if(g.action==PA_DIVEKICK){g.vx=g.face*32;strike();if(g.ground)g.action=PA_IDLE;}
 else if(g.action==PA_TORNADO){g.vx=0;g.vy=-5;if(g.actiontime%9==0){g.face=-g.face;strike();}if(progress.skills[WHIRLWIND])for(int i=0;i<g.enemies;i++)if(nearby(&g.enemy[i],progress.skills[WHIRLWIND]*10,progress.skills[WHIRLWIND]*10)){g.enemy[i].x=approach(g.enemy[i].x,g.px,53);g.enemy[i].y=approach(g.enemy[i].y,g.py,53);}if(!g.actiontime||!(g.keys&HITKEY))g.action=PA_JUMP;}
 else if(g.action==PA_PEDROKEN){if(g.vy<0)strike();if(g.ground&&g.vy>=0)g.action=PA_IDLE;}
 else if(g.action==PA_HITSTUN){if((g.tap&DOWN)&&progress.skills[RECOVERY]){g.action=PA_JUMP;g.vy=30;}else if((g.tap&HITKEY)&&progress.skills[RETALIATE]&&g.fury>=20-3*progress.skills[RETALIATE]){add_fury(-(20-3*progress.skills[RETALIATE]));g.action=PA_CHARGEKICK;g.actiontime=12;}else if(!g.actiontime&&g.ground)g.action=PA_IDLE;}
 bool water=tile_at(g.px/16+4,g.py/16+8)==62;
 if(g.action!=PA_CHARGEKICK&&g.action!=PA_TORNADO)g.vy+=water?2:5;
 if((g.keys&JUMPKEY)&&g.vy>16&&!g.ground&&g.action==PA_JUMP){g.vy=16;g.action=PA_GLIDE;}
 if(g.action==PA_GLIDE){if(!(g.keys&JUMPKEY)||g.ground)g.action=PA_JUMP;else g.vy=16;normal=true;}
 g.vy=clampi(g.vy,-200,160);int oldx=g.px;move_body(&g.px,&g.py,&g.vy,g.vx,8,g.action==PA_DUCK?12:15,&g.ground);
 if(g.action==PA_DASH&&g.px==oldx){g.action=PA_HITSTUN;g.actiontime=12;g.vx=-g.face*27;g.vy=-40;}
 if(g.action==PA_PILEDRIVE&&g.ground&&g.carry>=0){Enemy *e=&g.enemy[g.carry];e->cool=0;enemy_hit(e,skill_damage(PA_PILEDRIVE),0,false);e->stun=15*progress.skills[PILEDRIVER];if(progress.skills[ATOMICPILEDRIVER]&&g.fury>=progress.skills[ATOMICPILEDRIVER]){add_fury(-progress.skills[ATOMICPILEDRIVER]);area_hit(progress.skills[ATOMICPILEDRIVER]*200*fury_bonus()/100,10+progress.skills[ATOMICPILEDRIVER]*6,false);}g.carry=-1;g.action=PA_JUMP;g.vy=-32;}
 if(g.py/16>(int)g.h*16+32){g.invul=0;player_hurt(100,0,0,0);g.px=g.safex;g.py=g.safey;g.vx=g.vy=0;}
 if(g.ground&&tile_at(g.px/16+4,g.py/16+17)==63)player_hurt(100,-g.face,40,-40);
 if(g.hp<=0)g.mode=DEFEAT;
}
