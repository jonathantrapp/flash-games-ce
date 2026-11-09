#ifndef SCOUT_ENGINE_H
#define SCOUT_ENGINE_H
#define MAXEN 160
#define MAXTOWER 64
#define MAXBULLET 96
#define FP 256
/* Keep enemy physics out of main(): inlined there, every local spill needs the slow
 * far-IX sequence of main's >128-byte frame (measured 7.3 -> 8.5 FPS crowded). */
#ifndef PHYS_ATTR
#define PHYS_ATTR __attribute__((noinline))
#endif
#define HZ 20
#define COORD(name) union {int name;struct __attribute__((packed)) {uint8_t name##_fraction;int16_t name##_pixel;};}
/* Positions and velocities are 8.8 fixed point; health/damage are hundredths. */
typedef struct { const uint16_t *cells; uint16_t length; } Route;
typedef struct { uint8_t width,height; uint16_t camp; uint8_t routeCount; uint16_t rleOffset; const Route *routes; } Map;
typedef struct { const uint16_t *groups; uint8_t count; } Wave;
#include "data.h"
#include "rules.h"
uint8_t skills[48];
static uint8_t layers[4][2500],mode,level,selection,escaped,wave,unlocked=1,stageWon[17];
static int money,cx,cy,camx,camy,tick,statusTicks,skillCursor,playerLevel=1,skillPoints,xp;
static bool paused,sendFast;
/* Original slider: 0..60 px in 5px steps, divided by 15 => 0..4x. */
static uint8_t speedThirds=3,previousSpeedThirds=3;
static int16_t focusEnemy=-1;
static const Map *map;
static char status[80],textbuf[100];
volatile uint8_t scout_diag[16];
typedef struct {
    COORD(x);COORD(y);int vx,vy,hp,maxhp,traveled;
    uint16_t born,slow,freeze,poison,shock,shockDamage,disabled,crippled,boost,flat,fling,special,babyLevel;
    uint16_t home,monsterLevel,babyThreshold,speed,scale,wobble,birthLength;
    uint8_t poisonTick,frostTick,shockTick;
    int8_t wobbleDir;
    uint8_t active,type,action,ground,immune,advancing,escaping,slowRate;
    int8_t facing,carry;
    uint8_t homeX,homeY; /* immutable portal coordinates, populated at spawn */
    int movementVelocity,movementStep; /* derived vx/60 cache; zeroed at spawn */
} Enemy;
typedef struct {
    uint16_t cell,spent,damage,range,reloadTime,second,cooldown,born,noFire,buff,buffTime,animation,instaLock,buildTime;
    uint8_t active,type,level;
    int8_t facing;
} Tower;
typedef struct {COORD(x);COORD(y);int vy;int16_t holder;uint8_t active;} Food;
typedef struct {COORD(x);COORD(y);int vx,vy,damage,remaining;uint16_t power,shockPower;int16_t target;uint8_t active,type,pop,age,airSkip,inAir;uint8_t victims[MAXEN/8];} Bullet;
typedef struct {uint16_t timer;uint8_t active,group,count;} Spawner;
static Enemy enemies[MAXEN];
static Tower towers[MAXTOWER];
static Food foods[5];
static Bullet bullets[MAXBULLET];
/* All enemy/bullet slots at or above these marks are inactive. Loops over
 * active objects stop there; free-slot searches still scan every slot. */
