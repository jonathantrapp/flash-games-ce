#include "../src/game.h"
static int parity_rand(void){return 99;}
#define rand parity_rand
#include "../src/profile.c"
Game g;
int clampi(int v,int lo,int hi){return v<lo?lo:v>hi?hi:v;}
static void reset(void){memset(&progress,0,sizeof progress);memset(&g,0,sizeof g);}
int main(void){
 int actions[]={PA_PUNCH,PA_DASH,PA_CARRY,PA_PILEDRIVE,PA_PEDROKEN,PA_JUMPKICK,PA_DIVEKICK,PA_CHARGEKICK,PA_TORNADO,PA_FURYPICK};
 for(int p=0;p<231;p++)for(int m=0;m<8;m++){
  reset();for(int i=0;i<45;i++)progress.skills[i]=p<6?p:(i==(p-6)/5?(p-6)%5+1:0);
  g.berserk=m&1;g.rage=m&2;g.hp=m&4?maxlife():100;g.fury=m&4?maxfury():0;
  for(int t=0;t<10;t++)printf("D %d %d %d %d\n",p,m,t,skill_damage(actions[t]));
  if(!m)for(int i=0;i<45;i++)printf("S %d %d %d\n",p,i,skill_need(i));
 }
 for(int n=0;n<=15;n++){reset();for(int i=0;i<n;i++)progress.hearts[i]=progress.souls[i]=1;printf("M %d %d %d\n",n,maxlife(),maxfury());}
 int gains[]={0,1,49,50,51,100,500,10000};
 for(int r=0;r<100;r+=7)for(int f=0;f<=5;f++)for(int a=0;a<8;a++){
  reset();progress.rank=r;progress.skills[FANCYFOOTWORK]=f;profile_xp(gains[a]);printf("X %d %d %d %d %d %d\n",r,f,gains[a],progress.rank,progress.xp,progress.points);
 }
 reset();progress.rank=98;progress.xp=1020;profile_xp(10);printf("L %d %d %d\n",progress.rank,progress.xp,progress.points);
 for(int rank=1;rank<=5;rank++){
  reset();progress.skills[FURYOVERLOAD]=rank;g.hp=100;g.fury=maxfury();
  for(int i=0;i<10;i++){add_fury(20);printf("F %d %d %d %d\n",rank,i+1,g.hp,g.fury);}
 }
 return 0;
}
