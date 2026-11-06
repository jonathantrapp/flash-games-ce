#include <tice.h>
#include <graphx.h>
#include <keypadc.h>
#include <fileioc.h>
#include <sys/timers.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "../../src/art.h"
bool art_open(void){return true;}
const uint8_t *art_map_data(void){return NULL;}
void art_cache_level(const uint8_t*a,const uint8_t*b,const uint8_t*c,int d,int e){(void)a;(void)b;(void)c;(void)d;(void)e;}
#include "../../src/engine.h"
#include "../../src/combat.h"
volatile uint8_t engine_diag[4];
static const uint16_t portal[]={290};static const Route route[]={ {portal,1} };
static const Map testMap={32,12,253,1,0,route};
#define CHECK(c,id) do{if(!(c)){engine_diag[1]=(id);goto failed;}engine_diag[3]++;}while(0)
static void flat(void){focusEnemy=-1;map=&testMap;mapWidth=32;mapHeight=12;for(int y=0;y<12;y++)rowOffsets[y]=y*32;memset(layers,0,sizeof layers);for(int x=0;x<32;x++)layers[1][10*32+x]=1;memset(enemies,0,sizeof enemies);memset(towers,0,sizeof towers);memset(bullets,0,sizeof bullets);memset(skills,0,sizeof skills);skills[0]=1;money=500;}
int main(void){
 flat();Enemy*e=spawnEnemy(0,1,290);e->born=0;e->ground=1;e->facing=1;e->x=136*FP;e->y=160*FP;
 for(int t=0;t<20;t++){tick++;for(int sub=0;sub<3;sub++)physicsEnemy(e,sub);}
 CHECK(abs(e->x-156*FP)<FP,1);CHECK(e->y==160*FP,2);
 for(int power=0;power<3;power++){
  flat();e=spawnEnemy(0,1,290);e->born=0;e->ground=1;e->facing=1;e->x=136*FP;e->y=160*FP;layers[3][9*32+8]=4+power*3;
  int minimum=e->y;
  for(int t=0;t<20;t++){tick++;for(int sub=0;sub<3;sub++){physicsEnemy(e,sub);if(e->y<minimum)minimum=e->y;}}
  int expected=power==0?5184:power==1?9216:14400;
  CHECK(abs((160*FP-minimum)-expected)<FP,3+power);
 }
 flat();e=spawnEnemy(8,49,290);e->born=0;e->ground=1;e->hp=(uint32_t)e->maxhp*99/100;stepSpecials(e);
 CHECK(alive()==4,10);CHECK(e->scale==9900,11);CHECK(enemies[1].speed==35*FP,12);CHECK(enemies[2].speed==35*FP/2,13);CHECK(enemies[3].speed==35*FP/4,14);CHECK(enemies[1].born==9&&enemies[2].born==18&&enemies[3].born==36,15);
 flat();skills[SK_FREE_PEBBLES]=3;towers[0].active=1;towers[0].type=SLING;towers[0].cell=9*32+5;towers[0].cooldown=100;bullets[0].active=1;bullets[0].type=ROLL;bullets[0].x=88*FP;bullets[0].y=152*FP;bullets[0].remaining=100*FP;stepBullets();CHECK(towers[0].cooldown==0&&towers[0].instaLock==140,20);
 flat();skills[SK_SELL_TOWER]=4;cx=5;cy=9;towers[0].active=1;towers[0].cell=cy*32+cx;towers[0].level=2;towers[0].spent=50;
 for(int i=0;i<3;i++){e=spawnEnemy(i?3:0,1,290);e->born=0;e->x=(300+i*10)*FP;}
 enemies[2].freeze=5;sellTower();CHECK(enemies[0].freeze==48,21);CHECK(enemies[1].freeze==24,22);CHECK(enemies[2].freeze==48,23);
 flat();skills[SK_SLINGSHOT]=1;cx=5;cy=9;towers[0].active=1;towers[0].cell=cy*32+cx;towers[0].level=3;towers[0].spent=500;towers[0].buff=150;towers[0].cooldown=99;convertTower(0);CHECK(towers[0].type==SLING&&towers[0].level==3,24);CHECK(towers[0].spent==(int)rule_BasePrice(SLING,0)&&towers[0].cooldown==0&&towers[0].buff==100,25);
 flat();e=spawnEnemy(0,1,290);e->x=500*FP;e->y=100*FP;Tower*t=&towers[0];t->type=SLING;t->cell=9*32+2;t->damage=2300;t->range=600;t->buff=100;createBullet(t,e);CHECK(bullets[0].vx>0&&bullets[0].vy<0,26);CHECK(isqrt((bullets[0].vx/FP)*(bullets[0].vx/FP)+(bullets[0].vy/FP)*(bullets[0].vy/FP))>=198,27);
 flat();Enemy *a=spawnEnemy(0,1,290),*b=spawnEnemy(0,1,290);a->born=b->born=0;a->x=100*FP;b->x=180*FP;a->y=b->y=160*FP;a->traveled=100;b->traveled=1000;
 Tower aim={0};aim.type=ROCK;aim.range=250;
 CHECK(findTarget(&aim,88,152,false)==b,30);
 focusEnemy=0;CHECK(findTarget(&aim,88,152,false)==a,31);
 a->immune=1;CHECK(findTarget(&aim,88,152,false)==b,32);
 aim.type=SNOW;CHECK(findTarget(&aim,88,152,false)==a,33);
 a->slow=1;CHECK(findTarget(&aim,88,152,false)==b,34);
 a->slow=0;a->freeze=1;CHECK(findTarget(&aim,88,152,false)==b,35);
 aim.type=ICE;CHECK(findTarget(&aim,88,152,false)==b,36);
 a->immune=a->freeze=0;aim.type=SHOCK;a->shock=1;CHECK(findTarget(&aim,88,152,false)==b,37);
 b->shock=1;CHECK(findTarget(&aim,88,152,false)==a,38);
 a->shock=b->shock=0;a->x=120*FP;b->x=80*FP;layers[1][9*32+6]=1;aim.type=ROCK;
 CHECK(findTarget(&aim,88,152,false)==b,39);
 aim.type=SLING;CHECK(findTarget(&aim,88,152,false)==a,40);
 aim.type=CRIPPLER;a->immune=1;CHECK(findTarget(&aim,88,152,false)==a,41);
 a->crippled=1;CHECK(findTarget(&aim,88,152,false)==b,42);
 a->immune=a->crippled=0;a->x=b->x=88*FP;a->y=b->y=100*FP;focusEnemy=1;aim.type=LIGHTNING;
 CHECK(findTarget(&aim,88,152,false)==a,43);
 CHECK(focusAt(88,94)==0,44);CHECK(focusAt(500,94)==-1,45);
 focusEnemy=0;damageEnemy(a,100000,false);CHECK(focusEnemy==-1,46);
 focusEnemy=1;b->x=40*FP;b->y=(144+monsterHeight[0]/2)*FP;b->escaping=1;b->carry=-1;physicsEnemy(b,0);CHECK(focusEnemy==-1&&!b->active,47);
 engine_diag[0]=1;os_ClrHome();os_PutStrFull("ENGINE PARITY PASS");while(!os_GetCSC()){}return 0;
failed:engine_diag[0]=2;os_ClrHome();os_PutStrFull("ENGINE CHECK FAILED");while(!os_GetCSC()){}return 1;
}