static int enemyTop,bulletTop;
static Spawner spawners[24];
static int waveDue[24];
static const uint8_t baseTypes[]={ROCK,ROLL,SNOW,SHOCK};
static const uint8_t baseSkills[]={SK_ROCKTOWER,SK_ROLYPOLY,SK_SNOWFORT,SK_SHOCKER};
static const uint8_t branchTypes[4][2]={{SLING,SOAPBOX},{CRUSHER,QUAKE},{ICE,SLUSHEE},{CRIPPLER,LIGHTNING}};
static const uint8_t branchSkills[4][2]={{SK_SLINGSHOT,SK_SOAPBOX},{SK_CRUSHER,SK_QUAKE},{SK_ICELAUNCHER,SK_SLUSHEE},{SK_CRIPPLER,SK_LIGHTNINGROD}};
static __attribute__((always_inline)) inline int ex(const Enemy *e){return e->x_pixel;}
static __attribute__((always_inline)) inline int ey(const Enemy *e){return e->y_pixel-monsterHeight[e->type]/2;}
static int squareDistance(int x,int y,int xx,int yy){int dx=x-xx,dy=y-yy;return dx*dx+dy*dy;}
static int random100(void){return rand()%100;}
static void say(const char *s){strncpy(status,s,sizeof status-1);status[sizeof status-1]=0;statusTicks=60;}
static uint16_t rowOffsets[64];
static uint8_t mapWidth,mapHeight,campTileX,campTileY;
static __attribute__((always_inline)) inline int tileAt(int layer,int x,int y){if((unsigned)x>=mapWidth||(unsigned)y>=mapHeight)return layer==1?1:0;return layers[layer][rowOffsets[y]+x];}
static bool slope(int tile){return tile==14||tile==18;}
PHYS_ATTR static int surface(int x,int y){int tile=tileAt(1,x/16,y/16);if(!tile)return 32767;int top=(y/16)*16;if(tile==14)return top+15-(x&15);if(tile==18)return top+(x&15);return top;}
static bool lineClear(int x,int y,int xx,int yy){int dx=xx-x,dy=yy-y,n=abs(dx)>abs(dy)?abs(dx):abs(dy);if(!n)return true;for(int t=4;t<n;t+=4)if(tileAt(1,(x+dx*t/n)/16,(y+dy*t/n)/16))return false;return true;}
static int alive(void){int n=0;for(int i=0;i<enemyTop;i++)n+=enemies[i].active;return n;}
static int towerAt(int cell){for(int i=0;i<MAXTOWER;i++)if(towers[i].active&&towers[i].cell==cell)return i;return -1;}
static int foodLeft(void){int n=0;for(int i=0;i<5;i++)n+=foods[i].active;return n;}
static bool valid(int x,int y){int p=y*map->width+x;if(x<=1||x>=map->width-2||y<=1||y>=map->height-1)return false;if(y==map->camp/map->width&&abs(x-map->camp%map->width)<=1)return false;int below=layers[1][p+map->width];return !layers[1][p]&&below&&!slope(below)&&!layers[2][p]&&!(layers[0][p]>=28&&layers[0][p]<=32);}
static int skillNeeded(int idx){const SkillRule*r=&skillRules[idx];int id=r->icon;if((id==SK_LIGHTNINGROD||id==SK_CRIPPLER)&&!skills[SK_SHOCKER])return 999;if((id==SK_ICELAUNCHER||id==SK_SLUSHEE)&&!skills[SK_SNOWFORT])return 999;if((id==SK_CRUSHER||id==SK_QUAKE)&&!skills[SK_ROLYPOLY])return 999;int spent=0;for(int i=0;i<48;i++)if(skillRules[i].group==r->group&&skillRules[i].rank<r->rank)spent+=skills[skillRules[i].icon];return r->rank*3-spent;}
static void earnXP(int n){xp+=n;int need=playerLevel*(playerLevel<5?50:100);if(xp>need&&playerLevel<99){xp-=need;playerLevel++;skillPoints++;say("LEVEL UP! One skill point earned");}}
typedef struct {uint8_t magic[4],skills[48],wins[17],level;uint16_t points;uint32_t xp;} Save;
static void save(void){Save s={{'S','C','V','2'},{0},{0},0,0,0};memcpy(s.skills,skills,48);memcpy(s.wins,stageWon,17);s.level=playerLevel;s.points=skillPoints;s.xp=xp;ti_var_t f=ti_Open("SCTSV02","w");if(f){ti_Write(&s,1,sizeof s,f);ti_Close(f);}art_open();}
static void load(void){skills[SK_ROCKTOWER]=1;ti_var_t f=ti_Open("SCTSV02","r");if(f){Save s;if(ti_GetSize(f)==sizeof s&&ti_Read(&s,1,sizeof s,f)==sizeof s&&!memcmp(s.magic,"SCV2",4)){memcpy(skills,s.skills,48);memcpy(stageWon,s.wins,17);playerLevel=s.level>=1&&s.level<=99?s.level:1;skillPoints=s.points>999?999:s.points;xp=s.xp>9900?9900:s.xp;for(int i=0;i<48;i++)if(skills[i]>5)skills[i]=5;for(int i=0;i<17;i++)stageWon[i]=!!stageWon[i];if(!skills[SK_ROCKTOWER])skills[SK_ROCKTOWER]=1;}ti_Close(f);}for(int i=0;i<17;i++)if(stageWon[i]&&i<16)unlocked=i+2;}
static void towerStats(Tower *t){t->damage=rule_DamageCalc(t->type,t->level)*100;t->range=rule_RangeCalc(t->type,t->level);t->reloadTime=rule_ReloadCalc(t->type,t->level)*HZ;t->second=rule_SecondCalc(t->type,t->level)*HZ;}
static int upgradeCost(Tower*t){return rule_UpgradePrice(t->type,t->level)*(1-skills[SK_ENHANCEMENT]*0.03f);}
static void build(void){int cell=cy*map->width+cx,type=baseTypes[selection];if(towerAt(cell)>=0)return;if(!skills[baseSkills[selection]]){say("Unlock this tower in Skills first");return;}if(!valid(cx,cy)){say("Build on clear solid ground");return;}int cost=rule_BasePrice(type,0);if(money<cost){say("Not enough money");return;}for(int i=0;i<MAXTOWER;i++)if(!towers[i].active){Tower*t=&towers[i];memset(t,0,sizeof *t);t->cell=cell;t->active=1;t->type=type;t->spent=cost;t->cooldown=0;t->buff=100;t->buffTime=0;t->noFire=0;t->instaLock=0;t->animation=0;t->born=HZ;t->buildTime=2*HZ;t->buff=100;t->facing=1;towerStats(t);money-=cost;say("Building...");return;}}
static void upgrade(void){int i=towerAt(cy*map->width+cx);if(i<0){build();return;}Tower*t=&towers[i];if(t->level==5){say("Maximum level");return;}int cost=upgradeCost(t);if(money<cost){say("Not enough money");return;}money-=cost;t->spent+=rule_UpgradePrice(t->type,t->level);t->level++;if(!t->buildTime)t->buildTime=HZ;towerStats(t);if(t->type==SOAPBOX&&random100()<skills[SK_ENCOURAGEMENT]*5){for(int j=0;j<MAXTOWER;j++){Tower*n=&towers[j];if(n->active&&n!=t&&n->level<5&&squareDistance(t->cell%map->width*16,t->cell/map->width*16,n->cell%map->width*16,n->cell/map->width*16)<=t->range*t->range){n->level++;towerStats(n);break;}}}say("Tower upgraded");}
static void convertTower(int branch){int i=towerAt(cy*map->width+cx);if(i<0)return;Tower*t=&towers[i];if(t->type>SHOCK){say("This tower is already specialized");return;}int skill=branchSkills[t->type][branch];if(!skills[skill]){say("Unlock this specialization in Skills");return;}int type=branchTypes[t->type][branch],cost=rule_BasePrice(type,0);if(money<cost){say("Not enough money");return;}money-=cost;t->type=type;t->spent=cost;t->cooldown=0;t->buff=100;t->buffTime=0;t->noFire=0;t->instaLock=0;t->animation=0;t->born=HZ;t->buildTime=2*HZ;towerStats(t);say("Tower specialization built");}
static void sellTower(void) {
    int i=towerAt(cy*map->width+cx);if(i<0)return;
    Tower*t=&towers[i];money+=t->spent/2;if(money>9999)money=9999;t->active=0;
    int time=skills[SK_SELL_TOWER]*(t->level+1)*HZ/5;
    if(time)for(int j=0;j<enemyTop;j++) {
        Enemy*e=&enemies[j];if(!e->active)continue;
        if(e->freeze){if(e->freeze<time)e->freeze=time;}
        else e->freeze=(e->type==3||e->type==8)?time/2:time;
    }
    say("Tower sold");
}
static Enemy *spawnEnemy(int type,int lv,int portal){for(int i=0;i<MAXEN;i++)if(!enemies[i].active){Enemy*e=&enemies[i];memset(e,0,sizeof *e);e->active=1;if(i>=enemyTop)enemyTop=i+1;e->type=type;e->home=portal;e->homeX=portal%mapWidth;e->homeY=portal/mapWidth;e->x=(portal%map->width*16+8)*FP;e->y=(portal/map->width*16+16)*FP;e->facing=rand()&1?1:-1;e->advancing=1;e->carry=-1;e->monsterLevel=lv;e->hp=e->maxhp=monster_Life(type,lv)*100;e->born=e->birthLength=HZ;e->speed=monsterSpeed[type]*FP;e->scale=10000;e->wobble=1000;e->wobbleDir=-1;e->slowRate=100;e->babyThreshold=99;e->babyLevel=1;return e;}return NULL;}
static void dropFood(Enemy*e){if(e->carry>=0){Food*f=&foods[e->carry];f->holder=-1;f->x=e->x;f->y=e->y-monsterHeight[e->type]*FP/2;f->vy=0;e->carry=-1;}}
typedef struct {int16_t x,y;uint16_t damage;} Explosion;
static Explosion explosions[MAXEN];
static unsigned explosionRead,explosionWrite;
static void damageEnemy(Enemy*e,int damage,bool crit) {
    if(!e->active||e->immune)return;
    if((uint32_t)e->hp<(uint32_t)e->maxhp*skills[SK_FINISHHIM]*8/100)damage=damage*125/100;
    if(e->crippled)damage=damage*(100+skills[SK_CRIPPLER]*10)/100;
    if(e->escaping)damage=damage*(100+skills[SK_POISONTRAP]*5)/100;
    if(crit&&random100()<skills[SK_CRITICAL]*2)damage*=2;
    e->hp-=damage;
    if(e->hp>0)return;
    e->hp=0;dropFood(e);e->active=0;if(e-enemies==focusEnemy)focusEnemy=-1;
    money+=monster_Money(e->type,e->monsterLevel)*(100+skills[SK_CASHFLOW]*4)/100;
    if(money>9999)money=9999;earnXP(e->monsterLevel);
    /* A death may kill another crippled alien. Queue the chain to bound stack use. */
    if(e->crippled&&skills[SK_MEGAWATT]&&explosionWrite<MAXEN)
        explosions[explosionWrite++]=(Explosion){ex(e),ey(e),skills[SK_MEGAWATT]*500};
}
static void resolveExplosions(void) {
    while(explosionRead<explosionWrite){Explosion p=explosions[explosionRead++];
        for(int i=0;i<enemyTop;i++){Enemy*e=&enemies[i];if(e->active&&squareDistance(p.x,p.y,ex(e),ey(e))<=900)damageEnemy(e,p.damage,true);}}
    explosionRead=explosionWrite=0;
}
static void shockEnemy(Enemy*e,int time,int damage) {
    if(!e->shock)e->shockTick=0;e->shock=time;
    if(e->shockDamage<damage)e->shockDamage=damage;
}
static void slowEnemy(Enemy*e,int time,int amount,bool disable){if(e->type==3||e->type==8)time/=2;e->slow=time;e->slowRate=100-amount;if(e->slowRate<5)e->slowRate=5;if(disable)e->disabled=time;}
static void chain(Enemy*target,int x,int y){int n=skills[SK_CHAINLIGHTNING]+1;if(!skills[SK_CHAINLIGHTNING])return;for(int i=0;i<MAXEN&&n;i++){Enemy*e=&enemies[i];if(e->active&&e!=target&&!e->immune&&squareDistance(ex(target),ey(target),ex(e),ey(e))<900){damageEnemy(e,skills[SK_CHAINLIGHTNING]*200,true);n--;}}(void)x;(void)y;}
static void stepStatus(Enemy*e) {
    if(e->slow)e->slow--;if(e->disabled)e->disabled--;if(e->crippled)e->crippled--;if(e->boost)e->boost--;if(e->fling)e->fling--;
    if(e->poison){e->poison--;if(!e->poisonTick){e->poisonTick=HZ;damageEnemy(e,skills[SK_GATHEREDMOSS]*30,true);}if(e->poisonTick)e->poisonTick--;}
    if(e->slow||e->freeze){if(!e->frostTick){e->frostTick=HZ/2;damageEnemy(e,skills[SK_FROSTBITE]*25*(e->freeze?2:1)*(e->shock?100+skills[SK_CONDUCTANCE]*5:100)/100,true);}if(e->frostTick)e->frostTick--;}
    if(e->shock){e->shock--;if(++e->shockTick>=HZ/2){e->shockTick=0;Enemy*other=NULL;int count=0,range=20+skills[SK_ARCING]*8;
        for(int i=0;i<enemyTop;i++){Enemy*n=&enemies[i];if(n->active&&n!=e&&!n->immune&&squareDistance(ex(e),ey(e),ex(n),ey(n))<range*range){if(rand()%++count==0)other=n;}}
        damageEnemy(other?other:e,e->shockDamage,true);
    }}
}
/* ---- Helper-free arithmetic for the physics hot path ----
 * This compiler lowers every multi-bit shift (x>>8, x/16, x*256) and the 14/18 slope
 * test (as 1<<tile) to looping runtime helpers, ~20 per substep. These forms give the
 * same values: byte loads through a volatile view, left shifts (inline adds), a table.
 * The original slope/surface/ex above stay for the frozen reference that
 * tests/check_native_physics.py compares this physics against. */
