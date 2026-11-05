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
typedef struct { const uint16_t *cells; uint16_t length; } Route;
typedef struct { uint8_t width,height; uint16_t camp; uint8_t routeCount; const uint8_t *rle; const Route *routes; } Map;
typedef struct { const uint16_t *groups; uint8_t count; } Wave;
#include "data.h"
#include "art.h"
#define MAXEN 48
#define MAXTOWER 40
#define TOP 18
#define VIEW 184
volatile uint8_t scout_diag[8]; /* mode,level,wave,towers,alive,escaped,paused,victories */
typedef struct { int x,y,hp,maxhp; uint16_t step,progress,slow; uint8_t active,type,route,back,carry; } Enemy;
typedef struct { uint16_t cell; uint8_t active,type,level; int cooldown; } Tower;
typedef struct { int x,y,xx,yy; uint8_t age,color; } Shot;
static Enemy enemies[MAXEN];static Tower towers[MAXTOWER];static Shot shots[24];
static uint8_t layers[4][2500],mode,level,selection,escaped,wave,group,remaining,spawnRoute,unlocked=1,stageWon[17];
static int money,cx,cy,camx,camy,tick,spawnTimer,nextWave,statusTicks;static bool activeWave,paused;
static const Map *map;static char status[48],textbuf[80];
static const char *towerNames[]={"Rock Tower","Roly Poly","Snow Fort","Shock Tower"};
static const uint8_t prices[]={50,100,60,80};
static const uint8_t speeds[]={16,26,12,10,20,40,23,16,8};
static const uint8_t healthBase[]={3,2,20,80,16,5,18,30,220};
static const uint8_t healthScale[]={2,1,9,25,5,3,7,10,50};
static void say(const char*s){strncpy(status,s,47);status[47]=0;statusTicks=70;}
static void save(void){ti_var_t f=ti_Open("SCTSV01","w");if(f){ti_Write(stageWon,1,17,f);ti_Close(f);}}
static void load(void){ti_var_t f=ti_Open("SCTSV01","r");if(f){if(ti_GetSize(f)==17)ti_Read(stageWon,1,17,f);ti_Close(f);}for(int i=0;i<17;i++)if(stageWon[i]&&i<16&&unlocked<i+2)unlocked=i+2;}
static int towerAt(int cell){for(int i=0;i<MAXTOWER;i++)if(towers[i].active&&towers[i].cell==cell)return i;return -1;}
static int upgradeCost(Tower*t){int l=t->level;return (l+1)*(l+1)*(l+1)*(t->type==1?8:7)+(t->type==0?60:t->type==1?100:t->type==2?70:80);}
static bool valid(int x,int y){int p=y*map->width+x;if(x<2||x>=map->width-2||y<1||y>=map->height-1)return false;if(y==map->camp/map->width&&abs(x-map->camp%map->width)<=1)return false;return !layers[1][p]&&layers[1][p+map->width]&&!layers[2][p]&&!(layers[0][p]>=28&&layers[0][p]<=32);}
static void startLevel(void){map=maps[level];memset(layers,0,sizeof layers);const uint8_t*p=map->rle;int n=map->width*map->height;for(int l=0;l<4;l++){int k=0;while(k<n){int count=*p++,v=*p++;while(count--)layers[l][k++]=v;}}memset(enemies,0,sizeof enemies);memset(towers,0,sizeof towers);memset(shots,0,sizeof shots);money=160+20*level;wave=group=remaining=escaped=spawnRoute=0;activeWave=paused=false;nextWave=20*waveTimes[level];spawnTimer=0;cx=map->routes[0].cells[0]%map->width+4;cy=map->routes[0].cells[0]/map->width;selection=0;mode=1;tick=0;say("Build towers, then press + for a wave");}
static void build(void){int cell=cy*map->width+cx;if(towerAt(cell)>=0){say("ENTER upgrades; DEL sells this tower");return;}if(!valid(cx,cy)){say("Build on clear, solid ground");return;}if(money<prices[selection]){say("Not enough money");return;}for(int i=0;i<MAXTOWER;i++)if(!towers[i].active){towers[i]=(Tower){cell,1,selection,1,0};money-=prices[selection];say("Tower built");return;}say("Tower limit reached");}
static void upgrade(void){int i=towerAt(cy*map->width+cx);if(i<0){build();return;}Tower*t=&towers[i];if(t->level>=5){say("Maximum tower level");return;}int cost=upgradeCost(t);if(money<cost){say("Not enough money to upgrade");return;}money-=cost;t->level++;say("Tower upgraded");}
static int alive(void){int count=0;for(int i=0;i<MAXEN;i++)count+=enemies[i].active;return count;}
static int carried(void){int n=0;for(int i=0;i<MAXEN;i++)if(enemies[i].active&&enemies[i].carry)n++;return n;}
static void sendWave(void){if(activeWave){say("Finish spawning this wave first");return;}if(wave>=waveCounts[level])return;wave++;activeWave=true;group=0;remaining=waveSets[level][wave-1].groups[0];spawnTimer=0;nextWave=20*waveTimes[level];say("Aliens incoming!");}
static bool spawn(uint8_t type){for(int i=0;i<MAXEN;i++)if(!enemies[i].active){Enemy*e=&enemies[i];memset(e,0,sizeof *e);e->active=1;e->type=type;e->route=spawnRoute++%map->routeCount;int p=map->routes[e->route].cells[0];e->x=p%map->width*8+4;e->y=p/map->width*8+4;int lv=level*2+wave;e->hp=e->maxhp=healthBase[type]+healthScale[type]*lv;return true;}return false;}
static void hurt(Enemy*e,int damage){e->hp-=damage;if(e->hp<=0){money+=5+level+e->type*2;e->active=0;}}
static void stepEnemies(void){for(int i=0;i<MAXEN;i++){Enemy*e=&enemies[i];if(!e->active)continue;const Route*r=&map->routes[e->route];int speed=speeds[e->type];if(e->slow){e->slow--;speed=speed*2/5;}e->progress+=speed;if(e->progress>=256){e->progress-=256;if(e->back){if(e->step)e->step--;else{if(e->carry)escaped++;e->active=0;continue;}}else{if(e->step+1<r->length)e->step++;else{e->back=1;e->carry=(5-escaped-carried())>0;e->progress=0;}}}int a=r->cells[e->step],b=a;if(e->back){if(e->step)b=r->cells[e->step-1];}else if(e->step+1<r->length)b=r->cells[e->step+1];int ax=a%map->width*8+4,ay=a/map->width*8+4;int bx=b%map->width*8+4,by=b/map->width*8+4;e->x=ax+(bx-ax)*e->progress/256;e->y=ay+(by-ay)*e->progress/256;}}
static void shoot(int x,int y,int xx,int yy,int color){for(int s=0;s<24;s++)if(!shots[s].age){shots[s]=(Shot){x,y,xx,yy,4,color};return;}}
static void stepTowers(void){for(int i=0;i<MAXTOWER;i++){Tower*t=&towers[i];if(!t->active)continue;if(t->cooldown){t->cooldown--;continue;}int x=t->cell%map->width*8+4,y=t->cell/map->width*8+4;int range=(t->type==0?60+t->level*15:t->type==1?25+t->level*10:t->type==2?70+t->level*10:50+t->level*15)/2;Enemy*target=0;int best=999999;for(int j=0;j<MAXEN;j++){Enemy*e=&enemies[j];if(!e->active)continue;int dx=e->x-x,dy=e->y-y,dist=dx*dx+dy*dy;if(dist<=range*range&&dist<best){best=dist;target=e;}}if(!target)continue;int damage=t->type==0?5+t->level*2:t->type==1?15+t->level*4:t->type==2?3:5+t->level*4;shoot(x,y,target->x,target->y,t->type==2?31:t->type==3?252:222);if(t->type==2)target->slow=100+t->level*20;if(t->type==1||t->type==3){int targets=0,limit=t->type==1?MAXEN:t->level+1;for(int j=0;j<MAXEN;j++){Enemy*e=&enemies[j];int dx=e->x-target->x,dy=e->y-target->y;if(e->active&&dx*dx+dy*dy<=(t->type==1?225:100)&&targets<limit){hurt(e,damage);targets++;}}}else hurt(target,damage);t->cooldown=t->type==0?40-t->level*6:t->type==1?100-t->level*8:t->type==2?30-t->level*4:60-t->level*5;}}
static void update(void){tick++;for(int i=0;i<24;i++)if(shots[i].age)shots[i].age--;if(statusTicks)statusTicks--;if(paused)return;if(activeWave){if(spawnTimer)spawnTimer--;else{const Wave*w=&waveSets[level][wave-1];const uint16_t*g=w->groups+group*3;if(spawn(g[1])){spawnTimer=g[2];if(--remaining==0){group++;if(group>=w->count)activeWave=false;else remaining=w->groups[group*3];}}}}if(nextWave>0)nextWave--;if(!activeWave&&wave<waveCounts[level]&&nextWave<=0)sendWave();stepEnemies();stepTowers();if(escaped>=5){mode=3;return;}if(wave==waveCounts[level]&&!activeWave&&!alive()){mode=4;if(!stageWon[level]){stageWon[level]=1;save();}if(level<16&&unlocked<level+2)unlocked=level+2;}}
static void pixel(int x,int y){if(x>=0&&x<320&&y>=TOP&&y<TOP+VIEW)gfx_SetPixel(x,y);}
static void label(const char*s,int x,int y,int color){gfx_SetTextFGColor(color);gfx_PrintStringXY(s,x,y);}
static void box(int y){gfx_SetColor(1);gfx_FillRectangle(15,y,290,66);gfx_SetColor(150);gfx_Rectangle(15,y,290,66);}
static void renderMenu(void){art_background(ART_TITLESTATE_TITLEIMAGE_LEFT);box(155);snprintf(textbuf,sizeof textbuf,"<  Stage %u / 17  >",level+1);label(textbuf,80,165,255);label(stageWon[level]?"CAMP SAVED":"CAMP NEEDS YOUR HELP",73,184,stageWon[level]?92:222);label("LEFT / RIGHT choose stage",45,200,255);label("ENTER play   ALPHA controls",40,213,255);label("CLEAR quit",115,227,182);}
static void renderHelp(void){gfx_FillScreen(1);label("DEFEND THE CAMP'S FIVE MEALS",22,12,222);const char*lines[]={"Arrows: move building cursor","1 Rock $50     2 Roly Poly $100","3 Snow $60     4 Shock $80","2nd: build     ENTER: upgrade","DEL: sell      +: send next wave","ALPHA: pause   MODE: stage menu","CLEAR: exit (progress saves)","Snow slows; Shock chains; Roly blasts.","Kill thieves before they escape!","ENTER returns"};for(int i=0;i<10;i++)label(lines[i],10,36+i*19,255);}
static const uint8_t mobArt[]={ART_LUMPY,ART_SQUIRMY,ART_BEEFY,ART_BEASTY,ART_WORMY,ART_SPEEDY,ART_BLINKY,ART_SCARY,ART_HUNGRY};
static const uint8_t towerArt[]={ART_TOWER_ROCK,ART_TOWER_ROLL,ART_TOWER_SNOW,ART_TOWER_SHOCK};
static void renderGame(void) {
    camx = cx * 16 - 152;
    camy = cy * 16 - 112;
    if (camx > map->width * 16 - 320) camx = map->width * 16 - 320;
    if (camy > map->height * 16 - 240) camy = map->height * 16 - 240;
    if (camx < 0) camx = 0;
    if (camy < 0) camy = 0;
    int theme = level == 16 ? 2 : level > 11 ? 3 : level > 7 ? 2 : level > 3 ? 1 : 0;
    art_background(theme == 2 ? ART_SKY_CAVEIMAGE_LEFT : theme == 1 ? ART_SKY_SUNSETIMAGE_LEFT : ART_SKY_DESERTIMAGE_LEFT);
    for (int layer=0;layer<3;layer++) {
        for (int y=camy/16;y<map->height && y*16-camy<240;y++) {
            for(int x=camx/16;x<map->width && x*16-camx<320;x++) {
                int tile=layers[layer][y*map->width+x];
                if(tile&&tile<128) art_draw(ART_TILES0+theme,tile,x*16-camx,y*16-camy);
            }
        }
    }
    int fx=map->camp%map->width*16-camx, fy=map->camp/map->width*16-camy;
    art_draw(ART_TENT,0,fx-16,fy+8);
    art_draw(ART_TENT,0,fx+16,fy+8);
    art_draw(ART_FIRE,tick/2,fx,fy);
    for(int f=0;f<5-escaped-carried();f++) art_draw(ART_FOOD,f,fx-16+f*8,fy+2);
    for(int i=0;i<MAXTOWER;i++) {
        Tower *t=&towers[i];
        if(!t->active) continue;
        int x=t->cell%map->width*16-camx, y=t->cell/map->width*16-camy;
        int id=towerArt[t->type];
        art_draw(id,t->cooldown>0?(tick/2)%2:0,x,y+16-artTable[id].height);
        for(int l=0;l<t->level;l++) art_draw(ART_UPGRADE,0,x+(l%3)*5,y-5-(l/3)*5);
    }
    for(int i=0;i<MAXEN;i++) {
        Enemy *e=&enemies[i];
        if(!e->active) continue;
        int id=mobArt[e->type];
        int x=e->x*2-camx-artTable[id].width/2, y=e->y*2-camy+8-artTable[id].height;
        art_draw(id,tick/2,x,y);
        if(e->hp<e->maxhp) {
            gfx_SetColor(92);
            gfx_FillRectangle(x,y-2,artTable[id].width*e->hp/e->maxhp+1,1);
        }
        if(e->carry) art_draw(ART_FOOD,0,x,y-12);
    }
    for(int i=0;i<24;i++) if(shots[i].age) {
        Shot *shot=&shots[i];gfx_SetColor(shot->color);
        gfx_Line(shot->x*2-camx,shot->y*2-camy,shot->xx*2-camx,shot->yy*2-camy);
    }
    int x=cx*16-camx,y=cy*16-camy;
    art_draw(ART_BOX,valid(cx,cy)?1:0,x-4,y-4);
    art_draw(ART_CURSOR,0,x+4,y+4);
    art_draw(ART_HUD,0,195,0);
    snprintf(textbuf,sizeof textbuf,"$%d",money);label(textbuf,267,23,255);
    snprintf(textbuf,sizeof textbuf,"W%u/%u",wave,waveCounts[level]);label(textbuf,204,5,255);
    snprintf(textbuf,sizeof textbuf,"FOOD %d",5-escaped);label(textbuf,3,5,255);
    gfx_SetColor(1);gfx_FillRectangle(0,219,320,21);
    int ti=towerAt(cy*map->width+cx);
    if(ti>=0) {Tower*t=&towers[ti];snprintf(textbuf,sizeof textbuf,"%s L%u  Upgrade $%d",towerNames[t->type],t->level,upgradeCost(t));}
    else snprintf(textbuf,sizeof textbuf,"%u %s $%u   2nd BUILD",selection+1,towerNames[selection],prices[selection]);
    label(textbuf,3,222,255);
    if(paused) {box(90);label("PAUSED: ALPHA resumes",50,115,255);}
    if(mode==3||mode==4) {box(85);label(mode==4?"CAMP SAVED!":"THE FOOD IS GONE",85,98,255);label("ENTER retry / next   MODE menu",39,125,255);}
}
int main(void){if(!art_open()){os_ClrHome();os_PutStrFull("Send all SCAxx AppVars");while(!os_GetCSC());return 1;}load();gfx_Begin();gfx_SetPalette(artPalette,sizeof artPalette,0);gfx_SetTransparentColor(0);gfx_SetTextTransparentColor(0);gfx_SetTextBGColor(1);gfx_SetDrawBuffer();uint8_t prev[8]={0};int repeat=0;mode=0;bool running=true;while(running){kb_Scan();bool enter=(kb_Data[6]&kb_Enter)&&!(prev[6]&kb_Enter),alpha=(kb_Data[2]&kb_Alpha)&&!(prev[2]&kb_Alpha),modekey=(kb_Data[1]&kb_Mode)&&!(prev[1]&kb_Mode);if(kb_Data[6]&kb_Clear)break;if(mode==0){if((kb_Data[7]&kb_Left)&&!(prev[7]&kb_Left))level=(level+16)%17;if((kb_Data[7]&kb_Right)&&!(prev[7]&kb_Right))level=(level+1)%17;if(enter)startLevel();if(alpha)mode=5;}else if(mode==5){if(enter||modekey||alpha)mode=0;}else if(mode==3||mode==4){if(modekey)mode=0;else if(enter){if(mode==4)level=(level+1)%17;startLevel();}}else{if(modekey)mode=0;else{if(alpha)paused=!paused;bool move=kb_Data[7]&(kb_Left|kb_Right|kb_Up|kb_Down);if(move){if(!repeat||repeat>=4){if(kb_Data[7]&kb_Left)cx--;if(kb_Data[7]&kb_Right)cx++;if(kb_Data[7]&kb_Up)cy--;if(kb_Data[7]&kb_Down)cy++;if(cx<1)cx=1;if(cx>map->width-2)cx=map->width-2;if(cy<1)cy=1;if(cy>map->height-2)cy=map->height-2;repeat=1;}else repeat++;}else repeat=0;if(kb_Data[3]&kb_1)selection=0;if(kb_Data[4]&kb_2)selection=1;if(kb_Data[5]&kb_3)selection=2;if(kb_Data[3]&kb_4)selection=3;if((kb_Data[1]&kb_2nd)&&!(prev[1]&kb_2nd))build();if(enter)upgrade();if((kb_Data[1]&kb_Del)&&!(prev[1]&kb_Del)){int i=towerAt(cy*map->width+cx);if(i>=0){money+=prices[towers[i].type]/2+towers[i].level*10;towers[i].active=0;say("Tower sold");}}if((kb_Data[6]&kb_Add)&&!(prev[6]&kb_Add))sendWave();update();}}if(mode==0)renderMenu();else if(mode==5)renderHelp();else renderGame();scout_diag[0]=mode;scout_diag[1]=level;scout_diag[2]=wave;int count=0;for(int i=0;i<MAXTOWER;i++)count+=towers[i].active;scout_diag[3]=count;scout_diag[4]=alive();scout_diag[5]=escaped;scout_diag[6]=paused;scout_diag[7]=stageWon[level];for(int k=0;k<8;k++)prev[k]=kb_Data[k];gfx_SwapDraw();delay(50);}save();gfx_End();return 0;}

