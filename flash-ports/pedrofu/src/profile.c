#include "game.h"
#include "hwdiag.h"
#include "sky_runtime.h"
Progress progress;
int maxlife(void){int n=5;for(int i=0;i<15;i++)n+=progress.hearts[i]!=0;return n*100;}
int maxfury(void){int n=1;for(int i=0;i<15;i++)n+=progress.souls[i]!=0;return (n>5?5:n)*100;}
void profile_load(void){
 memset(&progress,0,sizeof progress);uint8_t f=ti_Open("PDPROG2","r");uint8_t head[4];
 if(f){if(ti_Read(head,1,4,f)==4&&!memcmp(head,"PDF2",4)&&ti_GetSize(f)==sizeof progress+4)ti_Read(&progress,1,sizeof progress,f);ti_Close(f);}
 for(int i=0;i<45;i++)if(progress.skills[i]>5)progress.skills[i]=0;
 if(progress.rank>99)progress.rank=0;
}
void profile_save(void){
#ifdef PEDRO_HWDIAG
 unsigned saved_phase=diag_last_phase;DIAG_PHASE(DP_FILEIO);
#endif
 uint8_t f=ti_Open("PDPROG2","w");if(f){ti_Write("PDF2",1,4,f);ti_Write(&progress,1,sizeof progress,f);ti_Close(f);}
 sky_runtime_refresh();
#ifdef PEDRO_HWDIAG
 diag_free_ram=os_MemChk(NULL);DIAG_PHASE(saved_phase);
#endif
}
/* Original Profile.GetXP: truncate the Fancy Footwork bonus, level at most once per gain, keep the remainder. */
void profile_xp(int n){n=n*(100+progress.skills[FANCYFOOTWORK]*6)/100;if(progress.rank==99){progress.xp=1;return;}progress.xp+=n;int need=progress.rank*10+50;if(progress.xp>=need){progress.xp-=need;progress.rank++;progress.points++;if(progress.rank==99)progress.xp=1;notice("Level up! A skill point is ready.");}}
int skill_need(int id){int spent=0,rank=(id%15)/3;for(int i=id/15*15;i<id/15*15+rank*3;i++)spent+=progress.skills[i];return rank*3-spent;}
bool skill_adjust(int id,int change){if(id<0||id>=45)return false;
 if(change>0){if(!progress.have[id]||!progress.points||progress.skills[id]>=5||skill_need(id)>0)return false;progress.skills[id]++;progress.points--;}
 else {if(!progress.skills[id])return false;progress.skills[id]--;for(int i=id/15*15;i<id/15*15+15;i++)if(progress.skills[i]&&skill_need(i)>0){progress.skills[id]++;return false;}progress.points++;}
 profile_save();return true;
}
void notice(const char *s){g.notice=s;g.notice_timer=100;}
/* Original Pedro.AddFury: surplus fury accumulates; each (0.5 - 0.08*rank) of it heals one heart. */
void add_fury(int n){
 if(n<0&&rand()%100<progress.skills[FURYMASTER]*3)return;
 int top=maxfury();
 if(n>0){if(g.fury>=top)g.excess+=n;else if(g.fury+n>top)g.excess+=g.fury+n-top;}
 int p=progress.skills[FURYOVERLOAD];
 if(p){int threshold=50-8*p;while(g.excess>threshold){g.excess-=threshold;if(g.hp<maxlife())g.hp=clampi(g.hp+100,0,maxlife());}}
 g.fury=clampi(g.fury+n,0,top);
}
void collect_power(int which){
 switch(which){
 case 0:if(!progress.hearts[g.level]){progress.hearts[g.level]=1;g.hp+=100;notice("Omega Heart: maximum life increased!");}break;
 case 1:case 2:case 3:{int id=g.level+(which-1)*15;if(!progress.have[id]){progress.have[id]=1;notice(skillnames[id]);}}break;
 case 4:if(!progress.souls[g.level]){progress.souls[g.level]=1;notice("Fury Soul: maximum fury increased!");}break;
 case 5:if(g.mailleft>0)g.mailleft--;if(!g.mailleft){progress.passed[g.level]=1;if(!progress.best[g.level]||progress.best[g.level]>g.ticks)progress.best[g.level]=g.ticks;profile_save();g.mode=VICTORY;}break;
 case 6:g.hp=maxlife();notice("Mmm, healed!");break;
 case 7:g.hp=clampi(g.hp+300,0,maxlife());break;
 }profile_save();
}
int punch_bonus(void){return 100+10*progress.skills[IRONFIST]+3*progress.skills[FISTOFFURY]+2*progress.skills[GALEFIST];}
int kick_bonus(void){return 100+3*progress.skills[FEETOFFURY]+3*progress.skills[POWERKICK]+10*progress.skills[STEELTOES];}
int fury_bonus(void){return 100+3*progress.skills[HEARTOFFURY]+4*progress.skills[MAXIMUMFORCE]+4*progress.skills[FURYMASTER];}
/* Damage is in hundredths of the original game's heart units; each stage rounds to nearest. */
#define RDIV(a,b) (((a)+(b)/2)/(b))
int skill_damage(int type){long n=0;switch(type){
 case PA_PUNCH:n=RDIV((100L+10*progress.skills[PEDROPUNCH])*punch_bonus(),100);break;
 case PA_DASH:n=RDIV((200L+100*progress.skills[BURROBASH])*punch_bonus(),100);break;
 case PA_CARRY:n=RDIV(progress.skills[MIGHTYGRAB]*300L*(100+10*progress.skills[STRONGARM]+3*progress.skills[COCONUTBONK]),100);break;
 case PA_PILEDRIVE:n=RDIV(progress.skills[PILEDRIVER]*300L*(100+10*progress.skills[STRONGARM]+3*progress.skills[COCONUTBONK]),100);break;
 case PA_PEDROKEN:n=RDIV(progress.skills[PEDROKEN]*150L*punch_bonus(),100);break;
 case PA_JUMPKICK:n=RDIV((100L+100*progress.skills[FLYINGKICK])*kick_bonus(),100);break;
 case PA_DIVEKICK:n=RDIV((200L+50*progress.skills[KOKICK])*kick_bonus(),100);break;
 case PA_CHARGEKICK:n=RDIV((100L+100*progress.skills[CHARGEKICK])*kick_bonus(),100);break;
 case PA_TORNADO:n=kick_bonus();break;
 case PA_FURYPICK:n=RDIV((progress.skills[FURIOUSBLAST]*300L+progress.skills[FURIOUSROAR]*200L)*fury_bonus(),100);break;
 }if(g.berserk)n*=2;if(g.rage)n=RDIV(n*(100+8*progress.skills[RAGINGBURRO]),100);if(g.hp==maxlife()&&g.fury==maxfury())n=RDIV(n*(100+6*progress.skills[MAXIMUMFORCE]),100);return (int)n;
}