typedef union { int i; uint8_t b[3]; } IntBytes;
/* v/16 (C truncation): for 0<=v<4096 it is the middle byte of v<<4. */
static __attribute__((always_inline)) inline int div16f(int v){if((unsigned)v<4096u){volatile IntBytes t;t.i=v<<4;return t.b[1];}return v/16;}
/* The packed pixel half of a COORD, loaded from memory rather than re-derived as x>>8. */
static __attribute__((always_inline)) inline int pixelOf(const int *coord){return *(volatile const int16_t*)((const uint8_t*)coord+1);}
/* v*FP for -32768<=v<32768 (all pixel coordinates). */
static __attribute__((always_inline)) inline int toFP(int v){volatile IntBytes s,t;s.i=v;t.b[0]=0;t.b[1]=s.b[0];t.b[2]=s.b[1];return t.i;}
/* v/FP (C truncation). */
static __attribute__((always_inline)) inline int fromFP(int v){if(v<0)return v/FP;volatile IntBytes s,t;s.i=v;t.b[0]=s.b[1];t.b[1]=s.b[2];t.b[2]=0;return t.i;}
static const uint8_t slopeTiles[19]={[14]=1,[18]=1};
static __attribute__((always_inline)) inline bool isSlope(int tile){return (unsigned)tile<19u&&slopeTiles[tile];}
static int surfaceF(int x,int y){int ty=div16f(y),tile=tileAt(1,div16f(x),ty);if(!tile)return 32767;int top=ty*16;uint8_t sub=(uint8_t)x&15;if(tile==14)return top+15-sub;if(tile==18)return top+sub;return top;}
static const Map *limitMap;
static int limitFP;
PHYS_ATTR static void physicsEnemy(Enemy*e,int substep){
    if(e->born){if(!substep)e->born--;return;}
    if(!substep)stepStatus(e);if(!e->active)return;
    if(e->freeze){if(!substep)e->freeze--;return;}if(e->flat){if(!substep)e->flat--;return;}
    int h=monsterHeight[e->type],half=(uint8_t)monsterHeight[e->type]>>1,px=pixelOf(&e->x),feet=pixelOf(&e->y),py=feet-half;
    int tilex=div16f(px),tiley=div16f(py);
    if(tilex==campTileX&&tiley==campTileY)e->advancing=0;
    if(tilex==e->homeX&&tiley==e->homeY){e->advancing=1;if(e->escaping){if(e->carry>=0){foods[e->carry].active=0;escaped++;}e->active=0;if(e-enemies==focusEnemy)focusEnemy=-1;return;}}
    int speed=e->speed;
    if(e->action==1)speed=35*FP;else if(e->boost&&e->type!=1&&e->type!=5)speed=40*FP;
    if(e->slow)speed=speed*e->slowRate/100;
    if(e->escaping)speed=speed*(100-skills[SK_REFRIGERATION]*5)/100;
    if(!e->fling)e->vx=e->facing==1?speed:e->facing==-1?-speed:e->facing*speed;
    if(e->ground){
        int front=div16f(px+e->facing*4),checky=tiley;
        if(isSlope(tileAt(1,tilex,checky)))checky--;
        int wall=tileAt(1,front,checky);
        if(wall&&!isSlope(wall)){e->facing=-e->facing;e->vx=-e->vx;}
        int marker=tileAt(3,tilex,tiley);
        bool up=(e->advancing?campTileY:e->homeY)*16<py;
        if(up&&marker>=3&&marker<=11){int direction=(marker-3)%3,power=(marker-3)/3+1;bool dirOK=direction==2||(direction==0&&e->facing<0)||(direction==1&&e->facing>0);if(dirOK&&((e->facing<0&&px<=tilex*16+8)||(e->facing>0&&px>=tilex*16+8))){e->x=(tilex*16+8)*FP;e->vy=-(90+30*(power-1))*FP;e->vx=e->facing*35*FP;e->action=1;e->ground=0;}}
    }
    if(e->vx!=e->movementVelocity){e->movementVelocity=e->vx;e->movementStep=e->vx/60;}
    int oldx=e->x,oldy=e->y;e->x+=e->movementStep;{int moved=e->x-oldx;e->traveled+=moved<0?-moved:moved;}
    int nx=pixelOf(&e->x),mid=div16f(pixelOf(&e->y)-half),wall=tileAt(1,div16f(nx+e->facing*2),mid);
    if(wall&&!isSlope(wall)){e->x=oldx;e->facing=-e->facing;e->vx=-e->vx;}
    if(map!=limitMap){limitMap=map;limitFP=(map->width*16-3)*FP;}
    if(e->x<3*FP){e->x=3*FP;e->facing=1;}if(e->x>limitFP){e->x=limitFP;e->facing=-1;}
    int oldVelocity=e->vy;e->vy+=200*FP/60;e->y+=(oldVelocity+e->vy)/120;e->ground=0;
    int oldFeet=fromFP(oldy),newFeet=pixelOf(&e->y),x=pixelOf(&e->x);
    /* FlxTilemapExt floor slopes accept feet through the inclusive bottom
     * edge, including upward motion. Looking only in feet/16 misses that
     * edge and lets a walker enter beneath the slope. */
    int slopeRow=div16f(newFeet-1),slopeTile=tileAt(1,div16f(x),slopeRow);
    int slopeSurface=isSlope(slopeTile)?surfaceF(x,slopeRow*16):32767;
    if(newFeet>=slopeSurface&&newFeet<=slopeRow*16+16){
        e->y=toFP(slopeSurface);e->vy=0;e->ground=1;e->action=0;
    }
    else if(e->vy>=0){for(int yy=div16f(oldFeet),last=div16f(newFeet)+1;yy<=last;yy++){int surf=surfaceF(x,yy*16);if(surf!=32767&&surf>=oldFeet-4&&surf<=newFeet+1){e->y=toFP(surf);e->vy=0;e->ground=1;e->action=0;break;}}}
    else {
        /* Original tiles14/18 carry FLOOR and a side flag, never CEILING. */
        int row=div16f(newFeet-h),ceiling=tileAt(1,div16f(x),row);
        if(ceiling&&!isSlope(ceiling)){e->y=toFP((row+1)*16+h);e->vy=0;}
    }
    e->immune=e->type==4&&e->ground&&!e->disabled;
}
static void stepSpecials(Enemy*e){if(e->disabled||e->born)return;
    if(e->type==5){for(int i=0;i<enemyTop;i++){Enemy*n=&enemies[i];if(n->active&&n!=e&&n->type!=5&&squareDistance(ex(e),ey(e),ex(n),ey(n))<1600)n->boost=10;}}
    if(e->type==6&&tick%10==0){for(int i=0;i<enemyTop;i++){Enemy*n=&enemies[i];if(n->active&&n!=e&&squareDistance(ex(e),ey(e),ex(n),ey(n))<3600){n->hp+=e->monsterLevel*100;if(n->hp>n->maxhp)n->hp=n->maxhp;}}}
    if(e->type==7&&tick%5==0){for(int i=0;i<MAXTOWER;i++){Tower*t=&towers[i];if(t->active&&squareDistance(ex(e),ey(e),t->cell%map->width*16+8,t->cell/map->width*16+8)<3600)t->noFire=6;}}
    if(e->type==8){e->wobble+=e->wobbleDir<0?-25:15;if(e->wobble<=750){e->wobble=750;e->wobbleDir=1;}if(e->wobble>=1000){e->wobble=1000;e->wobbleDir=-1;}if(e->special)e->special--;if(!e->special&&e->ground&&(uint32_t)e->hp<=(uint32_t)e->maxhp*e->babyThreshold/100){e->babyThreshold--;e->scale=(uint32_t)e->scale*99/100;e->special=HZ;for(int j=0;j<3;j++){Enemy*b=spawnEnemy(9,e->babyLevel,e->home);if(b){b->x=e->x;b->y=e->y;b->facing=e->advancing?e->facing:-e->facing;b->speed=j==0?35*FP:j==1?35*FP/2:35*FP/4;b->born=b->birthLength=j==0?9:j==1?18:36;b->traveled=e->traveled;b->vx=0;b->special=j;}}e->babyLevel++;}for(int j=0;j<5;j++){Food*f=&foods[j];if(f->active&&f->holder>=0&&squareDistance(ex(e),ey(e),f->x_pixel,f->y_pixel)<100){Enemy*n=&enemies[f->holder];f->active=0;n->carry=-1;n->escaping=0;n->facing=-n->facing;n->advancing=!n->advancing;escaped++;}}}
}
static void stepFood(void){
    for(int i=0;i<5;i++){
        Food *f=&foods[i];if(!f->active)continue;
        if(f->holder>=0){
            Enemy *e=&enemies[f->holder];
            if(!e->active){f->holder=-1;continue;}
            f->x=e->x;f->y=e->y-monsterHeight[e->type]*FP;continue;
        }
        int old=f->y_pixel;f->vy+=200*FP/HZ;f->y+=f->vy/HZ;
        for(int yy=old/16;yy<=f->y_pixel/16+1;yy++){
            int surf=surface(f->x_pixel,yy*16);
            if(surf>=old-2&&surf<=f->y_pixel){f->y=surf*FP;f->vy=0;break;}
        }
        const int fx=f->x_pixel,fy=f->y_pixel;
        for(int j=0;j<enemyTop;j++){
            Enemy *e=&enemies[j];
            if(!e->active||e->born||e->escaping||e->type==8||e->action==1)continue;
            /* A distance below16 requires both integer axes in[-15,15].
             * Reject distant enemies before either software multiply. */
            int dx=fx-ex(e);if((unsigned)(dx+15)>=31)continue;
            int dy=fy-ey(e);if((unsigned)(dy+15)>=31)continue;
            if(dx*dx+dy*dy>=256)continue;
            f->holder=j;e->carry=i;e->escaping=1;
            if(e->advancing){e->facing=-e->facing;e->advancing=0;}
            break;
        }
    }
}
#endif
