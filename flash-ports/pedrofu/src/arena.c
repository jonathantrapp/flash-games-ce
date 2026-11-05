#include "game.h"
static const uint8_t locations[]={1,7,3,9,5,10,8,11,10,12,22,12,24,11,27,10,29,9,31,7};
static const uint8_t locations2[]={3,10,5,11,2,16,7,15,10,13,11,18,29,10,27,11,30,16,25,15,22,13,21,18,16,12};
static const uint8_t rounds[]={2,2,2,2,2,2,2,2,2,2,30,17,17,17,17,17,17,17,17,17,17,30,41,0,0,0,16,16,0,0,0,41,60,45,45,45,0,38,38,0,45,45,45,60,41,38,38,41,45,45,41,38,38,41,80};
static const uint8_t rounds2[]={2,2,2,2,2,2,2,2,2,2,2,2,2,40,45,0,45,0,45,0,45,0,45,0,45,0,45,60,0,35,0,35,0,35,0,35,0,35,0,35,35,90,16,41,47,0,0,0,16,41,47,0,0,0,47,90,38,38,41,38,41,0,38,38,41,38,41,0,47,120};
static const uint8_t powerPos[]={15,11,15,12,17,11,17,12,0,0,16,10};
static const uint8_t powerPos2[]={2,10,10,13,22,13,30,10,0,0,16,12};

void arena_setup(void){
 const uint8_t *roundsdata=g.level==13?rounds2:rounds,*loc=g.level==13?locations2:locations;int count=g.level==13?13:10;
 if(g.arenaround>=5)return;
 for(int i=0;i<count;i++){int type=roundsdata[g.arenaround*(count+1)+i];if(type)spawn_enemy(type,loc[i*2],loc[i*2+1],1);}
 g.arenatime=roundsdata[g.arenaround*(count+1)+count]*30;
}
void arena_update(void){
 if(g.arena<0||g.arenaround>=5)return;if(g.arenatime>0)g.arenatime--;
 for(int i=0;i<g.enemies;i++)if(g.enemy[i].active&&g.enemy[i].tag==1)return;
 const uint8_t *powers=g.level==13?powerPos2:powerPos;
 drop_power(5,powers[10]*16,powers[11]*16);
 if(g.arenatime>0){int reward=-1;if(!progress.hearts[g.level])reward=0;else for(int i=0;i<3;i++)if(!progress.have[g.level+i*15]){reward=i+1;break;}
 if(reward>=0)drop_power(reward,powers[reward*2]*16,powers[reward*2+1]*16);else profile_xp((g.arenaround+1)*50);notice("Round cleared with a bonus!");}
 else notice("Round cleared - no time bonus!");
 g.arenaround++;arena_setup();
}
